# LA32 subset demo. Labels denote byte addresses in the generated ROM.
# Branch offsets are relative to the branch instruction, with no delay slot.
    addi.w r1, r0, 7
    addi.w r2, r0, 5
    add.w r3, r1, r2
    st.w r3, r0, 0
    ld.w r4, r0, 0
    sub.w r5, r4, r2
    beq r5, r1, logic
    addi.w r31, r0, -1
logic:
    and r6, r1, r2
    or r7, r1, r2
    xor r8, r1, r2
    addi.w r9, r0, -1
    slli.w r10, r9, 31
    srli.w r11, r10, 31
    srai.w r12, r10, 31
    lu12i.w r13, 0x12345
    addi.w r13, r13, 1656
    addi.w r14, r0, -2048
    addi.w r15, r0, 2047
    add.w r16, r14, r15
    sub.w r17, r0, r9
    add.w r26, r9, r17
    addi.w r0, r0, 123
    ld.w r0, r0, 0
    beq r1, r2, fail
    bne r1, r2, branch_taken
    addi.w r31, r0, -2
branch_taken:
    bne r1, r1, fail
    b loop_setup
    addi.w r31, r0, -3
loop_setup:
    b back_entry
back_target:
    addi.w r25, r0, 42
    b sum_setup
back_entry:
    b back_target
sum_setup:
    addi.w r18, r0, 0
    addi.w r19, r0, 1
    addi.w r20, r0, 6
sum_loop:
    add.w r18, r18, r19
    addi.w r19, r19, 1
    bne r19, r20, sum_loop
    st.w r18, r0, 4
    ld.w r21, r0, 4
    addi.w r22, r0, 15
    bne r21, r22, fail
    addi.w r23, r0, 16
    st.w r13, r23, -4
    ld.w r24, r23, -4
    beq r24, r13, success
fail:
    addi.w r31, r0, -1
    st.w r31, r0, 8
    b finish
success:
    addi.w r31, r0, 1
    st.w r31, r0, 8
    b finish
finish:
    b finish
