# EGO1 CPU 课程设计工程

目前包含三个可单独打开的阶段：

| 阶段 | 工程 | 说明 |
| --- | --- | --- |
| 基础模块 | project/ego1_cpu.xpr | ALU与寄存器堆，277项检查 |
| 单周期CPU | single_cycle_project/ego1_single_cycle.xpr | 15条真实指令，取指、译码、执行、访存和写回 |
| EGO1单周期上板 | board_project/ego1_single_cycle_board.xpr | 10MHz时钟、复位、程序通过与故障LED |

第二阶段操作和波形说明见 [单周期CPU指南](SINGLE_CYCLE_GUIDE.md)。第三阶段下载与灯号说明见 [EGO1上板指南](EGO1_BOARD_GUIDE.md)。以下内容保留为第一阶段说明。

## 第一阶段基础模块

本阶段完成32位ALU、32个通用寄存器和两者组成的基础数据通路，供后续单周期与流水线CPU复用。采用LoongArch LA32相关规则。本阶段没有PC、机器码译码、指令存储器或完整CPU，不能把ALU操作数量计为已实现的指令数量。

工程文件：`D:/Code/Vivado/ego1_cpu/project/ego1_cpu.xpr`。

## 在Vivado中运行

1. 用 File → Open Project 打开上述工程。若Vivado询问是否关闭LED工程，可先保存后关闭。
2. Design Sources 中应有 datapath_basics、alu32 和 regfile32。Simulation Sources 中应有 tb_datapath_basics。
3. 点击 Run Simulation → Run Behavioral Simulation。工程设置为运行到测试结束。
4. Tcl Console 中应出现 `ALL TESTS PASSED: 277 checks, 39 ALU vectors`。看到 `$finish called` 是正常结束。
5. 在波形中观察 clk、reset、we、waddr、wdata、raddr1、raddr2、rdata1、rdata2、alu_op、alu_result 和 zero。数据可右键选择 Radix → Hexadecimal。
6. 如果仿真停在1000ns但尚未结束，在仿真已启动的 Tcl Console 中输入 `run all`。

本阶段只运行行为仿真，不需要连接开发板或添加引脚约束。这个顶层暴露了大量内部测试端口，不作为上板顶层，不生成Bitstream。后续会新增只连接时钟、复位和显示接口的板级顶层。

## 文件及职责

| 文件 | 作用 |
| --- | --- |
| rtl/alu32.v | 32位组合ALU，两个输入a/b，内部操作码alu_op，输出result/zero |
| rtl/regfile32.v | 32×32位寄存器堆，两路组合读、一路上升沿写 |
| rtl/datapath_basics.v | 将寄存器堆两个读端口连接到ALU |
| sim/tb_datapath_basics.sv | 自动检查结果的SystemVerilog测试平台，仅用于仿真 |
| scripts/create_project.tcl | 可复现的工程创建脚本，拒绝覆盖已有工程 |
| scripts/run_sim.tcl | 用独立Vivado批处理进程运行已有工程仿真 |

## ALU内部控制表

这些数字只是内部控制码，不是LoongArch机器指令的编码。

| alu_op | 运算 | 规则 |
| --- | --- | --- |
| 0 | ADD | a+b，保留低32位 |
| 1 | SUB | a-b，保留低32位 |
| 2 | AND | 按位与 |
| 3 | OR | 按位或 |
| 4 | XOR | 按位异或 |
| 5 | NOR | 按位或后取反 |
| 6 | SLL | 逻辑左移b[4:0]位 |
| 7 | SRL | 逻辑右移b[4:0]位，高位补0 |
| 8 | SRA | 算术右移b[4:0]位，高位补符号位 |
| 9 | SLT | 按有符号数比较，小于返回1，否则0 |
| 10 | SLTU | 按无符号数比较，小于返回1，否则0 |
| 11 | PASS_B | 直接返回b；以后LU12I.W的译码先构造{imm20,12'b0}再送入b |
| 12至15 | 保留 | 当前结果为0；以后译码器必须单独检测不支持的机器指令 |

例如FFFFFFFF按有符号数解释为-1，小于1；按无符号数解释为4294967295，大于1。80000000右移一位时，逻辑右移得到40000000，算术右移得到C0000000。

## 寄存器时序约定

- r0恒为0，写r0被忽略；其余31个寄存器可读写，地址为5位。
- reset为高电平有效、同步复位，在时钟上升沿清零全部寄存器。这是本项目便于验证而采用的初始化设计，不是LA32对所有通用寄存器复位值的要求。
- reset的优先级高于写入。we为0时寄存器保持。
- 两个读端口为组合逻辑；读地址变化后无需等待时钟即可读出数据。
- 读写同址时，上升沿之前读旧值，上升沿更新完成后读新值。当前没有写穿透旁路，后续流水线会另行处理数据转发。
- testbench在下降沿准备写入信号，在上升沿后检查结果，避免与硬件更新竞争。

## 验证范围

测试覆盖两次全寄存器复位、全部31个可写地址和双读端口、写r0、关闭写使能、时钟边沿前后同址读写、复位与写入同时发生，以及r1=7、r2=5、ALU计算后将12写回r3的组合流程。

39组ALU向量包含12种已定义操作和一个保留操作码，覆盖溢出截断、零结果、位图、0/1/31位移位、只取移位量低5位、算术右移符号扩展、有符号与无符号比较边界。

本阶段验证基础模块功能，不代表已经完成机器指令执行、乘除法、流水线冒险、上板或时序收敛。

## 后续接入顺序

PC与指令ROM → 指令译码与立即数扩展 → 单周期基础指令 → 数据RAM与自编程序 → 五级流水线和冒险控制 → 多周期乘除法 → EGO1显示和性能实验。

## 依据

- LoongArch官方手册： https://loongson.github.io/LoongArch-Documentation/LoongArch-Vol1-EN.html
- AMD Vivado行为仿真操作： https://docs.amd.com/r/2025.1-English/ug888-vivado-design-flows-overview-tutorial/Step-5-Running-Behavioral-Simulation
