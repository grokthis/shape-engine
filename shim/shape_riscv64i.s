# shape_riscv64i.s — Shape engine in RISC-V RV64I (64-bit base integer).
#
# RV64I: 64-bit registers, still no multiply instruction.
# Same structural shortcuts, wider data path.
# The only difference from RV32I: 64-bit add/sub/shift, use slli/srli
# with 6-bit shift amounts, doubleword loads/stores.

.global asm_loop_accum_add
.global asm_loop_accum_const
.global asm_nested_accum
.global asm_pow
.global asm_add
.global asm_mul_rv64i
.global asm_div_rv64i

.text
.align 2

asm_loop_accum_add:
    mv      t0, a0
    mv      a0, a2
.Lloop_add_64i:
    bge     t0, a1, .Ldone_add_64i
    add     a0, a0, t0
    addi    t0, t0, 1
    j       .Lloop_add_64i
.Ldone_add_64i:
    ret

asm_loop_accum_const:
    sub     t0, a1, a0          # n = end - start
    li      t1, 0
.Lmul_64i:
    beqz    t0, .Lmul_64i_done
    andi    t2, t0, 1
    beqz    t2, .Lmul_64i_even
    add     t1, t1, a3
.Lmul_64i_even:
    slli    a3, a3, 1
    srli    t0, t0, 1
    j       .Lmul_64i
.Lmul_64i_done:
    add     a0, a2, t1
    ret

asm_nested_accum:
    li      t0, 0
.Lnest_64i:
    beqz    a0, .Lnest_64i_done
    andi    t1, a0, 1
    beqz    t1, .Lnest_64i_even
    add     t0, t0, a1
.Lnest_64i_even:
    slli    a1, a1, 1
    srli    a0, a0, 1
    j       .Lnest_64i
.Lnest_64i_done:
    add     a0, a2, t0
    ret

asm_pow:
    li      t0, 1
.Lpow_64i:
    beqz    a1, .Lpow_64i_done
    andi    t1, a1, 1
    beqz    t1, .Lpow_64i_sq
    # result *= base (shift-and-add)
    mv      t2, a0
    mv      t3, t0
    li      t0, 0
.Lpow_m1:
    beqz    t3, .Lpow_m1d
    andi    t4, t3, 1
    beqz    t4, .Lpow_m1e
    add     t0, t0, t2
.Lpow_m1e:
    slli    t2, t2, 1
    srli    t3, t3, 1
    j       .Lpow_m1
.Lpow_m1d:
.Lpow_64i_sq:
    # base *= base
    mv      t2, a0
    mv      t3, a0
    li      a0, 0
.Lpow_m2:
    beqz    t3, .Lpow_m2d
    andi    t4, t3, 1
    beqz    t4, .Lpow_m2e
    add     a0, a0, t2
.Lpow_m2e:
    slli    t2, t2, 1
    srli    t3, t3, 1
    j       .Lpow_m2
.Lpow_m2d:
    srli    a1, a1, 1
    j       .Lpow_64i
.Lpow_64i_done:
    mv      a0, t0
    ret

asm_add:
    add     a0, a0, a1
    ret

asm_mul_rv64i:
    mv      t0, a0
    li      a0, 0
.Lm_64i:
    beqz    t0, .Lm_64i_d
    andi    t1, t0, 1
    beqz    t1, .Lm_64i_e
    add     a0, a0, a1
.Lm_64i_e:
    slli    a1, a1, 1
    srli    t0, t0, 1
    j       .Lm_64i
.Lm_64i_d:
    ret

asm_div_rv64i:
    li      t0, 0
    li      t1, 63
.Ld_64i:
    bltz    t1, .Ld_64i_done
    sll     t2, a1, t1
    bgtu    t2, a0, .Ld_64i_skip
    sub     a0, a0, t2
    li      t3, 1
    sll     t3, t3, t1
    or      t0, t0, t3
.Ld_64i_skip:
    addi    t1, t1, -1
    j       .Ld_64i
.Ld_64i_done:
    mv      a0, t0
    ret
