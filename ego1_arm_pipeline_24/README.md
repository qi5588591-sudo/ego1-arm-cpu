# EGO1 ARM A32 五级流水线 CPU：24 条指令（含乘除法）

2026-10-31：本机实现、仿真、综合与布局布线已完成；用户已确认新版本下载、灯光及 S0 复位重跑符合预期，实板演示验证通过。已验证的 21 条版本位于 `D:/Code/Vivado/ego1_arm_pipeline`，本次没有修改其 RTL、约束或 bit。修改前副本另保存在本目录 `baseline_21/`。

## 本机最终验证结果

- CPU：77079 项检查通过；板级仿真：26 项检查通过。
- 建立时间裕量：6.173ns；保持时间裕量：0.051ns；DRC：0；内部未约束端点：0。
- LUT：2274（10.93%）；FF：1421（3.42%）；DSP：0。
- bit 大小：765551 字节；SHA256：`A9BF47941C74A642255B8FC5C2CC31C1AA4DCF1143E8590B56A44271805AE4FD`。
- 可追溯记录：`reports/verification_summary.json`、`reports/cpu_simulation.log`、`reports/final_checks.log` 及实现报告。用户确认的实板记录见 `reports/physical_board_verification.json`，与上述 bit 的 SHA256 绑定；重新生成不同 bit 后须重新验证实板。

## 打开与下载

- 工程：`D:/Code/Vivado/ego1_arm_pipeline_24/ego1_arm_pipeline_24.xpr`
- 下载文件：`D:/Code/Vivado/ego1_arm_pipeline_24/download/ego1_arm_pipeline_24.bit`
- 顶层：`ego1_arm_pipeline_top`；器件：`xc7a35tcsg324-1`。
- 保留已经验证的板级方案：100MHz/P17，CPU 1MHz，S0/R11 高有效复位；D16/K3 独立心跳，D15/M1 通过，D14/L1 故障。自动启动，不需要手动启动序列。
- 新文件 USR_ACCESS 为 `41525032`（ARP2），区别于 21 条版本的 `41525031`。

通过 Hardware Manager 识别 xc7a35t_0 后，在 Program Device 中明确选择上述新 bit，保留启动状态检查。正常预期：startup HIGH，D16 闪烁、D15 常亮、D14 熄灭。按住 S0 时 D15/D14 熄灭，松开后 D15 重新常亮。JTAG 与 CPU 时钟独立；如需沿用此前稳定设置，可在打开目标前设置 JTAG=125000Hz。

新程序会验证 24 条指令和乘除边界，完成时仍要求 RAM 0x1000/0x1004/0x1008 为 12/15/1，以及一次新退休的完成写入；不能只因上次保留的 RAM 状态而点亮通过灯。正常新演示在旁路流水线上为 1042 拍，约 1.042ms（按测试中的退休计数区间，未含板级复位延迟）。

## 指令范围

| 类别 | 基础指令 |
|---|---|
| 算术 | ADD、SUB、RSB、ADC、SBC |
| 逻辑 | AND、ORR、EOR、BIC |
| 传送 | MOV、MVN |
| 比较 | CMP、CMN、TST |
| 访存 | LDR、STR、LDRB、STRB |
| 控制流 | B、BL、BX |
| 乘除 | MUL、SDIV、UDIV |

采用 A32 ARMv7-A 子集并包含 A32 整数除法扩展，不是完整 ARMv7 处理器。汇编文件显式声明 `.arch armv7-a` 和 `.arch_extension idiv`；不混入 A64 指令。条件后缀、S 位和寻址形式不额外计数。

- MUL 写低 32 位；MULS 更新 N/Z、保留 C/V；普通 MUL 不改标志。
- SDIV 按有符号整数除法向零截断，UDIV 按无符号除法；两者不改 NZCV。
- 除零返回 0，不产生除零异常；SDIV 的 0x80000000 / 0xffffffff 返回 0x80000000。
- 所有乘除源/目的寄存器禁止 R15；R0 是正常寄存器。未实现 MLA、长乘、余数、Thumb、特权寄存器和完整异常体系。
- 原 21 条指令的支持形式与限制保持一致：数据处理的立即数/立即数控制移位、不回写基址的立即数偏移访存、字对齐检查、A32 BX 等。

架构依据：[Armv7-A/R 架构手册](https://documentation-service.arm.com/static/5f8daeb7f86e16515cdb8c4e)、[Arm 指令参考](https://documentation-service.arm.com/static/6245c734b059dc5ff9a8bdab)。A32 除法在部分 Armv7-A 实现中是可选扩展，不能把它描述为所有 Armv7-A 芯片都支持的功能。

## 实现与冒险

`rtl/arm_mdu.v` 是固定 32 次迭代的移位加法乘法器和恢复余数除法器。没有组合 `/`、`%` 或依赖运算符推断的大型组合除法器。`start/busy/done` 连接 EX；CPU 锁存条件与 MULS 保留标志，MDU 锁存操作数。运算时保持 PC、IF/ID、ID/EX，给 EX/MEM 注入空泡，让旧 MEM/WB 排空。一次运算产生 33 拍前端停顿，完成结果按原 MEM/WB 路径旁路、提交。条件不成立不启动 MDU；旧错误或复位取消请求，错误路径不能启动运算或写入结果。

寄存器旁路、WB→ID 旁路、load-use 暂停、NZCV 旁路及分支冲刷均保留。细节和时序例子见 [MDU_DESIGN.md](MDU_DESIGN.md)。性能数据见 [PERFORMANCE.md](PERFORMANCE.md)。

## 验证与复现

`scripts/build_programs.py` 用真实 LLVM ARM 汇编器产生机器码，再由独立的 Python 助记符语义模型产生逐条退休期望。参考模型没有复用 RTL 译码器；没有声称使用外部 ARM 模拟器。

1. 保留原 3 程序 × 单周期参考/旁路流水线/仅暂停流水线的回归。
2. 新增 3 个乘除程序 × 两种流水线；核对每条 PC、机器码、条件、寄存器、内存和 NZCV，核对真实存储次数、MDU 请求次数、停顿次数。
3. 23 类精确错误 × 两种流水线，包括非法 MDU 编码/R15、旧 MEM 错误优先、错误路径不启动 MDU、旧乘法完成后才报告年轻错误。
4. MDU 单元 1443 组 Python 整数参考向量，覆盖有符号/无符号边界与随机值、忙时输入变化/请求、所有 32 个迭代位置的复位取消。
5. 完整流水线在 MUL、SDIV、UDIV 忙时复位，验证取消、无过期提交及重新执行。
6. 板级仿真保持真实 /100 分频，验证自动启动、独立心跳、完整 24 条演示、重复复位、保留 RAM 及故障指示。

CPU 回归顶层 `tb_arm_pipeline`；板级顶层 `tb_ego1_arm_pipeline_top`。原单周期仿真内核仍只有 21 条指令，只参与旧程序回归；24 条程序使用 Python 参考模型核对两种流水线，不把旧内核冒充 24 条单周期 CPU。

运行顺序：Python 执行 `scripts/build_programs.py`；Vivado batch 执行 `scripts/run_all.tcl`。脚本会依次创建工程（若不存在）、验证 CPU、验证板级、综合实现并生成新 bit。最终报告位于 `reports/`；当前 bit 已获用户确认实板演示通过，后续不同 bit 的硬件状态须重新确认。
