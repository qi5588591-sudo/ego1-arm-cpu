"""Real LLVM A32 assembler + mnemonic-level reference model, separate from RTL.

No pseudo-instructions or handwritten demo machine codes are used. ELF .text
and local branch relocations are extracted explicitly without objcopy.
"""
from pathlib import Path
import json, random, re, struct, subprocess

ROOT = Path(__file__).resolve().parents[1]
CLANG = Path(r'D:/develop/anaconda3/Library/bin/clang.exe')
MASK = 0xffffffff
CONDITIONS = ['eq','ne','cs','cc','mi','pl','vs','vc','hi','ls','ge','lt','gt','le','al']
ARITH = {'add','sub','rsb','adc','sbc','cmp','cmn'}
COMPARE = {'cmp','cmn','tst'}

def signed(x): return x if x < 0x80000000 else x-0x100000000
def condition(code, f):
    n,z,c,v = [(f >> i) & 1 for i in (3,2,1,0)]
    return bool([z,not z,c,not c,n,not n,v,not v,c and not z,
        not c or z,n==v,n!=v,not z and n==v,z or n!=v,True,False][code])

class Program:
    def __init__(self): self.items=[]; self.labels={}
    def label(self,s): self.labels[s]=len(self.items)*4
    def dp(self,op,rd=None,rn=None,imm=None,rm=None,shift='lsl',amount=0,s=False,cond='al'):
        assert (imm is None) != (rm is None)
        self.items.append(dict(op=op,rd=rd,rn=rn,imm=imm,rm=rm,shift=shift,
                               amount=amount,s=s,cond=cond))
    def mem(self,op,rd,offset=0,cond='al',rn=10):
        self.items.append(dict(op=op,rd=rd,rn=rn,offset=offset,cond=cond))
    def branch(self,label,cond='al',link=False):
        self.items.append(dict(op='bl' if link else 'b',label=label,cond=cond))
    def bx(self,rm): self.items.append(dict(op='bx',rm=rm,cond='al'))
    def constant(self,rd,value):
        self.dp('mov',rd,imm=value&255)
        for shift in (8,16,24):
            part=value&(255<<shift)
            if part: self.dp('orr',rd,rd,imm=part)
    def check(self,reg,value):
        self.constant(8,value&MASK)
        self.dp('cmp',rn=reg,rm=8)
        self.branch('fail','ne')
    def assembly(self):
        labels={}
        for name,addr in self.labels.items(): labels.setdefault(addr,[]).append(name)
        lines=['.syntax unified','.arch armv7-a','.arm','.text','.global _start','_start:']
        for i,x in enumerate(self.items):
            lines += [name+':' for name in labels.get(i*4,[])]
            op=x['op']; suffix='' if x['cond']=='al' else x['cond']
            if op in ('b','bl'): line=op+suffix+' '+x['label']
            elif op=='bx': line='bx r'+str(x['rm'])
            elif op in ('ldr','str','ldrb','strb'):
                line=f"{op}{suffix} r{x['rd']}, [r{x['rn']}, #{x['offset']}]"
            else:
                # Unified A32 syntax puts S before the condition suffix.
                mnemonic=op+('s' if x['s'] and op not in COMPARE else '')+suffix
                args=[]
                if x['rd'] is not None: args.append('r'+str(x['rd']))
                if x['rn'] is not None: args.append('r'+str(x['rn']))
                if x['imm'] is not None: args.append('#0x%x'%x['imm'])
                else:
                    operand='r'+str(x['rm'])
                    if x['shift']=='rrx': operand+=', rrx'
                    elif x['shift']!='lsl' or x['amount']:
                        operand+=f", {x['shift']} #{x['amount']}"
                    args.append(operand)
                line=mnemonic+' '+', '.join(args)
            lines.append('    '+line)
        return '\n'.join(lines)+'\n'

