.syntax unified
.arch armv7-a
.arm
.text
.global _start
_start:
    mov r10, #0x0
    orr r10, r10, #0x1000
    mov r0, #0x2a
    str r0, [r10, #0]
    add r1, r0, #0x1
    cmp r0, #0x2a
    mov r9, #0x1
    bx r9
    b escape
    str r0, [r10, #8]
escape:
    adds r3, r0, #0x1
    str r0, [r10, #8]
end:
    b end
