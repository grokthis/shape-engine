# shape_riscv32i.s — Shape engine in RISC-V RV32I (base integer only).
#
# RV32I: the minimal RISC-V. 32 registers, 32-bit, no multiply.
# Multiply must be synthesized from shifts and adds.
# This is the structural floor: what persistence looks like
# on the simplest possible RISC machine.
#
# Register conventions (RISC-V ABI):
#   a0-a7 (x10-x17): arguments and return values
#   t0-t6 (x5-x7, x28-x31): temporaries (caller-saved)
#   s0-s11 (x8-x9, x18-x27): saved (callee-saved)
#   ra (x1): return address
#   sp (x2): stack pointer
#   zero (x0): hardwired zero

.global asm_loop_accum_add
.global asm_loop_accum_const
.global asm_nested_accum
.global asm_pow
.global asm_add
.global asm_mul_rv32i
.global asm_div_rv32i

.text
.align 2

# ============================================================
# asm_loop_accum_add(start, end, init) -> sum
# a0 = start, a1 = end, a2 = init
# Returns: a0 = final accumulator
# ============================================================
asm_loop_accum_add:
    mv      t0, a0              # i = start
    mv      a0, a2              # acc = init
.Lloop_add_32i:
    bge     t0, a1, .Ldone_add_32i  # if i >= end, done
    add     a0, a0, t0          # acc += i
    addi    t0, t0, 1           # i++
    j       .Lloop_add_32i
.Ldone_add_32i:
    ret

# ============================================================
# asm_loop_accum_const(start, end, init, c) -> sum
# Structural shortcut: init + c * (end - start)
# No MUL instruction in RV32I. Synthesize from shift-and-add.
# a0 = start, a1 = end, a2 = init, a3 = c
# ============================================================
asm_loop_accum_const:
    sub     t0, a1, a0          # n = end - start
    # Multiply t0 * a3 without MUL (shift-and-add)
    li      t1, 0               # result = 0
.Lmul_loop_const:
    beqz    t0, .Lmul_done_const
    andi    t2, t0, 1           # if n is odd
    beqz    t2, .Lmul_even_const
    add     t1, t1, a3          # result += c
.Lmul_even_const:
    slli    a3, a3, 1           # c <<= 1
    srli    t0, t0, 1           # n >>= 1
    j       .Lmul_loop_const
.Lmul_done_const:
    add     a0, a2, t1          # init + n*c
    ret

# ============================================================
# asm_nested_accum(n, m, init) -> init + n*m
# Structural shortcut. Synthesized multiply.
# a0 = n, a1 = m, a2 = init
# ============================================================
asm_nested_accum:
    # Multiply a0 * a1 without MUL
    li      t0, 0               # result = 0
.Lmul_loop_nested:
    beqz    a0, .Lmul_done_nested
    andi    t1, a0, 1
    beqz    t1, .Lmul_even_nested
    add     t0, t0, a1
.Lmul_even_nested:
    slli    a1, a1, 1
    srli    a0, a0, 1
    j       .Lmul_loop_nested
.Lmul_done_nested:
    add     a0, a2, t0
    ret

# ============================================================
# asm_pow(base, exp) -> result
# Repeated squaring. Uses synthesized multiply.
# a0 = base, a1 = exp
# ============================================================
asm_pow:
    li      t0, 1               # result = 1
.Lpow_loop_32i:
    beqz    a1, .Lpow_done_32i
    andi    t1, a1, 1
    beqz    t1, .Lpow_even_32i
    # result *= base (shift-and-add multiply)
    mv      t2, a0              # multiplicand
    mv      t3, t0              # copy result
    li      t0, 0
.Lpow_mul1:
    beqz    t3, .Lpow_mul1_done
    andi    t4, t3, 1
    beqz    t4, .Lpow_mul1_even
    add     t0, t0, t2
.Lpow_mul1_even:
    slli    t2, t2, 1
    srli    t3, t3, 1
    j       .Lpow_mul1
.Lpow_mul1_done:
.Lpow_even_32i:
    # base *= base (shift-and-add multiply)
    mv      t2, a0
    mv      t3, a0
    li      a0, 0
.Lpow_mul2:
    beqz    t3, .Lpow_mul2_done
    andi    t4, t3, 1
    beqz    t4, .Lpow_mul2_even
    add     a0, a0, t2
.Lpow_mul2_even:
    slli    t2, t2, 1
    srli    t3, t3, 1
    j       .Lpow_mul2
.Lpow_mul2_done:
    srli    a1, a1, 1
    j       .Lpow_loop_32i
.Lpow_done_32i:
    mv      a0, t0
    ret

# ============================================================
# Primitives
# ============================================================
asm_add:
    add     a0, a0, a1
    ret

# RV32I has no MUL. Shift-and-add.
asm_mul_rv32i:
    mv      t0, a0
    li      a0, 0
.Lmul_prim:
    beqz    t0, .Lmul_prim_done
    andi    t1, t0, 1
    beqz    t1, .Lmul_prim_even
    add     a0, a0, a1
.Lmul_prim_even:
    slli    a1, a1, 1
    srli    t0, t0, 1
    j       .Lmul_prim
.Lmul_prim_done:
    ret

# RV32I has no DIV. Restoring division.
asm_div_rv32i:
    li      t0, 0               # quotient = 0
    li      t1, 31              # bit position
.Ldiv_loop:
    bltz    t1, .Ldiv_done
    sll     t2, a1, t1          # divisor << bit
    bgt     t2, a0, .Ldiv_skip  # if shifted divisor > remainder, skip
    sub     a0, a0, t2          # remainder -= shifted divisor
    li      t3, 1
    sll     t3, t3, t1
    or      t0, t0, t3          # quotient |= (1 << bit)
.Ldiv_skip:
    addi    t1, t1, -1
    j       .Ldiv_loop
.Ldiv_done:
    mv      a0, t0
    ret
