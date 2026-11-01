# EGO1 单周期 CPU：重新整理的独立工程

## 只打开这个工程

`D:/Code/Vivado/ego1_single_cycle/ego1_single_cycle.xpr`

顶层模块为 `ego1_top`，器件为 `xc7a35tcsg324-1`。源码和约束均在本目录内，不依赖旧的 `ego1_cpu` 工程。旧工程保留用于回查。

## 与旧版的区别

- 沿用已经通过逐条指令仿真的 CPU 内核，重新创建 Vivado 工程和板级顶层。
- K3 的闪烁由 100MHz 输入时钟直接计数产生，与已正常上板的 LED 实验相同。
- CPU 使用计数器与 BUFG 得到的 1MHz 时钟，约束文件明确声明 /100 生成时钟。
- 上电自动复位；S0/R11 按下复位 CPU。K3 心跳不会被 CPU 复位关闭。
- 使用压缩配置文件，USR_ACCESS 标记为 `53433130`。

## 下载后的现象（本版灯的分配有所调整）

| 板上标号 | FPGA 引脚 | 含义 | 正常现象 |
|---|---|---|---|
| D16 | K3 | 100MHz 时钟心跳 | 每 0.5 秒翻转，闪烁周期 1 秒 |
| D15 | M1 | CPU 程序完成且结果正确 | 常亮 |
| D14 | L1 | CPU 或结果检查错误 | 熄灭 |

**本版 K3 是闪烁灯，M1 是通过灯，不能按旧工程的分配判断。**

按住右下五键区最右侧 S0（丝印 R11）：D15 和 D14 熄灭，D16 继续闪烁。松开后 CPU 重新执行程序，D15 重新亮起。程序执行很快，短按时可能看不清 D15 的熄灭过程。

## Vivado 操作

1. 打开本目录唯一的 `ego1_single_cycle.xpr`。
2. 在 Sources 查看 Design Sources 顶层为 `ego1_top`。
3. 本工程已在本机执行构建；核对 `reports/build_result.txt` 和 `download` 目录中的文件。
4. 连接 EGO1 的 J6（JTAG & UART），打开开发板电源。
5. Open Hardware Manager → Open Target → Auto Connect。
6. 识别出 `xc7a35t_0` 后，Program Device，选择：

   `D:/Code/Vivado/ego1_single_cycle/download/ego1_single_cycle.bit`

7. 观察上表中的三盏灯。若扫描仍报 No devices detected，再在硬件目标属性中降低 JTAG 频率，例如 250000 或 125000Hz。这是连接排查设置，与 CPU 的 1MHz 运行频率无关。

打开 `.xpr` 只是打开工程；Program Device 加载的是 `.bit`。因此要核对所选下载文件的完整路径，防止继续下载旧工程结果。

## 仿真

默认 Simulation Sources 顶层为 `tb_ego1_top`，Run Behavioral Simulation 检查板级时钟、复位、程序结果和灯光逻辑。仿真只加快了心跳显示，CPU 仍按实际 /100 分频运行。

要查看每条指令的执行，可把 `tb_single_cycle_cpu` 设为仿真顶层。该测试包含独立参考模型生成的 PC、指令、寄存器回写、访存和分支期望，以及 10 类错误情况。

## 当前 CPU 范围

支持 15 条 LoongArch 子集指令：ADD.W、SUB.W、ADDI.W、LU12I.W、AND、OR、XOR、SLLI.W、SRLI.W、SRAI.W、LD.W、ST.W、BEQ、BNE、B。

演示程序验证 7+5=12、1+2+3+4+5=15，并写入完成标记 1。结果分别保存在数据地址 0、4、8，最后执行 B 自循环。每条正常指令使用一个 CPU 时钟周期；数据 RAM 采用异步读。

这是第四题的单周期基线阶段，流水线、乘除法和不少于 20 条指令仍待后续完成。

## 本机验证结果（2026-10-28，最终同步复位版本）

- 内核：61 条动态执行指令、873 项主程序检查、226 项错误情况检查通过。
- 板级：26 项检查通过，包含实际 1MHz 分频、上电启动、按键复位、重复运行和独立心跳。
- 布局布线后：建立时间裕量 5.824ns，保持时间裕量 0.097ns，全部指定时序约束满足，内部未约束端点为 0。
- DRC：0 个问题；CDC：两个连接均为安全/信息级，无严重跨时钟问题。
- 下载文件：506762 字节，已与 Vivado 原始输出逐字节哈希核对一致。
- 实际开发板运行：用户于 2026-10-28 确认三盏灯及 S0/R11 复位后重跑的现象均符合预期。此工程保留为已验证的 LoongArch 单周期基线。

## 文件组织

- `rtl/`：内核、ROM、RAM 和板级顶层。
- `constraints/ego1.xdc`：引脚、时钟和时序约束。
- `sim/`：内核与板级测试。
- `programs/`：汇编程序、机器码列表和参考执行结果。
- `scripts/`：创建工程、验证仿真、构建下载文件。
- `reports/`：本机实际运行日志、时序、DRC 和构建结果。
- `download/ego1_single_cycle.bit`：本版上板文件。

仿真和时序检查通过只能说明软件验证结果；实际板上运行须以上述灯光观察确认。
