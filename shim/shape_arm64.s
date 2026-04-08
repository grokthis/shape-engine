// shape_arm64.s — Shape engine in ARM64 assembly.
//
// The thinnest possible shim. No compiler, no runtime, no abstraction.
// Each function IS the structure it computes.
//
// Register conventions (ARM64 / AAPCS64):
//   x0-x7:  arguments and return values
//   x8:     indirect result location
//   x9-x15: scratch (caller-saved)
//   x19-x28: callee-saved
//   x29:    frame pointer
//   x30:    link register (return address)
//   sp:     stack pointer

.global _asm_loop_accum_add
.global _asm_loop_accum_const
.global _asm_nested_accum
.global _asm_pow
.global _asm_add
.global _asm_mul
.global _asm_div

.text
.align 4

// ============================================================
// asm_loop_accum_add(start, end, init) -> sum
//
// for i in range(start, end) { acc += i }
//
// x0 = start, x1 = end, x2 = init (accumulator)
// Returns: x0 = final accumulator
//
// This IS a counter (x0) feeding an accumulator (x2) with
// a feedback loop. Two registers. One branch.
// ============================================================
_asm_loop_accum_add:
    mov     x9, x0          // i = start
    mov     x0, x2          // acc = init
.Lloop_add:
    cmp     x9, x1          // i < end?
    b.ge    .Lloop_add_done
    add     x0, x0, x9      // acc += i
    add     x9, x9, #1      // i++
    b       .Lloop_add
.Lloop_add_done:
    ret

// ============================================================
// asm_loop_accum_const(start, end, init, c) -> sum
//
// for i in range(start, end) { acc += c }
//
// x0 = start, x1 = end, x2 = init, x3 = constant
// Returns: x0 = final accumulator
//
// Structural shortcut: acc += c * (end - start).
// The loop IS a multiply. One instruction replaces N iterations.
// ============================================================
_asm_loop_accum_const:
    sub     x9, x1, x0      // n = end - start
    mul     x9, x9, x3      // n * c
    add     x0, x2, x9      // init + n*c
    ret

// ============================================================
// asm_nested_accum(n, m, init) -> count
//
// for i in range(n) { for j in range(m) { acc++ } }
//
// x0 = n, x1 = m, x2 = init
// Returns: x0 = final accumulator
//
// Structural shortcut: acc += n * m.
// Nested loop IS a multiply. Two dimensions collapse to one op.
// ============================================================
_asm_nested_accum:
    mul     x9, x0, x1      // n * m
    add     x0, x2, x9      // init + n*m
    ret

// ============================================================
// asm_pow(base, exp) -> result
//
// base^exp via repeated squaring.
//
// x0 = base, x1 = exp
// Returns: x0 = result
//
// Structural: exponentiation IS repeated squaring.
// O(log n) multiplies instead of O(n).
// ============================================================
_asm_pow:
    mov     x9, #1          // result = 1
.Lpow_loop:
    cbz     x1, .Lpow_done  // if exp == 0, done
    tst     x1, #1          // if exp is odd
    b.eq    .Lpow_even
    mul     x9, x9, x0      // result *= base
.Lpow_even:
    mul     x0, x0, x0      // base *= base (square)
    lsr     x1, x1, #1      // exp >>= 1
    b       .Lpow_loop
.Lpow_done:
    mov     x0, x9           // return result
    ret

// ============================================================
// asm_add(a, b) -> a + b
// x0 = a, x1 = b. Returns x0.
// One instruction. This IS the hardware.
// ============================================================
_asm_add:
    add     x0, x0, x1
    ret

// ============================================================
// asm_mul(a, b) -> a * b
// ============================================================
_asm_mul:
    mul     x0, x0, x1
    ret

// ============================================================
// asm_div(a, b) -> a / b (integer, truncated toward zero)
// ============================================================
_asm_div:
    sdiv    x0, x0, x1
    ret
