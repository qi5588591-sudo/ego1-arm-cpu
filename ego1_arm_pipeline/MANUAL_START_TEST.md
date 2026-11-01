# 手动启动诊断版（2026-10-31）

> 当前状态（2026-10-31）：用户确认板卡问题处理后，原自动启动 bit 下载成功（startup HIGH），D15 常亮、D16 闪烁。主工程顶层和约束已恢复为修改前内容；本文件后文保留排查过程。手动诊断工程已改为引用 verified_sources 中的独立快照，今后打开该诊断工程不会误用主工程自动启动源码。正常使用请选择 download/ego1_arm_pipeline.bit，不再运行 diagnose_program.tcl。

用于排查 startup LOW 和下载后 JTAG 掉线。此版本尚未完成实板验证，不能视为故障已经修复。

## 备份与修改范围

修改前备份：`D:/Code/Vivado/ego1_arm_pipeline/backups/manual_start_20261031_205706/`。
备份包含 RTL、约束、程序、脚本、仿真、报告、原有 bit 文件、XPR 和原路由检查点；`SHA256.csv` 为校验清单。

修改了 `rtl/ego1_arm_pipeline_top.v`：保持 100MHz 心跳和 /100 分频，使用 BUFGCE 在配置后关闭 CPU 时钟。等待 100ms 后，要求 S0 稳定松开至少 100ms，再按下才启用 CPU 时钟；启用后不再关闭，S0 恢复普通 CPU 复位功能。CPU 内部、指令程序、引脚和电平标准没有修改。原 XDC 的生成时钟声明移到分频寄存器 Q，以覆盖 BUFGCE 输入及使能端的时序检查；版本标记改为 MST1。时钟使能在分频时钟低电平中段更新。

新测试 `sim/tb_ego1_arm_pipeline_manual_start.sv` 使用厂商 BUFGCE 仿真模型，检查配置期间按住按钮、就绪前按下按钮、松开抖动、稳定松开但未再次按下时 CPU 时钟无边沿、独立心跳、手动启用、1MHz 周期、保持复位、程序结果 12/15/1、后续复位和保留 RAM 后重新完成。仿真只缩短就绪等待与可见心跳，保留真实 /100 分频。

## 下载与观察

新文件：`D:/Code/Vivado/ego1_arm_pipeline/download/ego1_arm_pipeline_manual_start.bit`。
旧的 `ego1_download` 过程固定指向旧 bit，不能用于此次测试。

1. 用 125000Hz JTAG 识别 xc7a35t_0。
2. Program Device 选择上述新文件，保持 end of startup check 勾选。
3. 下载期间按住 S0/R11。若 startup 仍 LOW，记录失败并停止；不要执行后续启动步骤。
4. 若 startup HIGH，按住至少 1 秒。预期 D16/K3 闪烁，D15/M1、D14/L1 熄灭；CPU 时钟此时关闭。
5. 松开 S0，等待 1 秒。CPU 时钟仍应关闭。
6. 再按住 S0 1 秒：启用 CPU 时钟，同时保持 CPU 复位。
7. 松开 S0：预期 D16 闪烁，D15 常亮，D14 熄灭。若此时连接丢失，记录发生在按下还是松开阶段。
8. 启动后 S0 可再次复位 CPU；重新下载或断电后需要再次进行手动启动序列。

metadata 标记 USR_ACCESS 为 `4D535431`（MST1）。仅在芯片仍能识别时可查询：

```tcl
get_property REGISTER.USR_ACCESS [get_hw_devices xc7a35t_0]
```

## 构建和报告

独立诊断工程：`diagnostics/manual_start_final/project/ego1_arm_pipeline_manual_start.xpr`。
构建脚本：`scripts/build_manual_start.tcl`。首次构建后该脚本不会覆盖已有诊断工程；重建前需另选输出目录或在独立工程中重新实现。

报告位于 `diagnostics/manual_start_final/`：`simulation.log`、`timing_summary.rpt`、`check_timing.rpt`、`drc.rpt`、`cdc.rpt`、`utilization.rpt`、`build_result.txt`。
原 `reports/` 中的性能、板级自动启动测试和实现报告属于修改前的自动启动版本。
原自动启动板级 testbench 没有手动启动步骤，不适用于当前顶层；本版使用新增的手动启动 testbench。

本次不连接硬件，不重启 GUI 或硬件服务。原 XPR 的运行结果没有重建；GUI 如提示源码在外部改变，请重新加载源码。可在当前 Hardware Manager 中直接选择新 bit，无需重新生成。

## 恢复原顶层

在没有构建运行时，将备份目录的 `rtl/ego1_arm_pipeline_top.v` 和 `constraints/ego1.xdc` 分别复制回当前对应目录，即可恢复自动启动源码及原约束；已有旧 bit 文件保持原样。后续若重新构建原工程，应先确认使用的是哪种顶层模式。

## 已完成的本机验证

最终测试版已在 Vivado 2025.2 完成 40 项手动启动仿真检查、综合、布局布线和 bitstream 生成。
建立时序裕量 5.008ns，保持时序裕量 0.063ns；时钟使能建立裕量 7.849ns、保持裕量 0.285ns。
DRC 为 0；无未定义时钟、无内部未约束端点、无生成时钟错误。CDC 各条均为安全/信息级。
CPU 层次保留 2960 个单元，确认不是 CPU 被优化删除后的小型心跳电路。

bit 文件大小：645123 字节。
SHA256：A79D3A2EA66049C2FB816C4A830B7C62BCE145CFC6D1AC758F722E047224BA2C

verified_sources/ 和 verified_SHA256.csv 保存本次验证源码快照及校验清单。
原有三份 bit 文件均已与修改前备份核对，哈希未改变。尚未下载到开发板，故障是否消除仍待实板对照。
## 实板反馈与后续诊断（2026-10-31）

用户报告本手动启动 bit 在按住 S0 下载时，仍报 startup LOW，随后目标失去器件识别。因此该版本没有消除故障，不能认为自动复位或 CPU 提前执行已经被证实为根因。

已对本地实际 bit 文件的配置包作只读解析：成功 LED 与手动版的 IDCODE=0362D093、COR0=02003FE5、COR1=00000000，未发现这些字段的错配。压缩、配置帧内容及版本标记等仍有差异；这不是对所有配置内容或传输可靠性的证明。解析结果在 diagnostics/board_document_review/bitstream_options.json。

scripts/diagnose_program.tcl 仅供用户在已识别 xc7a35t_0、JTAG 为 125kHz 的 GUI 会话中手动 source。它一次性跳过自动 EOS 检查以便读取配置状态，保留 CRC/EOS/DONE 等原始数据及版本标记。该选项仅用于诊断，命令返回正常不能当作成功；不得据此取消最终启动验证。脚本不自动重连，且本机没有执行硬件编程。日志保存到 diagnostics/program_probe_时间戳.txt。