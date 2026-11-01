# EGO1单周期CPU上板指南

本阶段将已通过仿真的15指令单周期CPU放入EGO1板级顶层，使用板载100MHz输入产生10MHz CPU时钟，并用三盏LED显示程序通过、时钟运行和故障。程序依旧计算7+5及1至5之和，沿用已验证的指令ROM与CPU数据通路。

当前软件阶段验证包括板级行为仿真与FPGA实现；真实EGO1的下载和灯号需要在实物上观察确认。

本次2026年10月27日构建已通过28项板级仿真检查，完成布局布线及Bitstream生成。10MHz CPU时钟下，最差建立裕量为71.057ns，最差保持裕量为0.160ns，最差脉宽裕量为3.000ns；建立、保持和脉宽失败端点均为0，内部未约束端点为0，布线后DRC违规为0。人眼观察的三个LED输出按本指南说明设置了时序例外。

## 工程与文件

Vivado工程：`D:/Code/Vivado/ego1_cpu/board_project/ego1_single_cycle_board.xpr`。

通过时序检查后，构建脚本会将下载文件复制到：

```text
D:/Code/Vivado/ego1_cpu/validation/ego1_single_cycle_board_verified.bit
```

这个verified名称表示构建脚本检查过当前布局布线的建立和保持时序，不代表已经验证过真实开发板。

## 在Vivado中下载

1. 当前仿真仍打开时，在底部Tcl Console输入 `close_sim`。
2. File → Open Project，打开上述板级工程。
3. 给EGO1供电，并通过USB-UART/JTAG端口连接电脑。
4. 点击Open Hardware Manager → Open Target。当前板卡在250kHz JTAG频率下已成功识别，按下方低速连接步骤打开目标。
5. 在xc7a35t_0器件上右键，选择Program Device。
6. 在Bitstream file中选择上面的verified.bit文件，Debug probes file留空。
7. 点击Program，观察下面三盏LED。

板级工程中已包含RTL和XDC引脚约束，生成好的文件可以直接下载。后续修改代码时，需要重新生成Bitstream；旧的verified副本不会自动跟随GUI编译更新。

本次使用JTAG配置，断电后需要重新下载。暂不进行SPI Flash固化。

## 正常灯号

| FPGA引脚 | 板上标识 | 功能 | 正常运行 |
| --- | --- | --- | --- |
| K3 | 用户已确认是D16（K3） | 程序通过 | 常亮 |
| M1 | D15（用户实物照片确认） | 时钟运行 | 亮0.5秒、灭0.5秒 |
| L1 | D14（用户实物照片确认） | 故障 | 熄灭 |

用户提供的实物照片确认了K3/M1/L1与D16/D15/D14的对应关系。

通过灯并非直接绑成常亮。CPU必须在本次运行中向数据地址8提交通过标志1，同时数据地址0的观察值为12、地址4的观察值为15，且CPU无故障，才会锁存点亮D16。

程序完成后仍执行终点自循环；运行灯继续闪烁是正常现象，不代表程序还在反复计算结果。

## 按键重新运行

复位使用接FPGA引脚R11的通用按键，即手册PB0/S0，按下为高电平。

在用户实物照片中，S0（R11）是右下方五个通用按键里，中间一排最右侧的按键。

1. 按住该键，三个指示灯均应熄灭。
2. 松开后，时钟重新锁定，CPU从PC=0重新执行。
3. D16重新常亮，M1灯恢复闪烁，L1故障灯保持熄灭。

CPU计算只需要微秒级时间，因此松手后的通过灯通常会很快亮起。数据RAM虽然在CPU复位时保留原值，但板级逻辑会清除上次的通过状态，并等待新的提交事件，旧的内存标志本身不能使D16提前通过。

## 时钟与复位结构

- P17输入为100MHz，XDC中约束为10ns周期。
- Artix-7 MMCM设置为输入乘6、输出除60，产生10MHz CPU时钟，VCO为600MHz。
- MMCM反馈及CPU时钟都使用BUFG专用时钟缓冲。
- R11按键直接接MMCM异步复位输入，使用该原语支持的异步复位机制。
- 时钟未锁定时，复位同步器异步进入复位状态；锁定后经两个CPU时钟上升沿释放复位。
- 失锁或复位期间，LED输出被屏蔽，避免CPU时钟停止后显示旧的通过状态。
- 运行灯计数器每500万个10MHz时钟翻转一次，半周期0.5秒。

