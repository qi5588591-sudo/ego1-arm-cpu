.syntax unified
.arch armv7-a
.arm
.text
.global _start
_start:
    mov r10, #0x0
    orr r10, r10, #0x1000
    mov r0, #0x7
    add r1, r0, #0x5
    add r2, r1, r0
    sub r3, r2, #0x7
    str r3, [r10, #0]
    ldr r4, [r10, #0]
    add r5, r4, #0x3
    str r5, [r10, #4]
    ldr r6, [r10, #4]
    str r6, [r10, #16]
    mov r8, #0xf
    cmp r6, r8
    bne fail
    mov r7, #0x2a
    mov r8, #0x1
    mov r9, #0x2
    add r11, r7, #0x1
    mov r8, #0x2b
    cmp r11, r8
    bne fail
    cmp r0, r0
    movne r4, #0x63
    addeq r1, r4, #0x0
    mov r8, #0xc
    cmp r1, r8
    bne fail
    mvn r6, #0x0
    adds r6, r6, #0x1
    adc r7, r6, #0x0
    mov r8, #0x1
    cmp r7, r8
    bne fail
    cmp r7, #0x1
    beq taken
    str r7, [r10, #0]
    .word 0xe7f000f0
taken:
    mov r8, #0xc
    cmp r3, r8
    bne fail
    mov r6, #0x80000000
    subs r6, r6, #0x1
    tst r6, #0x0
    movvs r7, #0x1
    mov r8, #0x1
    cmp r7, r8
    bne fail
    mov r0, #0x0
    cmp r0, r0
    ldrne r4, [r0, #0]
    add r7, r4, #0x1
    mov r8, #0xd
    cmp r7, r8
    bne fail
    add r9, r15, #0x14
    str r9, [r10, #20]
    mov r9, #0x0
    ldr r9, [r10, #20]
    bx r9
    str r9, [r10, #0]
    .word 0xe7f000f0
indirect:
    ldr r7, [r10, #16]
    mov r8, #0xf
    cmp r7, r8
    bne fail
    bl subroutine
    mov r8, #0xc
    cmp r0, r8
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
    mov r0, #0x9
    add r0, r0, #0x3
    bx r14
