"""Generate the simplified showcase demo: 24 instructions, small operands,
2 or 3 display pages each, two-digit case number plus six-digit value.

Program, machine code and expected values come from the verified LLVM
assembler + mnemonic reference model in ego1_arm_pipeline_24/scripts.
"""
from pathlib import Path
import importlib.util, json

SHOW = Path(__file__).resolve().parents[1]
BASE = SHOW.parent / 'ego1_arm_pipeline_24' / 'scripts' / 'build_programs.py'
spec = importlib.util.spec_from_file_location('bp', BASE)
bp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bp)
bp.ROOT = SHOW

SEG = {0:0x3f,1:0x06,2:0x5b,3:0x4f,4:0x66,5:0x6d,6:0x7d,7:0x07,8:0x7f,9:0x6f,
       10:0x77,11:0x7c,12:0x39,13:0x5e,14:0x79,15:0x71}
MINUS = 0x40
TRACE_FIELD = {'wdata': 'wdata', 'mem': 'mem_wdata', 'next': 'next_pc',
               'pc': 'pc', 'flags': 'nzcv'}

def s32(v):
    v &= 0xffffffff
    return v - (1 << 32) if v >= 0x80000000 else v

def dec6(v):
    n = s32(v)
    if n < 0:
        return '-' + f"{-n:05d}"[:5]
    return f"{n:06d}"[-6:]

def hex6(v):
    return f"{v & 0xffffff:06X}"

def flags6(v):
    return '00' + ''.join(str((v >> b) & 1) for b in (3, 2, 1, 0))

FMT = {'dec': dec6, 'hex': hex6, 'flags': flags6}

def lanes(case_no, chars6):
    txt = f"{case_no:02d}" + chars6
    assert len(txt) == 8, txt
    word = 0
    for i, ch in enumerate(txt):
        code = MINUS if ch == '-' else SEG[int(ch, 16)]
        word |= code << (8 * (7 - i))
    return word

P = bp.Program()
P.constant(10, 0x1000)                 # r10 = data base 0x1000
sample_pc = []

def sample(build):
    pc = len(P.items) * 4
    build()
    assert len(P.items) * 4 == pc + 4
    sample_pc.append(pc)

# 01 MOV -------------------------------------------------------------------
sample(lambda: P.dp('mov', 5, imm=7));                     P.check(5, 7)
# 02 ADD 7+5 ---------------------------------------------------------------
P.dp('mov', 0, imm=7); sample(lambda: P.dp('add', 5, 0, imm=5)); P.check(5, 12)
# 03 SUB 12-5 --------------------------------------------------------------
P.dp('mov', 0, imm=12); sample(lambda: P.dp('sub', 5, 0, imm=5)); P.check(5, 7)
# 04 RSB 20-7 --------------------------------------------------------------
P.dp('mov', 0, imm=7); sample(lambda: P.dp('rsb', 5, 0, imm=20)); P.check(5, 13)
# 05 ADC 7+5+1 -------------------------------------------------------------
P.dp('mov', 0, imm=7); P.dp('cmp', rn=0, rm=0)
sample(lambda: P.dp('adc', 5, 0, imm=5)); P.check(5, 13)
# 06 SBC 7-2-1 -------------------------------------------------------------
P.dp('mov', 0, imm=7); P.dp('mov', 1, imm=9); P.dp('cmp', rn=0, rm=1)
sample(lambda: P.dp('sbc', 5, 0, imm=2)); P.check(5, 4)
# 07-10 logic on 6 and 3 ---------------------------------------------------
P.dp('mov', 6, imm=6); P.dp('mov', 7, imm=3)
for op, expect in [('and', 2), ('orr', 7), ('eor', 5), ('bic', 4)]:
    sample(lambda o=op: P.dp(o, 5, 6, rm=7)); P.check(5, expect)
