.syntax unified
.arch armv7-a
.arch_extension idiv
.arm
.text
.global _start
_start:
    mov r10, #0x0
    orr r10, r10, #0x1000
    mov r6, #0xc
    str r6, [r10, #0]
    mov r6, #0xf
    str r6, [r10, #4]
    mov r0, #0x7
    mov r1, #0x3
    mul r0, r0, r1
    add r2, r0, r1
    sdiv r3, r2, r1
    mul r4, r3, r3
    udiv r5, r4, r3
    str r5, [r10, #16]
    ldr r6, [r10, #16]
    mul r7, r6, r1
    str r7, [r10, #20]
    ldr r6, [r10, #20]
    udiv r6, r6, r1
    mov r8, #0x8
    cmp r6, r8
    bne fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    subs r6, r6, #0x1
    muls r4, r6, r1
    adc r7, r4, #0x0
    mov r8, #0xfe
    orr r8, r8, #0xff00
    orr r8, r8, #0xff0000
    orr r8, r8, #0x7f000000
    cmp r7, r8
    bne fail
    cmp r0, r0
    beq mdu_taken
    sdiv r4, r6, r1
    mul r4, r6, r1
    .word 0xe7f000f0
mdu_taken:
    mov r6, #0xf9
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0x3
    mul r4, r6, r7
    mov r8, #0xeb
    orr r8, r8, #0xff00
    orr r8, r8, #0xff0000
    orr r8, r8, #0xff000000
    cmp r4, r8
    bne fail
    mov r6, #0xff
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0xff
    orr r7, r7, #0xff00
    orr r7, r7, #0xff0000
    orr r7, r7, #0xff000000
    mul r4, r6, r7
    mov r8, #0x1
    cmp r4, r8
    bne fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    mov r7, #0x2
    mul r4, r6, r7
    mov r8, #0x0
    cmp r4, r8
    bne fail
    mov r6, #0xf9
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0x3
    sdiv r4, r6, r7
    mov r8, #0xfe
    orr r8, r8, #0xff00
    orr r8, r8, #0xff0000
    orr r8, r8, #0xff000000
    cmp r4, r8
    bne fail
    mov r6, #0x7
    mov r7, #0xfd
    orr r7, r7, #0xff00
    orr r7, r7, #0xff0000
    orr r7, r7, #0xff000000
    sdiv r4, r6, r7
    mov r8, #0xfe
    orr r8, r8, #0xff00
    orr r8, r8, #0xff0000
    orr r8, r8, #0xff000000
    cmp r4, r8
    bne fail
    mov r6, #0xf9
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0xfd
    orr r7, r7, #0xff00
    orr r7, r7, #0xff0000
    orr r7, r7, #0xff000000
    sdiv r4, r6, r7
    mov r8, #0x2
    cmp r4, r8
    bne fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    mov r7, #0xff
    orr r7, r7, #0xff00
    orr r7, r7, #0xff0000
    orr r7, r7, #0xff000000
    sdiv r4, r6, r7
    mov r8, #0x0
    orr r8, r8, #0x80000000
    cmp r4, r8
    bne fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    mov r7, #0x1
    sdiv r4, r6, r7
    mov r8, #0x0
    orr r8, r8, #0x80000000
    cmp r4, r8
    bne fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    mov r7, #0x0
    sdiv r4, r6, r7
    mov r8, #0x0
    cmp r4, r8
    bne fail
    mov r6, #0x9
    mov r7, #0x0
    sdiv r4, r6, r7
    mov r8, #0x0
    cmp r4, r8
    bne fail
    mov r6, #0xf9
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0x3
    udiv r4, r6, r7
    mov r8, #0x53
    orr r8, r8, #0x5500
    orr r8, r8, #0x550000
    orr r8, r8, #0x55000000
    cmp r4, r8
    bne fail
    mov r6, #0xff
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0x0
    orr r7, r7, #0x80000000
    udiv r4, r6, r7
    mov r8, #0x1
    cmp r4, r8
    bne fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    mov r7, #0xff
    orr r7, r7, #0xff00
    orr r7, r7, #0xff0000
    orr r7, r7, #0xff000000
    udiv r4, r6, r7
    mov r8, #0x0
    cmp r4, r8
    bne fail
    mov r6, #0xff
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0x0
    udiv r4, r6, r7
    mov r8, #0x0
    cmp r4, r8
    bne fail
    mov r6, #0x0
    mov r7, #0x1
    udiv r4, r6, r7
    mov r8, #0x0
    cmp r4, r8
    bne fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    subs r6, r6, #0x1
    mov r7, #0x0
    muls r4, r6, r7
    bne fail
    bmi fail
    bcc fail
    bvc fail
    mov r6, #0x0
    orr r6, r6, #0x80000000
    mov r7, #0x1
    muls r4, r6, r7
    bpl fail
    beq fail
    bcc fail
    bvc fail
    mov r4, #0x2a
    cmp r4, r4
    mulsne r4, r6, r7
    sdivne r4, r6, r7
    udivne r4, r6, r7
    mov r8, #0x2a
    cmp r4, r8
    bne fail
    mov r0, #0x15
    mov r1, #0x3
    sdiv r0, r0, r1
    mul r0, r0, r1
    udiv r1, r0, r1
    str r1, [r10, #40]
    ldr r4, [r10, #40]
    mov r8, #0x7
    cmp r4, r8
    bne fail
    mov r0, #0x1
    str r0, [r10, #8]
finish:
    b finish
fail:
    mov r0, #0xee
    str r0, [r10, #8]
fail_halt:
    b fail_halt