def assemble(p,name):
    source=ROOT/'programs'/f'{name}.s'; obj=source.with_suffix('.o')
    source.write_text(p.assembly(),encoding='utf8')
    subprocess.run([str(CLANG),'-target','armv7-none-eabi','-march=armv7-a',
                    '-marm','-c',str(source),'-o',str(obj)],check=True)
    elf=obj.read_bytes()
    assert elf[:6]==b'\x7fELF\x01\x01' and struct.unpack_from('<H',elf,18)[0]==40
    shoff=struct.unpack_from('<I',elf,32)[0]
    entsize,count,strindex=struct.unpack_from('<HHH',elf,46)
    sections=[struct.unpack_from('<10I',elf,shoff+i*entsize) for i in range(count)]
    strings=elf[sections[strindex][4]:sections[strindex][4]+sections[strindex][5]]
    names=[strings[s[0]:].split(b'\0',1)[0].decode() for s in sections]
    tid=names.index('.text'); text=bytearray(elf[sections[tid][4]:sections[tid][4]+sections[tid][5]])
    for sec in sections:
        if sec[1]!=9 or sec[7]!=tid: continue  # SHT_REL targeting .text
        syms=sections[sec[6]]
        for off in range(sec[4],sec[4]+sec[5],8):
            place,info=struct.unpack_from('<II',elf,off); kind=info&255
            assert kind in (28,29), f'Unexpected ARM relocation {kind}'
            sym=struct.unpack_from('<IIIBBH',elf,syms[4]+(info>>8)*16)
            assert sym[5]==tid, 'All branch targets must be local .text labels'
            word=struct.unpack_from('<I',text,place)[0]
            addend=word&0xffffff
            if addend&0x800000: addend-=1<<24
            displacement=sym[1]+(addend<<2)-place
            assert displacement%4==0
            struct.pack_into('<I',text,place,(word&0xff000000)|((displacement>>2)&0xffffff))
    assert len(text)==4*len(p.items), 'No hidden literal pools or multiword pseudo-instructions'
    words=list(struct.unpack('<'+'I'*len(p.items),text))
    (ROOT/'programs'/f'{name}.hex').write_text(''.join(f'{w:08x}\n' for w in words))
    return words

def operand2(x,word,regs,pc,flags):
    carry=(flags>>1)&1
    if x['imm'] is not None:
        return x['imm'], (x['imm']>>31)&1 if ((word>>8)&15) else carry
    value=(pc+8 if x['rm']==15 else regs[x['rm']]); shift=x['shift']; n=x['amount']
    if shift=='rrx': return (carry<<31)|(value>>1),value&1
    if n==0: return value,carry
    if shift=='lsl': return (value<<n)&MASK,(value>>(32-n))&1
    if shift=='lsr': return value>>n,(value>>(n-1))&1
    if shift=='asr': return (signed(value)>>n)&MASK,(value>>(n-1))&1
    assert shift=='ror' and 0<n<32
    result=((value>>n)|(value<<(32-n)))&MASK
    return result,result>>31