# 11 MVN ~7 = -8 -----------------------------------------------------------
sample(lambda: P.dp('mvn', 5, imm=7)); P.check(5, (-8) & 0xffffffff)
# 12 CMP 7 vs 7 ------------------------------------------------------------
P.dp('mov', 0, imm=7); sample(lambda: P.dp('cmp', rn=0, rm=0))
# 13 CMN -1+1 --------------------------------------------------------------
P.dp('mvn', 6, imm=0); sample(lambda: P.dp('cmn', rn=6, imm=1))
# 14 TST 6&2 ---------------------------------------------------------------
P.dp('mov', 6, imm=6); sample(lambda: P.dp('tst', rn=6, imm=2))
# 15 STR 12 ----------------------------------------------------------------
P.dp('mov', 2, imm=12); sample(lambda: P.mem('str', 2))
# 16 LDR -------------------------------------------------------------------
sample(lambda: P.mem('ldr', 3)); P.check(3, 12)
# 17 STRB 274 -> low byte 18 -----------------------------------------------
P.constant(6, 274); sample(lambda: P.mem('strb', 6, 16))
# 18 LDRB ------------------------------------------------------------------
sample(lambda: P.mem('ldrb', 4, 16)); P.check(4, 18)
# 19 B ---------------------------------------------------------------------
sample(lambda: P.branch('b_here'))
P.dp('mov',0,imm=0x11); P.dp('mov',0,imm=0x22); P.label('b_here')
# 20 BL / 21 BX ------------------------------------------------------------
ret_pc = (len(P.items) + 1) * 4
sample(lambda: P.branch('sub1', link=True)); P.check(14, ret_pc)
# 22 MUL 6*3 ---------------------------------------------------------------
P.dp('mov', 6, imm=6); P.dp('mov', 7, imm=3)
sample(lambda: P.mdu('mul', 5, 6, 7)); P.check(5, 18)
# 23 SDIV -7/3 -------------------------------------------------------------
P.constant(6, (-7) & 0xffffffff); P.dp('mov', 7, imm=3)
sample(lambda: P.mdu('sdiv', 5, 6, 7)); P.check(5, (-2) & 0xffffffff)
# 24 UDIV 21/3 -------------------------------------------------------------
P.dp('mov', 6, imm=21); P.dp('mov', 7, imm=3)
sample(lambda: P.mdu('udiv', 5, 6, 7)); P.check(5, 7)
# pass protocol ------------------------------------------------------------
P.dp('mov', 1, imm=15); P.mem('str', 1, 4)
P.dp('mov', 0, imm=1); P.mem('str', 0, 8)
P.label('finish'); P.branch('finish')
P.label('fail'); P.dp('mov', 0, imm=0xee); P.mem('str', 0, 8)
P.label('fail_halt'); P.branch('fail_halt')
P.label('sub1'); sample(lambda: P.bx(14))
assert len(sample_pc)==24, len(sample_pc)
sample_pc = sample_pc[:20] + [sample_pc[23], sample_pc[20], sample_pc[21], sample_pc[22]]

words = bp.assemble(P, 'showcase')
traces, coverage, memory = bp.reference(P, words)
assert len(coverage) == 24, sorted(coverage)
assert [int.from_bytes(memory[i:i + 4], 'little') for i in (0, 4, 8)] == [12, 15, 1]
by_pc = {t['pc']: t for t in traces}

# page spec: ('lit', v[, fmt]) or ('trace', field[, fmt])
def L(v, f='dec'): return ('lit', v, f)
def T(f, fmt='dec'): return ('trace', f, fmt)

