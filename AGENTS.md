# AGENTS.md — 接手说明（给下一位 AI / 协作者）

本仓库是「系统硬件综合设计」课程的 ARM A32 五级流水线 CPU 工程，EGO1 开发板（xc7a35tcsg324-1）。

**先读这个文件，再读 `HANDOVER.md`，然后再动手。** 本文件只讲“怎么在这个仓库里安全地干活”。

---

## 1. 目录

```
D:\Code\Vivado\
├─ ego1_arm_pipeline_24\    已验证的 24 条指令五级流水线（上过板，不要改）
├─ ego1_arm_showcase\       演示版（本次改版对象：2/3 页、小样本、页灯）
├─ ego1_arm_pipeline\       旧的 21 条版本
├─ exp2_… exp7_…\           课程实验（与本题无关，可忽略）
└─ ego1_cpu\ ego1_single_cycle\ …   早期单周期/中间版本（历史留档）
```

**当前活跃的只有两个**：`ego1_arm_pipeline_24`（CPU 本体，冻结）和 `ego1_arm_showcase`（演示层）。

## 2. 铁律

1. **不要手改生成文件**。`ego1_arm_showcase/rtl/arm_showcase_rom.v`、`rtl/showcase_catalog.v`、`sim/showcase_lanes.vh`、`programs/showcase_card.md`、`programs/showcase_reference.json` 全部由 `scripts/build_showcase.py` 生成。要改就改生成器，然后重跑。
2. **不要动 `ego1_arm_pipeline_24` 的 RTL / 约束 / bit**。它已实板验证，SHA256 绑定了上板记录。
3. 改完必须过四道门：生成 → 行为仿真 → 综合实现（DRC 0、slack>0、无未约束端点）→ 出 bit。任何一道不过就不要往下走。
4. 不要用 `create_project -force` 覆盖正在被 Vivado GUI 打开的工程目录（会把 `.xpr` 删掉然后失败，已踩过一次）。

## 3. 环境

| 工具 | 路径 / 版本 |
|---|---|
| Vivado | `D:\develop\AMDDesignTools\2025.2\Vivado\bin\vivado.bat`（2025.2） |
| Python | `py`（3.13） |
| ARM 汇编器 | `D:/develop/anaconda3/Library/bin/clang.exe`（14.0.6，`-target armv7-none-eabi`） |
| 器件 | `xc7a35tcsg324-1`，板级 100 MHz，CPU 1 MHz（100 分频） |

## 4. 标准流程

```powershell
cd D:\Code\Vivado\ego1_arm_showcase
$env:PYTHONUTF8='1'                       # 必须，否则生成的中文文件是 GBK
py scripts\build_showcase.py              # 程序 + ROM + 目录 + 期望值 + 卡片

$env:TEMP\... vivado:
& 'D:\develop\AMDDesignTools\2025.2\Vivado\bin\vivado.bat' -mode batch -source scripts\build_all.tcl
```

`build_all.tcl` 会在仓库根目录重建工程、跑仿真、综合实现、出 bit 到 `download/`。
只想快速验仿真：`scripts/sim_only.tcl`（工程建在 `%TEMP%`，不碰仓库）。

判定成功的标志：

- 仿真日志出现 `SHOWCASE TESTS PASSED: <n>` 且没有 `Fatal:`
- `SHOWCASE BUILD PASSED setup=<正数> hold=<正数>`

## 5. 已知坑

| 现象 | 原因 / 处理 |
|---|---|
| 综合报 `Failed to remove the directory '*.runs'` | Vivado GUI 还开着占着目录。关掉 Vivado 再跑。 |
| 生成的中文文档乱码 | 忘了 `$env:PYTHONUTF8='1'` |
| 用 PowerShell `Set-Content -Encoding UTF8` 改 `.v` 后综合报 `non-printable character 0xef` | PowerShell 5.1 会写 UTF-8 **BOM**，Verilog 编译器不认。改用 `[IO.File]::WriteAllText($p,$t,(New-Object System.Text.UTF8Encoding($false)))` |
| `illegal use of 'x' or 'z' in decimal number` | 数字后紧跟 `?`（如 `2'd0?x`）会让这个版本的 xvlog 误判，写成 `2'd0 ? x` |
| 页数/数值对不上 | 先看 `programs/showcase_card.md` 与 `programs/showcase_reference.json`，那是唯一真值 |

## 6. 设计约束（已定稿，不要擅自改）

- 显示：`[2 位编号][6 位内容]`，十进制六位补零、负数带 `-`，地址/PC 用十六进制六位。
- 每条指令 2 或 3 页，**最后一页永远是结果**。
- 24 条顺序按「上一条输出喂下一条」排，尾数为 7 的闭环（见 README）。
- 页灯 D6/D7/D8 独热表示第 1/2/3 页；D1–D5 是编号二进制。
- 7 段数码管**没有 M 字形**，所以不要用助记符代替编号。

## 7. 现在最该做的事

见 `HANDOVER.md` 的「待办」：**上板确认**（板子当时被拔掉了，bit 只在仿真与时序上验证过）。