def reference(p,words):
    regs=[0]*15; flags=0; memory=bytearray(256); pc=0; traces=[]; coverage=set(); self_loops=0
    for step in range(5000):
        assert pc%4==0 and 0<=pc//4<len(words)
        x=p.items[pc//4]; word=words[pc//4]; op=x['op']; next_pc=pc+4
        executed=condition(word>>28,flags)
        t=dict(pc=pc,instruction=word,next_pc=next_pc,executed=int(executed),rd_we=0,
               rd=0,wdata=0,mem_req=0,mem_we=0,byte=0,mem_addr=0,mem_wdata=0,nzcv=flags)
        if executed:
            coverage.add(op); rd=None; value=0
            if op in ('b','bl'):
                next_pc=p.labels[x['label']]
                if op=='bl': rd=14; value=pc+4
            elif op=='bx': next_pc=regs[x['rm']]
            elif op in ('ldr','str','ldrb','strb'):
                addr=(regs[x['rn']]+x['offset'])&MASK; byte=op.endswith('b'); size=1 if byte else 4
                index=addr-0x1000
                assert 0<=index<=256-size and (byte or addr%4==0)
                t.update(mem_req=1,mem_we=int(op.startswith('str')),byte=int(byte),mem_addr=addr)
                if op.startswith('str'):
                    value=regs[x['rd']]&((1<<(size*8))-1)
                    memory[index:index+size]=value.to_bytes(size,'little');t['mem_wdata']=value
                else: rd=x['rd']; value=int.from_bytes(memory[index:index+size],'little')
            else:
                a=(pc+8 if x['rn']==15 else regs[x['rn']]) if x['rn'] is not None else 0
                b,shcarry=operand2(x,word,regs,pc,flags); carry=(flags>>1)&1
                if op in ARITH:
                    if op in ('add','cmn'): full=a+b; sfull=signed(a)+signed(b)
                    elif op=='adc': full=a+b+carry; sfull=signed(a)+signed(b)+carry
                    elif op in ('sub','cmp'): full=a-b; sfull=signed(a)-signed(b)
                    elif op=='sbc': full=a-b-(1-carry); sfull=signed(a)-signed(b)-(1-carry)
                    else: full=b-a; sfull=signed(b)-signed(a)
                    value=full&MASK
                    cout=int(full>MASK) if op in ('add','adc','cmn') else int(full>=0)
                    overflow=int(not (-0x80000000<=sfull<=0x7fffffff))
                else:
                    value={'and':lambda:a&b,'tst':lambda:a&b,'orr':lambda:a|b,
                           'eor':lambda:a^b,'bic':lambda:a&~b,'mov':lambda:b,'mvn':lambda:~b}[op]()&MASK
                    cout=shcarry; overflow=flags&1
                if x['s'] or op in COMPARE:
                    flags=((value>>31)<<3)|(int(value==0)<<2)|(cout<<1)|overflow
                if op not in COMPARE: rd=x['rd']
            if rd is not None:
                assert 0<=rd<15
                regs[rd]=value&MASK;t.update(rd_we=1,rd=rd,wdata=regs[rd])
        t.update(next_pc=next_pc,nzcv=flags);traces.append(t)
        self_loops=self_loops+1 if next_pc==pc else 0; pc=next_pc
        if self_loops==3: break
    else: raise AssertionError('Reference timeout')
    return traces,coverage,memory

def make_demo():
    p=Program(); p.constant(10,0x1000)
    p.dp('mov',0,imm=7);p.dp('add',2,0,imm=5);p.mem('str',2);p.mem('ldr',3);p.check(3,12)
    p.dp('sub',4,2,imm=12,s=True);p.dp('mov',5,imm=1,cond='eq');p.dp('mov',5,imm=99,cond='ne');p.check(5,1)
    p.dp('mvn',6,imm=0);p.dp('add',4,6,imm=1,s=True);p.dp('adc',5,0,imm=0);p.check(5,8)
    p.dp('sbc',5,0,imm=2);p.check(5,5)
    p.dp('mov',6,imm=0);p.dp('cmp',rn=6,imm=1);p.dp('sbc',5,0,imm=2);p.check(5,4)
    p.dp('rsb',5,0,imm=20);p.check(5,13)
    p.dp('mov',6,imm=0xf0);p.dp('mov',7,imm=0x3c)
    for op,expected in [('and',0x30),('orr',0xfc),('eor',0xcc),('bic',0xc0)]:
        p.dp(op,4,6,rm=7);p.check(4,expected)
    p.dp('mvn',6,imm=0);p.dp('cmn',rn=6,imm=1);p.branch('fail','ne');p.branch('fail','cc')
    p.dp('mov',6,imm=0xf0);p.dp('tst',rn=6,imm=0x80);p.branch('fail','eq')
    p.dp('mov',6,imm=0x80);p.dp('mov',4,rm=6,amount=24,s=True);p.check(4,0x80000000)
    p.dp('mov',4,rm=4,shift='lsr',amount=32,s=True);p.branch('fail','cc');p.check(4,0)
    p.constant(4,0x80000000);p.dp('mov',4,rm=4,shift='asr',amount=32,s=True);p.check(4,MASK)
    p.dp('mov',6,imm=0x81);p.dp('mov',4,rm=6,shift='ror',amount=4,s=True);p.check(4,0x10000008)
    p.dp('mov',6,imm=2);p.dp('cmp',rn=0,rm=0);p.dp('mov',4,rm=6,shift='rrx',s=True);p.check(4,0x80000001)
    p.dp('mvn',6,imm=0);p.mem('str',6,16)
    for offset,value in enumerate([0x12,0x34,0x56,0x78],16):
        p.dp('mov',6,imm=value);p.mem('strb',6,offset);p.mem('ldrb',4,offset);p.check(4,value)
    p.mem('ldr',7,16);p.check(7,0x78563412)
    p.dp('add',9,10,imm=20);p.mem('ldrb',4,-3,rn=9);p.check(4,0x34)
    p.dp('cmp',rn=0,rm=0);p.mem('str',6,0,cond='ne');p.mem('ldr',4,0,cond='ne')
    pc=len(p.items)*4;p.dp('mov',4,rm=15);p.check(4,pc+8)
    p.dp('mov',0,imm=9);return_pc=(len(p.items)+1)*4;p.branch('subroutine',link=True);p.check(0,12);p.check(14,return_pc)
    p.dp('mov',0,imm=1);p.dp('mov',1,imm=0);p.label('loop')
    p.dp('add',1,1,rm=0);p.dp('add',0,0,imm=1);p.dp('cmp',rn=0,imm=6);p.branch('loop','lt')
    p.mem('str',1,4);p.check(1,15);p.dp('mov',0,imm=1);p.mem('str',0,8)
    p.label('finish');p.branch('finish')
    p.label('fail');p.dp('mov',0,imm=0xee);p.mem('str',0,8);p.label('fail_halt');p.branch('fail_halt')
    p.label('subroutine');p.dp('add',0,0,imm=3);p.bx(14)
    return p

def make_stress():
    p=Program();rng=random.Random(0xA322026); registers=list(range(10))+[11,12,13,14]
    p.constant(10,0x1000)
    for reg in registers: p.constant(reg,rng.getrandbits(32))
    for i in range(600):
        cond=rng.choice(CONDITIONS)
        if i%6==0:
            op=rng.choice(['str','ldr','strb','ldrb']);byte=op.endswith('b')
            p.mem(op,rng.choice(registers),rng.randrange(256) if byte else rng.randrange(64)*4,cond)
        else:
            op=rng.choice(['add','sub','rsb','adc','sbc','and','orr','eor','bic','mov','mvn','cmp','cmn','tst'])
            kw=dict(rd=None if op in COMPARE else rng.choice(registers),
                    rn=None if op in ['mov','mvn'] else rng.choice(registers),s=bool(rng.getrandbits(1)),cond=cond)
            if rng.getrandbits(1):
                seed=rng.randrange(256);rot=rng.randrange(16)*2
                imm=((seed>>rot)|(seed<<(32-rot)))&MASK if rot else seed
                p.dp(op,imm=imm,**kw)
            else:
                shift=rng.choice(['lsl','lsr','asr','ror','rrx'])
                amount=0 if shift=='rrx' else rng.randrange(32) if shift=='lsl' else rng.randrange(1,33) if shift in ['lsr','asr'] else rng.randrange(1,32)
                p.dp(op,rm=rng.choice(registers),shift=shift,amount=amount,**kw)
    p.label('finish');p.branch('finish');return p

def export(p,name):
    words=assemble(p,name); traces,coverage,memory=reference(p,words)
    target=ROOT/('rtl' if name=='demo' else 'sim')/f'arm_{name}_rom.v'
    cases=''.join(f"            32'h{i*4:08x}: instruction=32'h{w:08x};\n" for i,w in enumerate(words))
    target.write_text('`timescale 1ns/1ps\nmodule arm_'+name+'_rom(input wire [31:0] address, output reg [31:0] instruction,output reg valid);\n    always @* begin\n        valid=1; instruction=0;\n        case(address)\n'+cases+'            default: begin valid=0; instruction=0; end\n        endcase\n    end\nendmodule\n')
    fields=['pc','instruction','next_pc','executed','rd_we','rd','wdata','mem_req','mem_we','byte','mem_addr','mem_wdata','nzcv']
    vectors=[]
    for t in traces:
        vals=','.join(f"32'h{t[k]:08x}" for k in fields)
        vectors.append(f'        expect_trace({vals});')
    (ROOT/'sim'/f'{name}_expected.vh').write_text('\n'.join(vectors)+'\n')
    (ROOT/'programs'/f'{name}_reference.json').write_text(json.dumps(dict(coverage=sorted(coverage),traces=traces),indent=2))
    (ROOT/'programs'/f'{name}_listing.txt').write_text('\n'.join(f'{i*4:08x}  {w:08x}  {p.items[i]}' for i,w in enumerate(words))+'\n')
    print(f'{name}: {len(words)} real A32 words, {len(traces)} retired, {len(coverage)} executed instruction kinds',sorted(coverage))
    if name=='demo':
        assert len(coverage)==21
        assert [int.from_bytes(memory[i:i+4],'little') for i in [0,4,8]]==[12,15,1]

if __name__=='__main__':
    export(make_demo(),'demo');export(make_stress(),'stress')