PAGES = [
    [L(7), T('wdata')],                                        # 01 MOV
    [L(7), L(5), T('wdata')],                                  # 02 ADD
    [L(12), L(5), T('wdata')],                                 # 03 SUB
    [L(20), L(7), T('wdata')],                                 # 04 RSB
    [L(7), L(5), T('wdata')],                                  # 05 ADC
    [L(7), L(2), T('wdata')],                                  # 06 SBC
    [L(6), L(3), T('wdata')],                                  # 07 AND
    [L(6), L(3), T('wdata')],                                  # 08 ORR
    [L(6), L(3), T('wdata')],                                  # 09 EOR
    [L(6), L(3), T('wdata')],                                  # 10 BIC
    [L(7), T('wdata')],                                        # 11 MVN
    [L(7), L(7), T('flags', 'flags')],                         # 12 CMP
    [L(-1), L(1), T('flags', 'flags')],                        # 13 CMN
    [L(6), L(2), T('flags', 'flags')],                         # 14 TST
    [L(0x1000, 'hex'), T('mem')],                              # 15 STR
    [L(0x1000, 'hex'), T('wdata')],                            # 16 LDR
    [L(0x1010, 'hex'), T('mem')],                              # 17 STRB
    [L(0x1010, 'hex'), T('wdata')],                            # 18 LDRB
    [T('pc', 'hex'), T('next', 'hex')],                        # 19 B
    [T('pc', 'hex'), T('next', 'hex'), T('wdata', 'hex')],     # 20 BL
    [T('pc', 'hex'), T('next', 'hex')],                        # 21 BX
    [L(6), L(3), T('wdata')],                                  # 22 MUL
    [L(-7), L(3), T('wdata')],                                 # 23 SDIV
    [L(21), L(3), T('wdata')],                                 # 24 UDIV
]
NAMES = [('MOV', '传送'), ('ADD', '加法'), ('SUB', '减法'), ('RSB', '反向减法'),
         ('ADC', '带进位加'), ('SBC', '带借位减'), ('AND', '按位与'), ('ORR', '按位或'),
         ('EOR', '按位异或'), ('BIC', '按位清除'), ('MVN', '按位取反'), ('CMP', '比较'),
         ('CMN', '相加比标志'), ('TST', '位测试'), ('STR', '写内存'), ('LDR', '读内存'),
         ('STRB', '写字节'), ('LDRB', '读字节'), ('B', '分支'), ('BL', '调用'),
         ('BX', '寄存器跳转'), ('MUL', '乘法'), ('SDIV', '有符号除'), ('UDIV', '无符号除')]

