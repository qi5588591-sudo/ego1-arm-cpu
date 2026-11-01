# EGO1 ARM A32 五级流水线 CPU：演示版（两/三页）

独立工程 `D:/Code/Vivado/ego1_arm_showcase`。CPU、MDU、ALU、译码、寄存器堆、RAM 与已验证的 24 条版本相同，本工程只做演示层：更小的样本、更少的页、按指令类别定制页面。

已验证的 `ego1_arm_pipeline_24` 未改动。

## 显示：两位编号 + 六位内容

```
03 000012      ← 第 03 类（加法），结果 12
```

- 一页只放一个数，每类指令 2 或 3 页，最后一页永远是结果。
- 算术/逻辑/乘除：操作数 A → 操作数 B → 结果
- 比较类：操作数 A → 操作数 B → NZCV
- 访存类：地址 → 数据
- 分支类：源 PC → 目标（BL 多一页返回地址）
- 十进制六位零填充，负数带减号（`-00008`）；地址与 PC 用十六进制六位。

| 按键 | 作用 |
|---|---|
| S1 / S3 | 下一类 / 上一类 |
| S2 | 下一页（2 页或 3 页循环） |
| S4 | 重新运行程序并重新采集 |
| S0 | 复位 CPU 与界面 |

| 灯 | 含义 |
|---|---|
| D1～D5 | 当前指令编号的二进制（D1 最低位） |
| D6 | 亮 = 停在第 1 页 |
| D7 | 亮 = 停在第 2 页 |
| D8 | 亮 = 停在第 3 页 |
| D13 | 24 类记录齐全 |
| D14 | 出错 |
| D15 | 当前记录与参考模型一致 |
| D16 | 独立心跳 |

D6/D7/D8 是三选一的“页灯”，翻页时亮的灯换位置。

## 24 条顺序（按“上一条的输出喂给下一条”排）

| 编号 | 指令 | 演示 | 编号 | 指令 | 演示 |
|---:|---|---|---:|---|---|
| 01 | MOV | 7 | 13 | CMN | −1+1 |
| 02 | ADD | 7+5=12 | 14 | TST | 6 & 2 |
| 03 | SUB | 12−5=7 | 15 | STR | 12 → 0x1000 |
| 04 | RSB | 20−7=13 | 16 | LDR | ← 12 |
| 05 | ADC | 7+5+1=13 | 17 | STRB | 274 → 低字节 18 |
| 06 | SBC | 7−2−1=4 | 18 | LDRB | ← 18 |
| 07 | AND | 6 & 3=2 | 19 | B | 跳到 000144 |
| 08 | ORR | 6 \| 3=7 | 20 | BL | 调用 |
| 09 | EOR | 6 ^ 3=5 | 21 | BX | 按 LR 返回 |
| 10 | BIC | 6 & ~3=4 | 22 | MUL | 6×3=18 |
| 11 | MVN | ~7=−8 | 23 | SDIV | −7÷3=−2 |
| 12 | CMP | 7 vs 7 | 24 | UDIV | 21÷3=7 |

三处呼应：02 的 12 由 15/16 落盘读回；17 写出的 18 与 22 的乘积相同；24 除完回到 01 的 7。
打印版对照卡见 `programs/showcase_card.md`。

## 生成与构建

```powershell
$env:PYTHONUTF8='1'
py scripts\build_showcase.py                                  # 程序 + ROM + 目录 + 期望值 + 卡片
D:\develop\AMDDesignTools\2025.2\Vivado\bin\vivado.bat -mode batch -source scripts\build_all.tcl
```

`build_showcase.py` 复用 `ego1_arm_pipeline_24/scripts/build_programs.py` 里的 LLVM 汇编器和 Python 助记符参考模型，所以每次改程序，机器码、PC、期望值、卡片是一起生成的，不会出现“改了程序忘了改期望”。

生成物：`rtl/arm_showcase_rom.v`、`rtl/showcase_catalog.v`、`sim/showcase_lanes.vh`、`programs/showcase_card.md`、`programs/showcase_reference.json`。

## 本机验证结果（2026-11-01）

| 项 | 结果 |
|---|---|
| 行为仿真 | 604 项检查通过（24 条记录、逐页显示、页灯、按键消抖、重跑、复位、数码管扫描） |
| 建立 / 保持裕量 | 7.489 ns / 0.063 ns，违例 0 |
| DRC | 0 |
| 未约束内部端点 | 0 |
| LUT / FF | 3680（17.69%） / 5754（13.83%） |
| DSP / BRAM | 0 / 0 |
| bit | 814755 字节，SHA256 `801F49D97E276FB6F0AFB2B5E788CCCB3B6FE04061A3210401C7F251438BD8C0` |

旧版 bit 备份在 `download/ego1_arm_showcase_v1.bit`（SHA256 `868A05CD…`），可随时退回。

## 尚未完成

**上板确认**。开发板已移除，`download/ego1_arm_showcase.bit` 还没有在实物上验证。上板后要确认：

1. 上电自动运行，D13 亮，D16 心跳。
2. 01～24 逐条切换，每条页数与卡片一致。
3. 每条最后一页与卡片数值一致（D15 常亮，D14 灭）。
4. 数码管左右方向：`01` 应显示在**最左边两位**；若左右颠倒需改 `constraints/ego1_showcase.xdc` 或显示扫描顺序。
5. S4 重跑、S0 复位。
