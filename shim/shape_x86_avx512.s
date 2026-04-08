# shape_x86_avx512.s — Shape engine with AVX-512 (2017, Skylake-X).
#
# AVX-512: 512-bit ZMM registers (zmm0-zmm31).
# 8x 64-bit integers per register. 8 opmask registers (k0-k7)
# for predicated execution. The widest deployed SIMD.
#
# Wave propagation at 8x throughput. Validate 8 deps per cycle.
# The shape engine's inner loop (propagateFrom) processes 8
# dependents simultaneously.

.global _asm_avx512_accum
.global _asm_avx512_propagate
.global _asm_avx512_validate

.text
.align 6

# ============================================================
# asm_avx512_accum(array, len) -> sum
# 8 elements per cycle.
# rdi = pointer, rsi = length
# ============================================================
_asm_avx512_accum:
    vpxorq  %zmm0, %zmm0, %zmm0    # acc = 8x zero
    movq    %rsi, %rcx
    shrq    $3, %rcx                 # octets = count / 8
    jz      .L512_tail
.L512_loop:
    vmovdqu64 (%rdi), %zmm1         # load 8 x int64
    vpaddq  %zmm1, %zmm0, %zmm0     # accumulate
    addq    $64, %rdi
    decq    %rcx
    jnz     .L512_loop
.L512_tail:
    # Reduce 8 lanes to 1
    vextracti64x4 $1, %zmm0, %ymm1  # high 256 bits
    vpaddq  %ymm1, %ymm0, %ymm0     # reduce to 4
    vextracti128 $1, %ymm0, %xmm1   # high 128
    vpaddq  %xmm1, %xmm0, %xmm0     # reduce to 2
    vpshufd $0x4e, %xmm0, %xmm1
    vpaddq  %xmm1, %xmm0, %xmm0     # reduce to 1
    vmovq   %xmm0, %rax
    # Remainder
    andq    $7, %rsi
    jz      .L512_done
.L512_rem:
    addq    (%rdi), %rax
    addq    $8, %rdi
    decq    %rsi
    jnz     .L512_rem
.L512_done:
    vzeroupper
    ret

# ============================================================
# asm_avx512_propagate(dep_ticks, new_tick, count) -> updated
# 8 dependents per cycle with opmask predication.
# rdi = tick array, rsi = new_tick, rdx = count
#
# This is the shape engine's Edit wave at maximum throughput.
# On Sapphire Rapids: 8 dependents stamped per clock cycle.
# At 4 GHz: 32 billion dependent updates per second.
# ============================================================
_asm_avx512_propagate:
    xorq    %rax, %rax
    vpbroadcastq %rsi, %zmm2         # zmm2 = 8x new_tick
    movq    %rdx, %rcx
    shrq    $3, %rcx
    jz      .L512_prop_tail
.L512_prop_loop:
    vmovdqu64 (%rdi), %zmm0         # load 8 ticks
    vpcmpq  $1, %zmm0, %zmm2, %k1   # k1 = mask where new > old
    vmovdqu64 %zmm2, (%rdi){%k1}    # write new_tick where masked
    kmovb   %k1, %r8d
    popcnt  %r8d, %r8d
    addq    %r8, %rax
    addq    $64, %rdi
    decq    %rcx
    jnz     .L512_prop_loop
.L512_prop_tail:
    andq    $7, %rdx
    jz      .L512_prop_done
.L512_prop_rem:
    cmpq    %rsi, (%rdi)
    jge     .L512_prop_skip
    movq    %rsi, (%rdi)
    incq    %rax
.L512_prop_skip:
    addq    $8, %rdi
    decq    %rdx
    jnz     .L512_prop_rem
.L512_prop_done:
    vzeroupper
    ret

# ============================================================
# asm_avx512_validate(dep_flags, count) -> violations
# 8 deps per cycle. Count dangling references.
# rdi = flag array (int64), rsi = count
# ============================================================
_asm_avx512_validate:
    xorq    %rax, %rax
    vpxorq  %zmm2, %zmm2, %zmm2     # zero
    movq    %rsi, %rcx
    shrq    $3, %rcx
    jz      .L512_val_tail
.L512_val_loop:
    vmovdqu64 (%rdi), %zmm0
    vpcmpeqq %zmm2, %zmm0, %k1      # mask where flag == 0
    kmovb   %k1, %r8d
    popcnt  %r8d, %r8d
    addq    %r8, %rax
    addq    $64, %rdi
    decq    %rcx
    jnz     .L512_val_loop
.L512_val_tail:
    andq    $7, %rsi
    jz      .L512_val_done
.L512_val_rem:
    cmpq    $0, (%rdi)
    jne     .L512_val_ok
    incq    %rax
.L512_val_ok:
    addq    $8, %rdi
    decq    %rsi
    jnz     .L512_val_rem
.L512_val_done:
    vzeroupper
    ret
