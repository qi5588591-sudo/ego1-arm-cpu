.syntax unified
.arch armv7-a
.arch_extension idiv
.arm
.text
.global _start
_start:
    mov r10, #0x0
    orr r10, r10, #0x1000
    mov r5, #0x7
    mov r8, #0x7
    cmp r5, r8
    bne fail
    mov r0, #0x7
    add r5, r0, #0x5
    mov r8, #0xc
    cmp r5, r8
    bne fail
    mov r0, #0xc
    sub r5, r0, #0x5
    mov r8, #0x7
    cmp r5, r8
    bne fail
    mov r0, #0x7
    rsb r5, r0, #0x14
    mov r8, #0xd
    cmp r5, r8
    bne fail
    mov r0, #0x7
    cmp r0, r0
    adc r5, r0, #0x5
    mov r8, #0xd
    cmp r5, r8
    bne fail
    mov r0, #0x7
    mov r1, #0x9
    cmp r0, r1
    sbc r5, r0, #0x2
    mov r8, #0x4
    cmp r5, r8
    bne fail
    mov r6, #0x6
    mov r7, #0x3
    and r5, r6, r7
    mov r8, #0x2
    cmp r5, r8
    bne fail
    orr r5, r6, r7
    mov r8, #0x7
    cmp r5, r8
    bne fail
    eor r5, r6, r7
    mov r8, #0x5
    cmp r5, r8
    bne fail
    bic r5, r6, r7
    mov r8, #0x4
    cmp r5, r8
    bne fail
    mvn r5, #0x7
    mov r8, #0xf8
    orr r8, r8, #0xff00
    orr r8, r8, #0xff0000
    orr r8, r8, #0xff000000
    cmp r5, r8
    bne fail
    mov r0, #0x7
    cmp r0, r0
    mvn r6, #0x0
    cmn r6, #0x1
    mov r6, #0x6
    tst r6, #0x2
    mov r2, #0xc
    str r2, [r10, #0]
    ldr r3, [r10, #0]
    mov r8, #0xc
    cmp r3, r8
    bne fail
    mov r6, #0x12
    orr r6, r6, #0x100
    strb r6, [r10, #16]
    ldrb r4, [r10, #16]
    mov r8, #0x12
    cmp r4, r8
    bne fail
    b b_here
    mov r0, #0x11
    mov r0, #0x22
b_here:
    bl sub1
    mov r8, #0x48
    orr r8, r8, #0x100
    cmp r14, r8
    bne fail
    mov r6, #0x6
    mov r7, #0x3
    mul r5, r6, r7
    mov r8, #0x12
    cmp r5, r8
    bne fail
    mov r6, #0xf9
    orr r6, r6, #0xff00
    orr r6, r6, #0xff0000
    orr r6, r6, #0xff000000
    mov r7, #0x3
    sdiv r5, r6, r7
    mov r8, #0xfe
    orr r8, r8, #0xff00
    orr r8, r8, #0xff0000
    orr r8, r8, #0xff000000
    cmp r5, r8
    bne fail
    mov r6, #0x15
    mov r7, #0x3
    udiv r5, r6, r7
    mov r8, #0x7
    cmp r5, r8
    bne fail
    mov r1, #0xf
    str r1, [r10, #4]
    mov r0, #0x1
    str r0, [r10, #8]
finish:
    b finish
fail:
    mov r0, #0xee
    str r0, [r10, #8]
fail_halt:
    b fail_halt
sub1:
    bx r14