TRACE_KIND = {('wdata','dec'):1, ('wdata','hex'):5, ('mem','dec'):2, ('mem','hex'):2, ('next','hex'):3, ('next','dec'):3, ('pc','hex'):6, ('pc','dec'):6, ('flags','flags'):4}
entries = []
for idx, (pages, (mne, cn)) in enumerate(zip(PAGES, NAMES)):
    t = by_pc[sample_pc[idx]]
    page_desc, text = [], []
    for pg in pages:
        fmt = pg[2] if len(pg) > 2 else 'dec'
        if pg[0] == 'lit':
            page_desc.append(0)
            text.append(FMT[fmt](pg[1]))
        else:
            page_desc.append(TRACE_KIND[(pg[1], fmt)])
            text.append(FMT[fmt](t[TRACE_FIELD[pg[1]]]))
    entries.append(dict(index=idx, mnemonic=mne, cn=cn, pc=sample_pc[idx],
                        ins=t['instruction'], next=t['next_pc'], addr=t['mem_addr'],
                        flags=t['nzcv'], value=t['wdata'], mem=t['mem_wdata'],
                        pages=page_desc, texts=text, num_lanes=(SEG[(idx+1)//10]<<56)|(SEG[(idx+1)%10]<<48),
                        lanes=[lanes(idx + 1, s) for s in text]))

# ---- ROM ----------------------------------------------------------------
cases = ''.join(f"            32'h{i*4:08x}: instruction=32'h{w:08x};\n" for i, w in enumerate(words))
(SHOW / 'rtl' / 'arm_showcase_rom.v').write_text(
    '`timescale 1ns/1ps\nmodule arm_showcase_rom(input wire [31:0] address, output reg [31:0] instruction,'
    'output reg valid);\n    always @* begin\n        valid=1; instruction=0;\n        case(address)\n'
    + cases + '            default: begin valid=0; instruction=0; end\n        endcase\n    end\nendmodule\n')

# ---- catalog ------------------------------------------------------------
pc_case = ''.join(f" 32'h{e['pc']:08x}:begin found=1;record_index=5'd{e['index']};end\n" for e in entries)

def kind_of(e, p):
    return e['pages'][p] if p < len(e['pages']) else 0

def static_of(e, p):
    return e['lanes'][p] if p < len(e['pages']) and e['pages'][p] == 0 else 0

mk = ''
for e in entries:
    mk += (f" 5'd{e['index']}:begin npages=1'b{1 if len(e['pages']) == 3 else 0};"
           f"p0_kind=3'd{kind_of(e,0)};p1_kind=3'd{kind_of(e,1)};p2_kind=3'd{kind_of(e,2)};"
           f"p0_lanes=64'h{static_of(e,0):016x};p1_lanes=64'h{static_of(e,1):016x};"
           f"p2_lanes=64'h{static_of(e,2):016x};num_lanes=64'h{e['num_lanes']:016x};"
           f"expected_ins=32'h{e['ins']:08x};expected_value=32'h{e['value']:08x};"
           f"expected_mem=32'h{e['mem']:08x};expected_next=32'h{e['next']:08x};"
           f"expected_flags=4'h{e['flags']:x};end\n")

(SHOW / 'rtl' / 'showcase_catalog.v').write_text(
    'module showcase_catalog(input wire [4:0] selected,input wire[31:0] trace_pc,\n'
    ' output reg found,output reg[4:0] record_index,\n'
    ' output reg npages,output reg[2:0] p0_kind,p1_kind,p2_kind,\n'
    ' output reg[63:0] p0_lanes,p1_lanes,p2_lanes,num_lanes,\n'
    ' output reg[31:0] expected_ins,expected_value,expected_mem,expected_next,\n'
    ' output reg[3:0] expected_flags);\n'
    ' always @* begin found=0;record_index=0;case(trace_pc)\n' + pc_case +
    ' default:begin end endcase end\n'
    ' always @* begin npages=0;p0_kind=0;p1_kind=0;p2_kind=0;p0_lanes=0;p1_lanes=0;p2_lanes=0;num_lanes=0;'
    'expected_ins=0;expected_value=0;expected_mem=0;expected_next=0;expected_flags=0;case(selected)\n'
    + mk + ' default:begin end endcase end\nendmodule\n')

# ---- tb expectations ----------------------------------------------------
vh = 'function [63:0] exp_lane(input integer idx,input integer page);\n  case(idx*4+page)\n'
for e in entries:
    for p, word in enumerate(e['lanes']):
        vh += f"    8'd{e['index']*4+p}: exp_lane = 64'h{word:016x};\n"
vh += "    default: exp_lane = 64'h0;\n  endcase\nendfunction\n"
vh += 'function integer exp_pages(input integer idx);\n  case(idx)\n'
for e in entries:
    vh += f"    {e['index']}: exp_pages = {len(e['pages'])};\n"
vh += "    default: exp_pages = 2;\n  endcase\nendfunction\n"
(SHOW / 'sim' / 'showcase_lanes.vh').write_text(vh)

# ---- printed card -------------------------------------------------------
card = ['# 演示对照卡（24 条，按演示顺序）\n',
        '| 编号 | 指令 | 中文 | 页 1 | 页 2 | 页 3 |', '|---:|---|---|---|---|---|']
for e in entries:
    cols = e['texts'] + ['—'] * (3 - len(e['texts']))
    card.append(f"| {e['index']+1:02d} | {e['mnemonic']} | {e['cn']} | "
                + ' | '.join(f'`{c}`' for c in cols) + ' |')
(SHOW / 'programs' / 'showcase_card.md').write_text('\n'.join(card) + '\n')
(SHOW / 'programs' / 'showcase_reference.json').write_text(
    json.dumps(dict(coverage=sorted(coverage), entries=entries, traces=traces), indent=2))
(SHOW / 'programs' / 'showcase_listing.txt').write_text(
    '\n'.join(f'{i*4:08x}  {w:08x}  {P.items[i]}' for i, w in enumerate(words)) + '\n')

for e in entries:
    print(f"{e['index']+1:02d} {e['mnemonic']:<5} {e['cn']:<6} pc={e['pc']:03x} "
          f"ins={e['ins']:08x} pages={len(e['pages'])} "
          + ' | '.join(e['texts']))
print(f'showcase: {len(words)} words, {len(traces)} retired, {len(coverage)} kinds')










