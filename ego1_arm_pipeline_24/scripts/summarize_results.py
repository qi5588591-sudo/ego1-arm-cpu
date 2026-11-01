from pathlib import Path
import csv,hashlib,json,re

root=Path(__file__).resolve().parents[1]
cpu=(root/'reports/cpu_simulation.log').read_text()
board=(root/'reports/board_simulation.log').read_text()
rows=[]
names={0:'21-instruction demo',1:'ALU/memory stress',2:'Basic hazards',
       4:'24-instruction demo',5:'MDU hazards',6:'MDU stress'}
pattern=r'PIPE PROGRAM PASSED: image=(\d+) core=(\d+) retired=(\d+) cycles=(\d+) stalls=(\d+) load_stalls=(\d+) flag_stalls=(\d+) redirects=(\d+) forwards=(\d+) flag_forwards=(\d+) checks=(\d+)'
for match in re.finditer(pattern,cpu):
    values=list(map(int,match.groups()))
    row=dict(zip(['image','core','retired','cycles','stalls','load_stalls','flag_stalls','redirects','forwards','flag_forwards','checks'],values))
    row['program']=names[row['image']]
    row['cpi']=row['cycles']/row['retired']
    rows.append(row)
rows.sort(key=lambda r:(r['image'],r['core']))
with (root/'reports/performance.csv').open('w',newline='') as f:
    writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
summary={
    'cpu_checks':int(re.search(r'ARM PIPELINE TESTS PASSED: (\d+)',cpu)[1]),
    'board_checks':int(re.search(r'BOARD TESTS PASSED: (\d+)',board)[1]),
    'program_core_cases':15,'precise_fault_cases':46,'mdu_integer_vectors':1443,
    'unit_reset_positions':32,'full_pipeline_reset_operations':['MUL','SDIV','UDIV'],
    'physical_board':'pending user verification',
}
demo=json.loads((root/'programs/demo24_reference.json').read_text())
summary['demo_executed_instruction_kinds']=demo['coverage']
assert len(demo['coverage'])==24
bit=root/'download/ego1_arm_pipeline_24.bit'
data=bit.read_bytes()
summary['bit_bytes']=len(data);summary['bit_sha256']=hashlib.sha256(data).hexdigest().upper()
physical_record=root/'reports/physical_board_verification.json'
if physical_record.exists():
    physical=json.loads(physical_record.read_text(encoding='utf-8'))
    if physical.get('bit_sha256')==summary['bit_sha256']:
        summary['physical_board']=physical['status']
        summary['physical_board_date']=physical['date']
        summary['physical_board_record']=str(physical_record.relative_to(root))
sync=data.index(bytes.fromhex('aa995566'))
tag=data.index(bytes.fromhex('3001a00141525032'),sync)
assert tag-sync<1024, 'Expected ARP2 metadata before configuration frames'
summary['usr_access']='41525032'
baseline=root.parent/'ego1_arm_pipeline/download/ego1_arm_pipeline.bit'
summary['baseline_21_sha256']=hashlib.sha256(baseline.read_bytes()).hexdigest().upper()
assert summary['baseline_21_sha256']=='669936854BC5432623BEC89C8F54969EC8579562EA61C4DA3693A80662FA8590'
sources=list((root/'rtl').glob('*'))+list((root/'constraints').glob('*'))
summary['source_sha256']={str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest().upper() for p in sources if p.is_file()}
(root/'reports/verification_summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
lines=['# 同一流水线中旁路与仅暂停的比较','',
       '数据来自 reports/cpu_simulation.log。两种配置都使用相同的 32 次迭代 MDU；这是旁路优化的周期收益，不是相对单周期 CPU 的加速比。',
       '旧单周期仿真内核只参与 21 条旧程序回归，不能执行新乘除程序。',
       '', '| 程序 | 退休指令 | 旁路周期 | 仅暂停周期 | 节约周期 | 周期减少 | 旁路 CPI |',
       '|---|---:|---:|---:|---:|---:|---:|']
for image in names:
    forward=next(r for r in rows if r['image']==image and r['core']==1)
    stall=next(r for r in rows if r['image']==image and r['core']==2)
    saved=stall['cycles']-forward['cycles']
    lines.append(f"| {names[image]} | {forward['retired']} | {forward['cycles']} | {stall['cycles']} | {saved} | {100*saved/stall['cycles']:.2f}% | {forward['cpi']:.3f} |")
lines+=['', '每条实际执行的 MDU 指令额外暂停前端 33 拍；条件不成立、错误路径上的指令不会启动单元。',
        '计数截止在最后一条期望指令退休时；此时可能有年轻的分支在途。子类停顿可重叠，不能简单将各计数相加等同总周期。',
        '板上 CPU 仍为 1MHz；没有测量并声称更高频率下的实板性能。','']
(root/'PERFORMANCE.md').write_text('\n'.join(lines),encoding='utf-8')
print(json.dumps({k:v for k,v in summary.items() if k!='source_sha256'},indent=2))
