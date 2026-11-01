.syntax unified
.arch armv7-a
.arm
.text
.global _start
_start:
    mov r10, #0x0
    orr r10, r10, #0x1000
    mov r0, #0xb8
    orr r0, r0, #0xc400
    orr r0, r0, #0xb40000
    orr r0, r0, #0x67000000
    mov r1, #0xc7
    orr r1, r1, #0x200
    orr r1, r1, #0x820000
    orr r1, r1, #0x37000000
    mov r2, #0xdd
    orr r2, r2, #0x9500
    orr r2, r2, #0x8b0000
    orr r2, r2, #0xb2000000
    mov r3, #0x5e
    orr r3, r3, #0xe700
    orr r3, r3, #0x140000
    orr r3, r3, #0xc2000000
    mov r4, #0x6c
    orr r4, r4, #0x1700
    orr r4, r4, #0x1a0000
    orr r4, r4, #0x6000000
    mov r5, #0x1c
    orr r5, r5, #0xc500
    orr r5, r5, #0x630000
    orr r5, r5, #0x1a000000
    mov r6, #0x61
    orr r6, r6, #0x7000
    orr r6, r6, #0xa60000
    orr r6, r6, #0x66000000
    mov r7, #0x77
    orr r7, r7, #0x3d00
    orr r7, r7, #0x670000
    orr r7, r7, #0x11000000
    mov r8, #0xfd
    orr r8, r8, #0xe000
    orr r8, r8, #0x9c0000
    orr r8, r8, #0x63000000
    mov r9, #0xfa
    orr r9, r9, #0x2000
    orr r9, r9, #0x1f0000
    orr r9, r9, #0x4c000000
    mov r11, #0xd3
    orr r11, r11, #0xfe00
    orr r11, r11, #0xa20000
    orr r11, r11, #0x8c000000
    mov r12, #0xe5
    orr r12, r12, #0x8800
    orr r12, r12, #0x6c0000
    orr r12, r12, #0x6e000000
    mov r13, #0x31
    orr r13, r13, #0x2d00
    orr r13, r13, #0x900000
    orr r13, r13, #0xc6000000
    mov r14, #0x28
    orr r14, r14, #0x7800
    orr r14, r14, #0x6c0000
    orr r14, r14, #0xbc000000
    strble r3, [r10, #7]
    adcslt r13, r8, r14, ror #2
    orrge r0, r7, #0x1a
    andscc r7, r12, r9, rrx
    cmpvc r3, r4, ror #25
    eorgt r7, r6, #0xbc000
    ldrge r9, [r10, #200]
    rsbls r14, r0, #0x7400
    and r9, r3, #0xfa000
    andsls r12, r1, #0xc0000025
    tstpl r6, r0, asr #25
    andmi r13, r11, r3, lsl #9
    ldrvc r2, [r10, #104]
    cmple r14, #0xdd000000
    eorgt r1, r9, r9, lsr #2
    sbcpl r12, r0, r14, lsr #4
    sbcsmi r7, r14, r8, asr #7
    cmnls r11, r2, rrx
    ldrmi r3, [r10, #148]
    addsgt r8, r13, r6, rrx
    orrcs r1, r14, #0x1ec0
    subcc r2, r7, r11, lsr #3
    movsne r9, #0x1e400
    cmnge r5, r11, lsr #31
    strbcc r11, [r10, #54]
    adds r0, r9, r2, lsl #26
    cmnle r4, r7, ror #31
    rsbseq r2, r9, r14, lsl #12
    sbcge r0, r5, #0x40000005
    eorsvc r4, r5, #0x17000000
    strble r13, [r10, #207]
    mvnshi r5, #0x9200
    subpl r1, r2, #0xd40000
    mvnsmi r14, r2, ror #25
    tstle r14, r3, lsl #7
    subgt r2, r4, r4, rrx
    strvc r4, [r10, #112]
    mvnlt r12, #0xf0
    cmpvs r4, #0x8000000a
    mvnle r1, r13, lsr #24
    movsvs r1, #0x6c000001
    mvnne r2, #0x1a800
    strbgt r14, [r10, #197]
    rsbsne r8, r9, r12, lsl #10
    rsbsmi r5, r14, #0x29
    subhi r7, r0, #0x30c000
    rsbsne r3, r6, r1, ror #28
    orrge r5, r5, r7, ror #21
    strbmi r1, [r10, #244]
    orrle r12, r1, #0x28000
    cmpne r4, #0x1c0000
    subls r3, r3, #0x10400
    movvc r8, r9, asr #26
    eormi r2, r14, r3, lsr #11
    ldrbls r1, [r10, #123]
    tstcs r12, r1, lsr #1
    cmnle r2, #0x56000
    addscs r5, r13, #0x65000
    addhi r13, r9, r4, asr #29
    andscc r7, r6, #0x2e800000
    strls r12, [r10, #92]
    orrcs r9, r3, #0x10000002
    addsvs r9, r5, r13, lsr #27
    cmnge r0, r11, lsr #29
    eorsgt r13, r13, #0x650
    andmi r11, r7, r5, ror #26
    streq r3, [r10, #204]
    movlt r5, r0, asr #4
    sbcsgt r3, r7, r12, asr #13
    sbcle r14, r1, r6, lsl #31
    subscs r3, r12, #0x40
    cmpne r14, #0xac000
    strcs r1, [r10, #80]
    orrseq r9, r3, #0x3a8000
    cmpne r7, r6, lsl #1
    adcsle r14, r9, r13, ror #22
    addne r11, r6, #0xe3000000
    cmpvc r11, #0xcb000000
    ldrne r12, [r10, #252]
    andls r1, r4, #0x32000
    andlt r14, r12, r13, lsr #10
    bicgt r6, r8, r2, lsr #17
    addscs r1, r9, #0xc6000000
    subslt r6, r11, r13, lsr #31
    strge r1, [r10, #236]
    sbcle r14, r14, #0x30000001
    andgt r5, r11, #0x18400000
    orrscc r12, r9, #0x1b000
    movls r13, #0x57000
    adcscc r9, r9, #0x8000001c
    ldrge r4, [r10, #16]
    tstmi r7, #0x9e
    movge r6, r14, rrx
    subeq r2, r6, r12, lsl #4
    addseq r1, r3, r8, asr #9
    cmnpl r0, #0xd40000
    ldrbvc r9, [r10, #106]
    movgt r12, #0x30c0000
    subsls r3, r5, r14, asr #6
    tstle r8, r1, lsl #22
    mov r13, r14, lsl #28
    cmppl r11, r1, rrx
    ldrmi r2, [r10, #196]
    cmphi r3, #0xd9
    adcsls r7, r4, r0, lsr #3
    bicle r3, r5, #0xfc0
    rsble r0, r5, r8, ror #6
    subsvs r0, r4, #0xb4
    ldrhi r3, [r10, #224]
    addslt r11, r3, #0xd0
    adcle r9, r7, r7, lsl #27
    orrsls r13, r5, r3, asr #9
    orrmi r1, r2, r8, asr #31
    bicpl r5, r9, r13, lsl #20
    ldrbcs r1, [r10, #108]
    eorsge r11, r7, #0x40000000
    cmpeq r9, r2, lsr #31
    cmp r12, r1, rrx
    cmncc r0, #0x58000
    biccc r14, r0, #0x36
    strge r13, [r10, #88]
    biceq r5, r3, #0xf0
    rsbsgt r1, r11, r4, lsl #26
    rsbsvc r1, r1, #0x67000000
    subs r3, r9, r12, rrx
    addsls r2, r3, #0x2b0000
    strls r1, [r10, #204]
    adcsvc r9, r4, #0xd4000000
    rsbvc r3, r1, r11, asr #26
    cmnhi r11, r5, lsl #10
    sbclt r2, r12, r5, lsl #7
    orrsgt r13, r0, r9, asr #9
    ldrbcs r7, [r10, #47]
    cmplt r8, #0x900000
    sbcpl r14, r5, r12, ror #28
    bicseq r2, r13, r13, ror #11
    tstle r11, r0, asr #8
    tstcc r9, #0xc000
    ldrne r5, [r10, #88]
    sbcpl r9, r4, r2, lsr #14
    orrscs r7, r5, r14, lsl #26
    andvc r1, r14, #0x9200000
    tstpl r6, r8, asr #17
    subeq r13, r11, r5, lsl #24
    ldrbge r11, [r10, #195]
    rsbsmi r12, r5, #0x1d4
    movsle r8, #0xb9000
    cmpcs r8, #0x2f800000
    cmnlt r9, r13, lsl #10
    cmplt r6, #0xc0000023
    strle r6, [r10, #72]
    adcs r7, r3, r1, asr #28
    cmnlt r1, r3, lsl #30
    cmpge r8, r11, rrx
    tstcc r14, r1, ror #5
    subsle r11, r5, r11, asr #24
    ldrbhi r5, [r10, #14]
    subsls r3, r6, r11, lsr #7
    cmpls r7, #0x90
    andsvs r6, r8, #0xc0000024
    cmnge r5, r6, lsr #30
    orrs r13, r8, #0x18c0
    ldrmi r4, [r10, #128]
    eorsvc r11, r9, r3, rrx
    eorsle r9, r6, r8, asr #8
    bicvs r5, r11, r6, lsr #20
    mvnshi r3, r14, asr #13
    cmngt r4, #0x8000000e
    ldrbpl r8, [r10, #193]
    tstle r6, #0xac00000
    sbcsne r0, r7, #0x840
    bicsvs r2, r0, r12, rrx
    sbcne r12, r5, #0xb4000
    bicle r6, r6, r0, asr #17
    ldrpl r0, [r10, #124]
    subs r5, r0, #0xac0000
    orrsgt r5, r0, r1, rrx
    subsge r3, r2, r14, asr #14
    subge r7, r7, #0x3c00
    cmnhi r5, #0x84000001
    ldrbcs r4, [r10, #79]
    tstpl r0, #0x26800000
    subcc r8, r0, r1, lsl #19
    cmple r4, #0x80000027
    andscc r14, r11, #0x2b000000
    eor r14, r0, r11, lsl #19
    streq r13, [r10, #104]
    adcsvc r12, r0, #0x29
    eors r9, r6, #0x2
    mvnvc r13, #0x2c000
    orreq r3, r13, #0x38400000
    eorsle r1, r9, #0x3bc000
    ldrhi r1, [r10, #108]
    cmnvs r8, r13, lsr #28
    cmpls r7, #0x860
    eors r14, r6, #0xc0000019
    biclt r4, r3, r6, ror #23
    rsble r9, r4, r5, rrx
    ldrbpl r11, [r10, #230]
    eorcc r3, r2, r12, rrx
    mvnvs r1, r2, ror #18
    eorspl r7, r12, #0x27000000
    tstls r6, #0xa000000e
    mvnshi r6, r3, rrx
    strbvs r0, [r10, #247]
    subsvs r14, r14, r0, lsl #27
    adcne r7, r0, #0x2400000
    movscs r0, #0xf80000
    sbcmi r12, r12, #0x4000001f
    movscs r12, r8, asr #31
    ldrle r11, [r10, #16]
    andslt r0, r3, #0xba000
    movsge r12, #0x80000031
    eorshi r13, r1, r9, ror #20
    cmpcc r9, r5, asr #10
    cmnvc r2, r5, asr #31
    strcc r7, [r10, #180]
    cmncs r8, r9, ror #31
    mvns r8, r11, ror #3
    movscs r6, r5, lsl #4
    orrsls r12, r7, #0x3280
    bicsvc r9, r4, #0xe2000000
    streq r6, [r10, #188]
    andne r9, r0, r14, lsl #13
    andgt r5, r3, #0x80000019
    rsbsgt r9, r6, #0xc8000
    adcsge r7, r0, #0xa20000
    rsb r9, r5, r11, lsr #17
    ldrbpl r6, [r10, #219]
    movne r1, r3, rrx
    movshi r4, r14, lsl #16
    adcsne r2, r8, r4, rrx
    addsle r2, r2, r12, rrx
    andmi r13, r9, r4, lsr #5
    strvc r9, [r10, #52]
    adcseq r5, r1, #0x2f80000
    rsbsgt r4, r3, r2, asr #13
    bicsls r11, r3, r2, asr #7
    addhi r7, r2, #0x364000
    sublt r0, r13, #0x3800
    ldreq r14, [r10, #176]
    mvnsge r13, #0xa000000b
    eorge r9, r4, #0x26c00000
    subslt r13, r5, #0x3800
    cmppl r8, #0xde00
    addscc r7, r1, r8, rrx
    ldrbgt r12, [r10, #68]
    cmneq r11, r12, asr #20
    movgt r9, r7, asr #27
    sbcsvs r8, r7, r6, asr #31
    subge r5, r12, r3, asr #28
    andgt r2, r11, r2, rrx
    strbpl r4, [r10, #143]
    adcsne r12, r1, r13, asr #25
    adcseq r5, r8, #0x1a80
    tstvs r9, #0xf0
    tstmi r2, #0x10000
    mvnmi r1, r2, lsr #9
    ldrbpl r13, [r10, #35]
    movls r2, r0, rrx
    tstmi r9, #0x19400
    mvnseq r7, #0x13
    adc r11, r3, #0x8c0
    movvs r8, #0x61
    strbcs r14, [r10, #135]
    mvnseq r3, r13, ror #9
    subcs r13, r4, #0xe8
    subeq r5, r14, #0x5f
    adcge r0, r5, r14, lsl #29
    bicvs r0, r13, r2, ror #22
    strbgt r5, [r10, #126]
    andgt r12, r3, #0x2900
    sbccs r1, r14, #0xf2000000
    sbceq r7, r9, r2, asr #12
    eorsgt r2, r0, #0x3c00000
    cmncs r8, #0xf40
    ldrble r12, [r10, #129]
    rsbgt r7, r1, r14, lsl #23
    sbcscs r3, r7, r2, asr #32
    subcs r8, r13, #0x3e0
    subvc r0, r6, #0x80000028
    suble r11, r7, #0xc000000b
    strvc r2, [r10, #100]
    adcscc r12, r8, #0x10
    suble r14, r13, r14, rrx
    mvnscc r5, #0x9a
    adcsgt r4, r13, r3, lsl #13
    andlt r6, r3, #0x5200
    ldrblt r13, [r10, #108]
    bicgt r6, r7, #0xa30
    adcsne r12, r3, r5, lsl #6
    cmnlt r5, r6, ror #6
    adcmi r6, r9, #0x86
    orrseq r0, r2, #0x2c8000
    strlt r3, [r10, #44]
    cmngt r2, #0xfe000000
    rsbpl r5, r12, #0x8000000b
    movhi r13, #0xfc
    cmphi r1, #0x39000
    sbcls r12, r9, r7, lsr #8
    strbgt r3, [r10, #80]
    rsbgt r12, r11, #0x2300000
    eors r7, r3, r6, lsl #17
    mvnvs r3, #0x640000
    orrcc r12, r13, r7, ror #24
    cmple r5, r11, asr #11
    strne r8, [r10, #200]
    orrscc r14, r4, #0x39
    addmi r3, r11, #0x21
    orrsls r7, r7, r2, rrx
    andshi r13, r1, #0x40
    cmnne r14, r0, ror #13
    ldrpl r7, [r10, #176]
    orrne r0, r7, #0x3e800
    cmphi r2, r13, ror #28
    bicne r0, r7, r0, rrx
    bicsne r13, r1, #0x2ec0000
    sbc r13, r8, r7, lsr #18
    ldrhi r11, [r10, #68]
    andcc r9, r8, r8, lsl #31
    tstmi r0, r12, lsr #10
    biclt r4, r9, #0x0
    andlt r9, r14, r11, lsr #1
    sbc r3, r7, r3, rrx
    ldrvs r11, [r10, #160]
    mvnge r3, #0x20000002
    bicscc r2, r6, #0x15
    orrslt r4, r14, #0x108
    movs r11, #0x26400000
    cmpvs r9, r6, lsl #15
    ldrbvc r14, [r10, #187]
    cmnmi r1, r11, lsl #26
    orrseq r9, r2, r2, asr #3
    adceq r1, r5, #0x3c4000
    bichi r5, r8, #0x790000
    andspl r0, r9, #0xe4000000
    strvs r1, [r10, #20]
    eorvc r3, r11, r14, rrx
    mvncc r5, r8, asr #27
    sbcvs r7, r13, #0xa0000
    tstmi r12, r13, rrx
    mvnge r7, r12, asr #30
    strne r1, [r10, #212]
    mvnvs r8, r13, ror #3
    addhi r4, r12, #0x800
    movvc r12, #0x830000
    addscs r3, r8, r6, asr #26
    orrsge r7, r3, #0x80000007
    ldrpl r5, [r10, #92]
    adcpl r5, r3, #0x1a
    movsvc r9, #0x7c00
    addvc r4, r14, #0x358000
    cmngt r14, #0x2000
    addsls r7, r5, r2, lsr #15
    strcc r9, [r10, #24]
    sbceq r14, r14, r1, ror #6
    eorcs r5, r13, r6, ror #29
    sbcs r11, r4, #0x30000002
    adcs r13, r2, r9, rrx
    rsbvc r13, r13, #0x384
    ldrbcc r4, [r10, #184]
    cmnle r8, r7, ror #24
    cmpge r13, #0x2300
    adcgt r14, r0, r5, ror #17
    mvnslt r13, #0x5c000003
    eorsmi r7, r6, r14, rrx
    strbne r12, [r10, #246]
    cmpvc r2, #0x8300
    adcmi r0, r7, r4, rrx
    addcc r3, r9, r13, asr #25
    bicsls r5, r1, #0x2780000
    adds r14, r9, r13, ror #8
    ldrcs r1, [r10, #184]
    adccc r1, r14, #0xc000002e
    adcgt r11, r8, r2, asr #17
    adds r5, r13, r2, asr #1
    sbccs r3, r5, #0x13400
    mvneq r8, #0xe00000
    ldrbpl r12, [r10, #16]
    cmneq r13, #0x370000
    eorhi r4, r3, r13, rrx
    orrvs r9, r5, r8, lsr #13
    movgt r6, #0xa2000000
    tst r7, #0xd400
    ldrhi r0, [r10, #252]
    rsbsgt r12, r5, r0, ror #27
    addhi r5, r7, r12, rrx
    cmpcs r3, #0x18400000
    cmnvs r8, #0x31800000
    rsbs r11, r7, #0xf4
    ldrbmi r13, [r10, #94]
    cmpcc r5, r3, asr #4
    cmppl r2, #0x2500000
    bicscc r13, r11, r13, ror #13
    adcseq r6, r11, #0x11c0
    orrsge r6, r11, #0xf40
    strvs r1, [r10, #92]
    andle r12, r7, #0x8000
    sbcle r9, r14, #0x24c0
    biccs r5, r8, r12, ror #14
    adcslt r0, r14, r2, lsl #13
    subcc r12, r6, #0x80000029
    strcc r13, [r10, #216]
    addsvs r3, r1, r6, lsl #19
    addeq r14, r11, #0xd00000
    orrle r13, r4, r0, ror #14
    andlt r8, r3, r3, rrx
    eorhi r2, r2, r3, lsr #2
    ldrbvs r5, [r10, #41]
    andle r11, r2, #0x1f00000
    cmpcs r5, r9, rrx
    orrmi r3, r0, #0x5d000000
    rsbhi r2, r13, #0xbb000000
    sbcls r9, r2, r4, ror #6
    ldrbcc r5, [r10, #1]
    andscc r13, r7, r11, rrx
    sublt r13, r6, r2, lsr #21
    cmnls r9, #0xcc
    cmpne r11, #0xfc
    orrmi r8, r13, r11, ror #27
    ldrgt r14, [r10, #224]
    bicls r3, r3, #0xc0000007
    tstmi r14, r6, lsl #25
    cmpne r11, r12, lsl #19
    bicvs r7, r4, #0x2000
    eors r0, r2, #0x42
    strbvc r1, [r10, #58]
    andcc r13, r1, r12, lsr #5
    subcc r9, r5, r5, lsr #9
    rsbvs r11, r7, r11, lsr #22
    sbcscc r1, r12, #0x1980000
    tstls r3, #0x2c400
    strbls r7, [r10, #33]
    subpl r5, r9, r7, lsl #20
    cmpvs r5, r9, asr #18
    subcc r0, r7, #0x36000
    sbcsle r8, r12, r0, lsl #11
    mvns r3, #0x320000
    ldrbvs r13, [r10, #251]
    sbcshi r0, r8, #0x1280
    rsbsne r6, r14, r14, lsr #12
    tstvc r0, r2, asr #26
    sbcle r8, r1, #0xa100000
    cmpmi r12, #0x8600
    ldrbmi r5, [r10, #25]
    sublt r0, r4, #0x30c0000
    mvnsgt r3, r9, lsr #28
    sbcspl r3, r11, r4, rrx
    eorslt r3, r4, r7, asr #1
    cmpcc r4, r3, rrx
    strbhi r8, [r10, #10]
    rsbscs r7, r5, r9, rrx
    subspl r12, r12, r7, ror #25
    rsbeq r5, r13, r14, lsr #5
    sbccs r6, r14, #0x38
    moveq r11, r8, asr #19
    ldrcc r14, [r10, #204]
    andvs r9, r0, r9, ror #23
    cmncs r9, #0x5b000
    andsmi r4, r4, r6, lsl #16
    adcshi r0, r1, r14, lsr #3
    adceq r12, r6, #0x48
    strge r13, [r10, #40]
    mvnne r5, r2, asr #28
    eorsvs r9, r6, #0xfc00
    tstcc r0, r1, ror #2
    orrgt r7, r8, #0x3c0
    rsble r13, r4, #0x21800000
    strblt r2, [r10, #15]
    sbcls r6, r13, #0xa0000006
    eorvc r5, r2, r14, rrx
    eors r8, r12, r2, lsl #23
    sbclt r13, r8, r3, asr #2
    eors r2, r2, #0x38c0000
    strb r7, [r10, #140]
    cmnhi r2, #0x54000000
    cmnlt r9, #0x2800000
    sbcsmi r12, r0, r14, lsr #21
    addle r6, r14, r5, rrx
    subvc r12, r1, r2, lsl #14
    ldrblt r5, [r10, #191]
    cmpvc r14, r0, lsl #2
    adcsgt r11, r13, #0xe5
    tsteq r8, #0xeb000000
    cmnne r12, #0x2f
    biceq r9, r7, #0x3000
    strbpl r6, [r10, #50]
    eorge r2, r4, #0x3
    sub r1, r5, #0x9
    addlt r8, r13, #0xdf00
    mvnvc r6, r13, asr #13
    movgt r12, r7, asr #19
    strblt r2, [r10, #28]
    orrsvs r3, r9, #0xdb
    sub r9, r5, #0x2
    rsbhi r2, r14, r0, ror #16
    orrsls r4, r8, #0x36c0
    orrseq r11, r11, r12, asr #30
    strbvs r9, [r10, #243]
    bic r13, r6, r0, lsr #17
    movseq r5, #0x8d
    subspl r8, r3, r9, rrx
    cmpmi r13, #0xce00
    cmpvs r8, #0x3a40000
    ldrbne r9, [r10, #82]
    bicsge r1, r5, #0x4
    eorsle r1, r9, r8, lsr #31
    mvnls r4, #0xe2
    addsmi r2, r9, r1, ror #18
    adcshi r12, r7, r4, ror #11
    ldrcc r0, [r10, #232]
    bicsge r11, r11, #0x338
    andvc r9, r12, r13, ror #29
    sbcseq r0, r7, r1, lsr #6
    adcscs r13, r2, r12, rrx
    rsbne r13, r7, r7, ror #23
    ldrbge r7, [r10, #221]
    orrslt r0, r8, r14, lsr #12
    cmnle r8, #0x200000
    adcseq r2, r3, #0x2d00000
    tstne r9, #0x2f
    orreq r14, r2, r2, rrx
    ldrbmi r9, [r10, #100]
    bicsmi r4, r5, r12, asr #10
    adccs r12, r3, r8, asr #3
    sbchi r6, r8, r12, ror #9
    subls r14, r5, r14, ror #22
    cmpcc r7, #0x2ec0000
    ldrbhi r5, [r10, #223]
    eorscc r8, r12, r5, lsl #12
    mvnshi r1, #0x49
    addlt r9, r13, #0x9900000
    addcs r5, r13, r11, rrx
    sbcshi r14, r12, #0x680
    ldrbcs r14, [r10, #175]
    cmnvs r9, #0xdb00
    sbcs r11, r7, #0xb90000
    orrslt r13, r1, #0xce0000
    subseq r1, r3, #0x7000000a
    mvneq r1, r1, asr #7
    ldrbls r8, [r10, #239]
    andpl r13, r7, #0xa8000001
    rsbhi r12, r13, r0, ror #9
    tsthi r7, r2, ror #5
    sbcpl r9, r3, r6, ror #30
    bicsvs r11, r4, r8, lsl #8
    strblt r12, [r10, #177]
    sbccs r1, r13, #0x4c000000
    bicle r14, r7, r7, lsl #27
    movge r2, r7, ror #12
    tstls r7, r2, lsr #16
    eorspl r3, r12, #0xc8
    strcc r7, [r10, #96]
    eorsvs r9, r2, r12, rrx
    andsge r5, r4, #0x280000
    subsge r5, r9, #0x6b0000
    orrvc r12, r12, #0x90000001
    sbcsle r2, r8, r3, rrx
    ldrle r7, [r10, #216]
    eorcs r9, r3, r2, lsr #30
    mvnsls r2, r13, rrx
    andhi r12, r2, r12, lsr #30
    suble r1, r4, #0x4400000
    rsbgt r0, r4, r9, asr #15
    strls r4, [r10, #124]
    biccc r1, r4, r8, ror #14
    mvnsne r4, r7, rrx
    tstls r0, r3, lsr #32
    cmneq r2, r4, lsr #21
    cmpvs r3, r14, lsl #10
    ldrbls r2, [r10, #134]
    addvc r5, r0, r3, rrx
    andsvc r9, r3, r0, lsl #17
    adcspl r13, r11, r7, rrx
    tstle r8, r0, ror #25
    andhi r3, r13, r11, lsl #19
    strhi r8, [r10, #192]
    bicscc r7, r14, #0x40000020
    adcls r7, r3, r0, ror #29
    bicsge r14, r8, r1, ror #25
    adcspl r1, r1, r3, lsl #19
    sbc r4, r5, #0x1b40
    ldrhi r12, [r10, #104]
    cmnvs r14, r3, lsl #7
    subsls r3, r5, r13, rrx
    addcc r11, r9, r8, lsr #1
    bicsge r5, r11, #0x2380000
    rsbhi r6, r11, r4, ror #2
    ldrbeq r8, [r10, #173]
    rsbsvs r0, r4, #0x4c
    adcspl r1, r6, #0x16000000
    tsteq r9, r3, lsl #20
    adccs r6, r4, #0xc400
    andscc r6, r13, r5, asr #16
    ldrcc r6, [r10, #240]
    eorle r9, r9, r7, ror #21
    cmnpl r7, #0x210
    subs r1, r6, #0x200000
    adcspl r5, r9, r6, lsr #2
    cmplt r14, r4, lsr #17
finish:
    b finish
