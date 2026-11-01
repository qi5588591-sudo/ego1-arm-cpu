"""Read-only inspection of 7-series type-1/type-2 configuration packets."""
from pathlib import Path
import json
import struct

FILES = [
    Path('D:/Code/Vivado/ego1_led_test/ego1_led_test.runs/impl_1/led_blink.bit'),
    Path('D:/Code/Vivado/ego1_arm_single_cycle/download/ego1_arm_single_cycle.bit'),
    Path('D:/Code/Vivado/ego1_arm_pipeline/download/ego1_arm_pipeline.bit'),
    Path('D:/Code/Vivado/ego1_arm_pipeline/download/ego1_arm_pipeline_jtag_uncompressed.bit'),
    Path('D:/Code/Vivado/ego1_arm_pipeline/download/ego1_arm_pipeline_manual_start.bit'),
]
NAMES = {4:'CMD',5:'CTL0',6:'MASK',9:'COR0',12:'IDCODE',13:'AXSS',14:'COR1',16:'WBSTAR',17:'TIMER',24:'CTL1',31:'BSPI'}
result = {}
for path in FILES:
    data = path.read_bytes()
    sync = data.index(bytes.fromhex('aa995566'))
    stream = data[sync + 4:]
    assert len(stream) % 4 == 0
    words = struct.unpack('>' + 'I' * (len(stream) // 4), stream)
    i = 0
    reg = None
    writes = {name:[] for name in NAMES.values()}
    while i < len(words):
        header = words[i]
        i += 1
        if header == 0xffffffff:
            continue
        typ = header >> 29
        op = (header >> 27) & 3
        if typ == 1:
            reg = (header >> 13) & 0x3fff
            count = header & 0x7ff
        elif typ == 2:
            count = header & 0x7ffffff
        else:
            raise ValueError(f'{path.name}: unexpected packet at word {i-1}: {header:08x}')
        if op == 2:
            assert i + count <= len(words)
            if reg in NAMES and count:
                writes[NAMES[reg]].extend(f'{x:08X}' for x in words[i:i+count])
            i += count
    result[str(path)] = {k:v for k,v in writes.items() if v}
    print(path.name)
    print(json.dumps(result[str(path)], indent=2))
Path(__file__).with_name('bitstream_options.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
