.syntax unified
.arch armv7-a
.arm
.text
.global _start
_start:
    mov r10, #0x0
    orr r10, r10, #0x1000
    mov r0, #0x7
    add r2, r0, #0x5
    str r2, [r10, #0]
    ldr r3, [r10, #0]
    mov r8, #0xc
    cmp r3, r8
    bne fail
    subs r4, r2, #0xc
    moveq r5, #0x1
    movne r5, #0x63
    mov r8, #0x1
    cmp r5, r8
    bne fail
    mvn r6, #0x0
    adds r4, r6, #0x1
    adc r5, r0, #0x0
    mov r8, #0x8
    cmp r5, r8
    bne fail
    sbc r5, r0, #0x2
    mov r8, #0x5
    cmp r5, r8
    bne fail
    mov r6, #0x0
    cmp r6, #0x1
    sbc r5, r0, #0x2
    mov r8, #0x4
    cmp r5, r8
    bne fail
    rsb r5, r0, #0x14
    mov r8, #0xd
    cmp r5, r8
    bne fail
    mov r6, #0xf0
    mov r7, #0x3c
    and r4, r6, r7
    mov r8, #0x30
    cmp r4, r8
    bne fail
    orr r4, r6, r7
    mov r8, #0xfc
    cmp r4, r8
    bne fail
    eor r4, r6, r7
    mov r8, #0xcc
    cmp r4, r8
    bne fail
    bic r4, r6, r7
    mov r8, #0xc0
    cmp r4, r8
    bne fail
    mvn r6, #0x0
    cmn r6, #0x1
    bne fail
    bcc fail
    mov r6, #0xf0
    tst r6, #0x80
    beq fail
    mov r6, #0x80
    movs r4, r6, lsl #24
    mov r8, #0x0
    orr r8, r8, #0x80000000
    cmp r4, r8
    bne fail
    movs r4, r4, lsr #32
    bcc fail
    mov r8, #0x0
    cmp r4, r8
    bne fail
    mov r4, #0x0
    orr r4, r4, #0x80000000
    movs r4, r4, asr #32
    mov r8, #0xff
    orr r8, r8, #0xff00
    orr r8, r8, #0xff0000
    orr r8, r8, #0xff000000
    cmp r4, r8
    bne fail
    mov r6, #0x81
    movs r4, r6, ror #4
    mov r8, #0x8
    orr r8, r8, #0x10000000
    cmp r4, r8
    bne fail
    mov r6, #0x2
    cmp r0, r0
    movs r4, r6, rrx
    mov r8, #0x1
    orr r8, r8, #0x80000000
    cmp r4, r8
    bne fail
    mvn r6, #0x0
    str r6, [r10, #16]
    mov r6, #0x12
    strb r6, [r10, #16]
    ldrb r4, [r10, #16]
    mov r8, #0x12
    cmp r4, r8
    bne fail
    mov r6, #0x34
    strb r6, [r10, #17]
    ldrb r4, [r10, #17]
    mov r8, #0x34
    cmp r4, r8
    bne fail
    mov r6, #0x56
    strb r6, [r10, #18]
    ldrb r4, [r10, #18]
    mov r8, #0x56
    cmp r4, r8
    bne fail
    mov r6, #0x78
    strb r6, [r10, #19]
    ldrb r4, [r10, #19]
    mov r8, #0x78
    cmp r4, r8
    bne fail
    ldr r7, [r10, #16]
    mov r8, #0x12
    orr r8, r8, #0x3400
    orr r8, r8, #0x560000
    orr r8, r8, #0x78000000
    cmp r7, r8
    bne fail
    add r9, r10, #0x14
    ldrb r4, [r9, #-3]
    mov r8, #0x34
    cmp r4, r8
    bne fail
    cmp r0, r0
    strne r6, [r10, #0]
    ldrne r4, [r10, #0]
    mov r4, r15
    mov r8, #0x20
    orr r8, r8, #0x200
    cmp r4, r8
    bne fail
    mov r0, #0x9
    bl subroutine
    mov r8, #0xc
    cmp r0, r8
    bne fail
    mov r8, #0x34
    orr r8, r8, #0x200
    cmp r14, r8
    bne fail
    mov r0, #0x1
    mov r1, #0x0
loop:
    add r1, r1, r0
    add r0, r0, #0x1
    cmp r0, #0x6
    blt loop
    str r1, [r10, #4]
    mov r8, #0xf
    cmp r1, r8
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
subroutine:
    add r0, r0, #0x3
    bx r14