10MHz是本阶段实际使用并进行时序检查的频率。不能把100MHz板载晶振频率当成CPU运行频率。

## 约束与时序范围

所有板级端口都具有PACKAGE_PIN和LVCMOS33约束。配置电压设置为3.3V，CFGBVS为VCCO。

异步按键到MMCM复位的路径不按同步数据路径分析；人眼观察的LED输出没有外部采样时钟，因此这些输出端点不作外部同步接口的时序要求。CPU内部、生成时钟、寄存器和存储器路径仍参与时序分析。

完整报告位于 `D:/Code/Vivado/ego1_cpu/validation/`：

| 文件 | 内容 |
| --- | --- |
| board_simulation.log | 板级仿真结果 |
| board_timing_summary.rpt | 布局布线后的建立、保持、脉宽与未约束路径报告 |
| board_drc.rpt | 实现后的设计规则检查 |
| board_cdc.rpt | 时钟域与同步器检查 |
| board_utilization.rpt | FPGA资源使用 |
| board_build_result.txt | 构建脚本确认的时钟及最差时序裕量 |

## 板级仿真

仿真顶层为tb_ego1_single_cycle_board。它使用Vivado提供的真实MMCM原语模型，没有用理想10MHz时钟替代时钟生成逻辑。仿真中仅将运行灯的计数分频缩短，以便快速观察。

测试检查实际CPU时钟周期、程序结果与通过灯、运行灯分频、按住按键的复位效果、松手重跑、旧RAM标志不误报，以及注入故障后的故障灯锁存和再次复位恢复。

预期输出：

```text
BOARD TESTS PASSED: 28 checks; actual MMCM model; CPU 10MHz
```

## 如何判读异常

### 本板已验证的低速JTAG连接

2026年10月27日排查记录：Windows识别到FTDI双通道接口；15MHz及1MHz扫描未发现FPGA；250kHz扫描成功返回xc7a35t_0（PART=xc7a35t）。这是已验证可用的扫描条件，尚不能据此确定高速失败的具体电气原因。

在当前Vivado已连接localhost:3121的Hardware Manager底部执行：

```tcl
catch {close_hw_target}
current_hw_target [get_hw_targets */xilinx_tcf/Xilinx/1234-tulA]
set_property PARAM.FREQUENCY 250000 [current_hw_target]
open_hw_target
get_hw_devices
```

预期最后返回xc7a35t_0。该步骤读取器件并建立连接，不下载配置。随后再选择本阶段的Bitstream并Program Device。重新Auto Connect可能恢复默认扫描设置，遇到同类扫描问题时可重新执行上述命令。

| 现象 | 首先检查 |
| --- | --- |
| 三灯均不亮 | 是否下载了本阶段文件、是否供电、R11按键是否一直按下 |
| M1闪烁但D16不亮、L1亮 | 程序或结果检查出现故障，保留现象并检查当前代码与下载文件 |
| D16亮且M1闪烁、L1灭 | 符合本阶段预期 |
| 灯号位置与表格不一致 | 按括号内的K3/M1/L1辨认并核对对应XDC |

## 新增文件

| 文件 | 作用 |
| --- | --- |
| rtl/ego1_clock.v | Artix-7 MMCM与BUFG时钟生成 |
| rtl/ego1_single_cycle_board.v | 复位同步、CPU实例、结果判定与LED |
| constraints/ego1_single_cycle_board.xdc | 时钟、按键、LED、配置电压和时序例外 |
| sim/tb_ego1_single_cycle_board.sv | 板级时钟、复位、程序和指示灯测试 |
| scripts/create_board_project.tcl | 创建独立板级工程 |
| scripts/run_board_sim.tcl | 自动运行并检查板级仿真 |
| scripts/build_board_bitstream.tcl | 实现、检查建立和保持时序、生成已检查的下载文件 |

确认实物灯号与复位重跑后，再进行数码管结果显示和流水线扩展。当前仍是15指令单周期CPU，不是第4题的最终流水线成果。

## 依据

- EGO1用户手册，板载时钟、通用按键及LED引脚： https://e-elements.readthedocs.io/zh/ego1_v2.2/EGo1.html
- AMD 7系列MMCM原语说明： https://docs.amd.com/r/en-US/ug953-vivado-7series-libraries/MMCME2_BASE
