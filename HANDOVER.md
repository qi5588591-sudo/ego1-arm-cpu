# 交接说明（HANDOVER）

> 面向"下一次接手的人或 AI"。技术操作细节见 `AGENTS.md`，工程参数见 `ego1_arm_showcase/README.md`。

## 一句话状态

CPU 本体（24 条 ARM A32 指令、五级流水、含乘除）与演示层（两/三页 + 小样本 + 页灯）均已通过本机验证与实板确认（2026-11-01）。

## 已完成

| 项 | 状态 | 位置 |
|---|---|---|
| CPU：24 类指令、冒险处理、MDU 乘除 | 完成，上过板 | `ego1_arm_pipeline_24/` |
| 演示程序：24 条小样本、每条自检、通过协议 | 完成 | `ego1_arm_showcase/programs/` |
| 显示：2 位编号 + 6 位内容、2/3 页、十进制/负数/标志 | 完成 | `ego1_arm_showcase/rtl/` |
| 页灯 D6/D7/D8 独热 | 完成 | `ego1_arm_showcase/rtl/ego1_arm_showcase_top.v` |
| 行为仿真 | 604 项通过 | `ego1_arm_showcase/reports/simulation.log` |
| 综合实现 + bit | 完成，DRC 0，setup 7.489 ns / hold 0.063 ns | `ego1_arm_showcase/download/ego1_arm_showcase.bit` |
| 打印对照卡 | 完成 | `ego1_arm_showcase/programs/showcase_card.md` |

## 上板确认（2026-11-01 通过）

改版完成后已在实物上核对，用户确认通过。下面保留为下次改版的回归清单：

1. 下载 bit，上电自动运行；D13 亮、D16 心跳。
2. 数码管**左右方向**：`01` 必须显示在最左两位。若左右颠倒，改 `constraints/ego1_showcase.xdc` 或显示扫描顺序。
3. 01 停住：D1 亮（编号 1）、D6 亮（第 1 页），显示 `01 000007`。
4. 按 S2：D6 灭、D7 亮，内容是第 2 页；ADD（03）应能翻到第 3 页、D8 亮。
5. 每条按到最后一页，D15 常亮、D14 灭；D13 表示 24 类收齐。
6. S4 重跑、S0 复位。

若某条数值与 `programs/showcase_card.md` 不符：先看 D14。D14 亮说明 CPU 结果与参考模型不一致，是真问题；记下编号与页码，对照 `programs/showcase_reference.json` 里的退休轨迹定位。

## 复现 / 重建

```powershell
cd D:\Code\Vivado\ego1_arm_showcase
$env:PYTHONUTF8='1'
py scripts\build_showcase.py
& 'D:\develop\AMDDesignTools\2025.2\Vivado\bin\vivado.bat' -mode batch -source scripts\build_all.tcl
```

约 4～5 分钟；产物 bit 复制到 `download/`。旧版 bit 备份为 `download/ego1_arm_showcase_v1.bit`（SHA256 `868A05CD…`），可随时退回。

## 关键设计决策（以及为什么）

1. **为什么另开 `ego1_arm_showcase` 而不是改 `ego1_arm_pipeline_24`**：后者实板验证过、bit 的 SHA256 绑定了上板记录；改它等于作废已有验证。
2. **为什么每条 2 或 3 页，而不是固定 4 页**：4 页会对一元运算、访存指令产生空页；按"这条指令有几个数"决定页数，最后一页永远是结果。
3. **为什么用两位编号而不是助记符**：7 段数码管没有 M 字形，`MOV/MUL/MVN/CMN` 只能显示成 `HOV/HUL`，答辩时会被追问。编号 + 打印卡片更稳。
4. **为什么 STRB 的样本是 274**：274 只写最低字节得 18，与 22 号 MUL 的 18 呼应，串起"内存"和"运算"两条线。
5. **为什么期望值全部由脚本生成**：改程序会同时改 PC、机器码、期望值、对照卡；手改目录表迟早对不上。

## 24 条顺序（演示脚本）

01 MOV → 02 ADD(7+5=12) → 03 SUB(12−5=7) → 04 RSB → 05 ADC → 06 SBC → 07–10 逻辑(6,3) → 11 MVN(~7=−8) → 12 CMP → 13 CMN → 14 TST → 15 STR → 16 LDR → 17 STRB(274→18) → 18 LDRB → 19 B → 20 BL → 21 BX → 22 MUL(6×3=18) → 23 SDIV(−7÷3=−2) → 24 UDIV(21÷3=7)。

三处呼应：02 的 12 由 15/16 落盘读回；17 的 18 与 22 的乘积相同；24 回到 01 的 7。

## 可选后续方向

- 课程报告（目前仓库里只有工程文档，没有面向课程的设计报告）。
- 若被追问性能：CPU 跑 1 MHz，而逻辑能跑 ~260 MHz，瓶颈在分频；MDU 是 33 拍固定停顿、DSP 用量 0。
- 若要扩展指令：`MLA`、长乘、LoongArch 版本都还没做；现架构是 ARMv7-A 的 A32 子集 + idiv 扩展。

## 风险

- 保持时间裕量只有 0.063 ns，能过但很紧；换板、换温度或重跑布线都可能翻车。
- 显示格式改过一轮，若老师/助教按旧版（8 页）的说明来看，需要先解释。
- 仓库不含 bit 的 CI 验证；bit 是手动跑脚本产出的。
