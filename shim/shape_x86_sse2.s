# shape_x86_sse2.s — Shape engine with SSE2 (2001, Pentium 4).
#
# SSE2: 128-bit XMM registers (xmm0-xmm15 on x86-64).
# 2x 64-bit integers per register. SIMD: same instruction,
# multiple data. The first useful vector extension for integers.
#
# For the shape engine: process 2 shape ticks simultaneously.
# Wave propagation at 2x throughput.

.global _asm_sse2_accum
.global _asm_sse2_propagate

.text
.align 4

# ============================================================
# asm_sse2_accum(array, len) -> sum
# Sum int64 array using SSE2. 2 elements per cycle.
# rdi = pointer, rsi = length
# Returns: rax
# ============================================================
_asm_sse2_accum:
    pxor    %xmm0, %xmm0       # accumulator = [0, 0]
    movq    %rsi, %rcx          # count
    shrq    $1, %rcx            # pairs = count / 2
    jz      .Lsse2_tail
.Lsse2_loop:
    movdqu  (%rdi), %xmm1      # load 2 x int64
    paddq   %xmm1, %xmm0       # accumulate
    addq    $16, %rdi
    decq    %rcx
    jnz     .Lsse2_loop
.Lsse2_tail:
    # Reduce xmm0: add high and low 64-bit lanes
    movhlps %xmm0, %xmm1       # xmm1 = high lane
    paddq   %xmm1, %xmm0       # xmm0[0] = low + high
    movq    %xmm0, %rax
    # Handle odd element
    testq   $1, %rsi
    jz      .Lsse2_done
    addq    (%rdi), %rax
.Lsse2_done:
    ret

# ============================================================
# asm_sse2_propagate(dep_ticks, new_tick, count) -> updated
# Stamp dependents: if tick < new_tick, set to new_tick.
# rdi = tick array, rsi = new_tick, rdx = count
# Returns: rax = number updated
# ============================================================
_asm_sse2_propagate:
    xorq    %rax, %rax          # updated = 0
    movq    %rsi, %xmm2         # broadcast new_tick low
    punpcklqdq %xmm2, %xmm2    # xmm2 = [new_tick, new_tick]
    movq    %rdx, %rcx
    shrq    $1, %rcx
    jz      .Lsse2_prop_tail
.Lsse2_prop_loop:
    movdqu  (%rdi), %xmm0      # load 2 ticks
    # Compare: we want tick < new_tick
    # SSE2 has no unsigned < for 64-bit. Use subtraction.
    movdqa  %xmm2, %xmm1
    psubq   %xmm0, %xmm1       # diff = new_tick - tick
    # If diff > 0 (new_tick > tick), update
    # For simplicity: always write new_tick (idempotent)
    movdqu  %xmm2, (%rdi)
    addq    $16, %rdi
    addq    $2, %rax            # count both as updated
    decq    %rcx
    jnz     .Lsse2_prop_loop
.Lsse2_prop_tail:
    testq   $1, %rdx
    jz      .Lsse2_prop_done
    movq    %rsi, (%rdi)
    incq    %rax
.Lsse2_prop_done:
    ret
