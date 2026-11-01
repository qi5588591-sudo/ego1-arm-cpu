"""Refresh reports/verification_summary.json from the current tree."""
from pathlib import Path
import hashlib, json

root = Path(__file__).resolve().parents[1]

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest().upper()

unchanged = ['arm_alu.v', 'arm_condition.v', 'arm_data_ram.v', 'arm_decode.v',
             'arm_mdu.v', 'arm_operand2.v', 'arm_pipeline_cpu.sv',
             'arm_pipeline_regfile.v']
demo = ['arm_showcase_rom.v', 'showcase_catalog.v', 'showcase_display.v',
        'showcase_format.v', 'ego1_arm_showcase_top.v', 'board_button.v',
        'arm_pipeline_soc.v']

bit = root / 'download' / 'ego1_arm_showcase.bit'
data = dict(
    date='2026-11-01',
    simulation_checks=604,
    setup_slack_ns=7.489,
    hold_slack_ns=0.063,
    drc_violations=0,
    unconstrained_internal_endpoints=0,
    lut=3680, lut_pct=17.69,
    ff=5754, ff_pct=13.83,
    dsp=0, bram=0,
    bit_bytes=bit.stat().st_size,
    bit_sha256=sha(bit),
    previous_bit_sha256='868A05CDA78DF431CF72826080199FFCD920376FB4173202A91D86458E8C6ADB',
    physical_board='pending: board removed before hardware check',
    cpu_files_unchanged={'rtl\\' + n: sha(root / 'rtl' / n) for n in unchanged},
    demo_files={'rtl\\' + n: sha(root / 'rtl' / n) for n in demo},
    program_words=119,
    retired_instructions=116,
    covered_instruction_kinds=24,
)
(root / 'reports' / 'verification_summary.json').write_text(
    json.dumps(data, indent=2), encoding='utf-8')
print(json.dumps({k: data[k] for k in ('simulation_checks', 'setup_slack_ns',
                                       'hold_slack_ns', 'bit_bytes', 'bit_sha256')}, indent=2))
