# shape_riscv_m.s — Shape engine in RISC-V RV64IM (M extension: multiply/divide).
#
# The M extension adds: MUL, MULH, MULHU, MULHSU, DIV, DIVU, REM, REMU.
# With hardware multiply, the structural shortcuts become trivially short.
# This is what the RV32I shift-and-add loops were always computing.
# The M extension makes the structure visible in the ISA.

.global asm_loop_accum_add
.global asm_loop_accum_const
.global asm_nested_accum
.global asm_pow
.global asm_add
.global asm_mul
.global asm_div

.text
.align 2

asm_loop_accum_add:
    mv      t0, a0
    mv      a0, a2
.Lloop_m:
    bge     t0, a1, .Ldone_m
    add     a0, a0, t0
    addi    t0, t0, 1
    j       .Lloop_m
.Ldone_m:
    ret

# Structural shortcut: init + c * (end - start). Three instructions.
asm_loop_accum_const:
    sub     t0, a1, a0          # n = end - start
    mul     t0, t0, a3          # n * c
    add     a0, a2, t0          # init + n*c
    ret

# Structural shortcut: init + n * m. Three instructions.
asm_nested_accum:
    mul     t0, a0, a1          # n * m
    add     a0, a2, t0          # init + n*m
    ret

# Repeated squaring with hardware MUL.
asm_pow:
    li      t0, 1               # result = 1
.Lpow_m:
    beqz    a1, .Lpow_m_done
    andi    t1, a1, 1
    beqz    t1, .Lpow_m_sq
    mul     t0, t0, a0          # result *= base
.Lpow_m_sq:
    mul     a0, a0, a0          # base *= base
    srli    a1, a1, 1           # exp >>= 1
    j       .Lpow_m
.Lpow_m_done:
    mv      a0, t0
    ret

asm_add:
    add     a0, a0, a1
    ret

asm_mul:
    mul     a0, a0, a1
    ret

asm_div:
    div     a0, a0, a1
    ret
