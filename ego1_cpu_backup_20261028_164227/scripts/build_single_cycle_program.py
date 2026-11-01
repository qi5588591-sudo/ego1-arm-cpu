"""Encode a small LA32 program and derive a trace from an instruction-level model.

The reference model executes mnemonic objects rather than decoding generated
machine words, so it does not reuse the hardware decoder or ALU implementation.
Only this project's documented instruction subset is accepted.
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent.parent
MASK = (1 << 32) - 1
RR = {"add.w": 0x00100000, "sub.w": 0x00110000,
      "and": 0x00148000, "or": 0x00150000, "xor": 0x00158000}
SHIFT = {"slli.w": 0x00408000, "srli.w": 0x00448000, "srai.w": 0x00488000}
RI = {"addi.w": 0x02800000, "ld.w": 0x28800000, "st.w": 0x29800000}
BR = {"beq": 0x58000000, "bne": 0x5C000000}
program = []
labels = {}


def label(name):
    assert name not in labels
    labels[name] = len(program) * 4


def emit(op, *args):
    program.append((op, args))


def signed32(value):
    return value if value < (1 << 31) else value - (1 << 32)


def reg(value):
    assert 0 <= value < 32
    return value


def encode(op, args, pc):
    if op in RR:
        rd, rj, rk = map(reg, args)
        return RR[op] | (rk << 10) | (rj << 5) | rd
    if op in SHIFT:
        rd, rj, amount = args
        assert 0 <= amount < 32
        return SHIFT[op] | (amount << 10) | (reg(rj) << 5) | reg(rd)
    if op in RI:
        rd, rj, imm = args
        assert -2048 <= imm <= 2047
        return RI[op] | ((imm & 0xFFF) << 10) | (reg(rj) << 5) | reg(rd)
    if op == "lu12i.w":
        rd, imm = args
        assert 0 <= imm < (1 << 20)
        return 0x14000000 | (imm << 5) | reg(rd)
    if op in BR:
        rj, rd, target = args
        delta = labels[target] - pc
        assert delta % 4 == 0 and -(1 << 17) <= delta < (1 << 17)
        return BR[op] | (((delta // 4) & 0xFFFF) << 10) | (reg(rj) << 5) | reg(rd)
    if op == "b":
        delta = labels[args[0]] - pc
        assert delta % 4 == 0 and -(1 << 27) <= delta < (1 << 27)
        offset = (delta // 4) & ((1 << 26) - 1)
        return 0x50000000 | ((offset & 0xFFFF) << 10) | (offset >> 16)
    raise ValueError(op)


# A few fixed encodings make the software encoder's field layout reviewable.
assert encode("addi.w", (1, 0, 7), 0) == 0x02801C01
assert encode("add.w", (3, 1, 2), 8) == 0x00100823
assert encode("st.w", (3, 0, 0), 12) == 0x29800003
assert encode("srai.w", (12, 10, 31), 0) == 0x0048FD4C

emit("addi.w", 1, 0, 7)
emit("addi.w", 2, 0, 5)
emit("add.w", 3, 1, 2)
emit("st.w", 3, 0, 0)
emit("ld.w", 4, 0, 0)
emit("sub.w", 5, 4, 2)
emit("beq", 5, 1, "logic")
emit("addi.w", 31, 0, -1)  # Must be skipped.
label("logic")
emit("and", 6, 1, 2)
emit("or", 7, 1, 2)
emit("xor", 8, 1, 2)
emit("addi.w", 9, 0, -1)
emit("slli.w", 10, 9, 31)
emit("srli.w", 11, 10, 31)
emit("srai.w", 12, 10, 31)
emit("lu12i.w", 13, 0x12345)
emit("addi.w", 13, 13, 0x678)
emit("addi.w", 14, 0, -2048)
emit("addi.w", 15, 0, 2047)
emit("add.w", 16, 14, 15)
emit("sub.w", 17, 0, 9)
emit("add.w", 26, 9, 17)  # FFFFFFFF + 1 wraps to zero.
emit("addi.w", 0, 0, 123)  # Must not modify r0.
emit("ld.w", 0, 0, 0)     # Access memory but do not modify r0.
emit("beq", 1, 2, "fail")  # Not taken.
emit("bne", 1, 2, "branch_taken")
emit("addi.w", 31, 0, -2)  # Must be skipped.
label("branch_taken")
emit("bne", 1, 1, "fail")  # Not taken.
emit("b", "loop_setup")
emit("addi.w", 31, 0, -3)  # Must be skipped.
label("loop_setup")
emit("b", "back_entry")
label("back_target")
emit("addi.w", 25, 0, 42)
emit("b", "sum_setup")
label("back_entry")
emit("b", "back_target")  # Exercises the split, negative offs26 encoding.
label("sum_setup")
emit("addi.w", 18, 0, 0)
emit("addi.w", 19, 0, 1)
emit("addi.w", 20, 0, 6)
label("sum_loop")
emit("add.w", 18, 18, 19)
emit("addi.w", 19, 19, 1)
emit("bne", 19, 20, "sum_loop")
emit("st.w", 18, 0, 4)
emit("ld.w", 21, 0, 4)
emit("addi.w", 22, 0, 15)
emit("bne", 21, 22, "fail")
emit("addi.w", 23, 0, 16)
emit("st.w", 13, 23, -4)
emit("ld.w", 24, 23, -4)
emit("beq", 24, 13, "success")
label("fail")
emit("addi.w", 31, 0, -1)
emit("st.w", 31, 0, 8)
emit("b", "finish")
label("success")
emit("addi.w", 31, 0, 1)
emit("st.w", 31, 0, 8)
emit("b", "finish")
label("finish")
emit("b", "finish")

words = [encode(op, args, i * 4) for i, (op, args) in enumerate(program)]
regs = [0] * 32
memory = [0] * 64
trace = []
seen = set()
pc = 0
for _ in range(200):
    op, args = program[pc // 4]
    seen.add(op)
    entry = {"pc": pc, "instruction": words[pc // 4], "next_pc": pc + 4,
             "rd_we": 0, "rd": 0, "wdata": 0, "mem_req": 0,
             "mem_we": 0, "mem_addr": 0, "mem_wdata": 0, "branch_taken": 0}
    value = None
    if op in RR:
        rd, rj, rk = args
        a, b = regs[rj], regs[rk]
        if op == "add.w": value = a + b
        elif op == "sub.w": value = a - b
        elif op == "and": value = a & b
        elif op == "or": value = a | b
        elif op == "xor": value = a ^ b
    elif op in SHIFT:
        rd, rj, amount = args
        if op == "slli.w": value = regs[rj] * (2 ** amount)
        elif op == "srli.w": value = regs[rj] // (2 ** amount)
        else: value = signed32(regs[rj]) // (2 ** amount)
    elif op == "addi.w":
        rd, rj, imm = args
        value = regs[rj] + imm
    elif op == "lu12i.w":
        rd, imm = args
        value = imm * 4096
    elif op in ("ld.w", "st.w"):
        rd, rj, imm = args
        address = (regs[rj] + imm) & MASK
        assert address % 4 == 0 and 0 <= address < 256
        entry.update(mem_req=1, mem_addr=address)
        if op == "ld.w":
            value = memory[address // 4]
        else:
            memory[address // 4] = regs[rd]
            entry.update(mem_we=1, mem_wdata=regs[rd])
    elif op in BR:
        rj, rd, target = args
        take = (regs[rj] == regs[rd]) if op == "beq" else (regs[rj] != regs[rd])
        if take:
            entry.update(next_pc=labels[target], branch_taken=1)
    elif op == "b":
        entry.update(next_pc=labels[args[0]], branch_taken=1)
    if value is not None and rd != 0:
        regs[rd] = value & MASK
        entry.update(rd_we=1, rd=rd, wdata=regs[rd])
    assert regs[0] == 0
    trace.append(entry)
    if pc == labels["finish"]:
        break
    pc = entry["next_pc"]
else:
    raise AssertionError("Program did not finish")

assert len(seen) == 15
assert memory[:4] == [12, 15, 1, 0x12345678]
assert regs[3] == 12 and regs[12] == MASK and regs[31] == 1

rom = ["`timescale 1ns / 1ps", "", "// Generated by scripts/build_single_cycle_program.py.",
       "module instruction_rom (", "    input wire [31:0] address,",
       "    output reg [31:0] instruction,", "    output reg valid", ");",
       "    always @(*) begin", "        instruction = 32'd0;", "        valid = 1'b1;",
       "        case (address)"]
for i, (word, (op, args)) in enumerate(zip(words, program)):
    rom.append(f"            32'h{i*4:08x}: instruction = 32'h{word:08x}; // {op} {args}")
rom += ["            default: begin instruction = 32'd0; valid = 1'b0; end",
        "        endcase", "    end", "endmodule", ""]
(ROOT / "rtl" / "instruction_rom.v").write_text("\n".join(rom), encoding="utf-8")

golden = ["// Generated from the mnemonic-level reference model; do not edit by hand."]
for e in trace:
    golden.append(
        "expect_retire(" + ", ".join([
            f"32'h{e['pc']:08x}", f"32'h{e['instruction']:08x}", f"32'h{e['next_pc']:08x}",
            f"1'b{e['rd_we']}", f"5'd{e['rd']}", f"32'h{e['wdata']:08x}",
            f"1'b{e['mem_req']}", f"1'b{e['mem_we']}", f"32'h{e['mem_addr']:08x}",
            f"32'h{e['mem_wdata']:08x}", f"1'b{e['branch_taken']}"]) + ");")
(ROOT / "sim" / "single_cycle_expected.vh").write_text("\n".join(golden) + "\n", encoding="utf-8")

program_dir = ROOT / "programs"
program_dir.mkdir(exist_ok=True)
assembly = ["# LA32 subset demo. Labels denote byte addresses in the generated ROM.",
            "# Branch offsets are relative to the branch instruction, with no delay slot."]
listing = ["# 单周期CPU测试程序", "", "由程序生成器输出，地址单位为字节。", "",
           "| PC | 机器码 | 指令 |", "| --- | --- | --- |"]
for i, ((op, args), word) in enumerate(zip(program, words)):
    for name, addr in labels.items():
        if addr == i * 4:
            assembly.append(name + ":")
    if op in RR:
        text = f"{op} r{args[0]}, r{args[1]}, r{args[2]}"
    elif op in SHIFT or op in RI:
        text = f"{op} r{args[0]}, r{args[1]}, {args[2]}"
    elif op == "lu12i.w":
        text = f"{op} r{args[0]}, 0x{args[1]:x}"
    elif op in BR:
        text = f"{op} r{args[0]}, r{args[1]}, {args[2]}"
    else:
        text = f"b {args[0]}"
    assembly.append("    " + text)
    listing.append(f"| {i*4:08x} | {word:08x} | `{text}` |")
listing += ["", f"静态程序长度：{len(words)}条；主测试执行{len(trace)}条动态指令，包含终点的一次自循环。",
            f"终点PC：0x{labels['finish']:08x}。", "",
            "预期内存：地址0为12，地址4为15，地址8为1（程序通过标志），地址12为0x12345678。", ""]
(program_dir / "single_cycle_demo.s").write_text("\n".join(assembly) + "\n", encoding="utf-8")
(program_dir / "single_cycle_listing.md").write_text("\n".join(listing), encoding="utf-8")
(program_dir / "single_cycle_reference.json").write_text(json.dumps(
    {"labels": labels, "instructions": len(words), "retired": len(trace), "covered": sorted(seen),
     "registers": regs, "memory": memory, "trace": trace}, indent=2), encoding="utf-8")
print(f"Generated {len(words)} ROM words, {len(trace)} retirement expectations, {len(seen)} instruction kinds")
print(f"Finish PC = 0x{labels['finish']:08x}; memory[0:4] = {[hex(x) for x in memory[:4]]}")
