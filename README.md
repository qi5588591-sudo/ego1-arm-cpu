# EGO1 ARM A32 五级流水线 CPU

系统硬件综合设计课程项目：在 EGO1（xc7a35tcsg324-1）上实现一个 32 位 RISC 五级流水线 CPU，采用 ARMv7-A 的 A32 指令子集（含 A32 整数除法扩展），支持 24 类指令，含乘法与除法，能处理数据冒险、标志冒险、控制冒险与乘除忙停顿，并可在开发板上运行自检程序验证全部指令。

```
rtl  ──▶  IF / ID / EX / MEM / WB  ──▶  数据旁路、load-use 停顿、分支冲刷、MDU 33 拍停顿
程序 ──▶  LLVM ARM 汇编器  ──▶  机器码 ROM  ──▶  板上自检（写 0x1000/0x1004/0x1008 通过协议）
```

## 仓库里有什么

| 目录 | 内容 |
|---|---|
| `ego1_arm_pipeline_24/` | **CPU 本体**：24 条指令的五级流水线，已上板验证，冻结 |
| `ego1_arm_showcase/` | **演示版**：两/三页数码管展示、24 条小样本、页灯、按键交互 |
| `ego1_arm_pipeline/`、`ego1_cpu/`、`ego1_single_cycle/`、`exp*/` | 历史版本与课程实验，仅作留档 |
| `AGENTS.md` | 给接手的 AI/协作者的规则与踩坑记录 |
| `HANDOVER.md` | 现状、待办、关键决策 |

## 快速开始

```powershell
cd ego1_arm_showcase
$env:PYTHONUTF8='1'
py scripts\build_showcase.py
& '<Vivado>\bin\vivado.bat' -mode batch -source scripts\build_all.tcl
```

仿真打印 `SHOWCASE TESTS PASSED: 604`、构建打印 `SHOWCASE BUILD PASSED setup=7.489 hold=0.063` 即为通过，bit 输出到 `download/`。

## 验证记录

| 项 | 结果 |
|---|---|
| 行为仿真 | 604 项检查 |
| 建立 / 保持裕量 | 7.489 ns / 0.063 ns |
| DRC / 未约束端点 | 0 / 0 |
| LUT / FF / DSP | 3680 / 5754 / 0 |

## 当前状态

CPU 本体与演示版均已通过本机验证与实板确认（2026-11-01）。回归清单见 `HANDOVER.md`。
