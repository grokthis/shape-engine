# shape_x86_avx2.s — Shape engine with AVX2 (2013, Haswell).
#
# AVX2: 256-bit YMM registers (ymm0-ymm15).
# 4x 64-bit integers per register. Non-destructive 3-operand form.
# The workhorse SIMD for modern x86. Most deployed servers have this.
#
# Wave propagation at 4x throughput. Validate 4 deps per cycle.

.global _asm_avx2_accum
.global _asm_avx2_propagate
.global _asm_avx2_validate

.text
.align 5

# ============================================================
# asm_avx2_accum(array, len) -> sum
# Sum int64 array. 4 elements per cycle.
# rdi = pointer, rsi = length
# ============================================================
_asm_avx2_accum:
    vpxor   %ymm0, %ymm0, %ymm0   # acc = [0,0,0,0]
    movq    %rsi, %rcx
    shrq    $2, %rcx                # quads = count / 4
    jz      .Lavx2_tail
.Lavx2_loop:
    vmovdqu (%rdi), %ymm1          # load 4 x int64
    vpaddq  %ymm1, %ymm0, %ymm0   # accumulate
    addq    $32, %rdi
    decq    %rcx
    jnz     .Lavx2_loop
.Lavx2_tail:
    # Reduce 4 lanes to 1
    vextracti128 $1, %ymm0, %xmm1  # high 128 bits
    vpaddq  %xmm1, %xmm0, %xmm0   # reduce to 2 lanes
    vpshufd $0x4e, %xmm0, %xmm1    # swap high/low 64-bit
    vpaddq  %xmm1, %xmm0, %xmm0   # reduce to 1 lane
    vmovq   %xmm0, %rax
    # Handle remainder (0-3 elements)
    andq    $3, %rsi
    jz      .Lavx2_done
.Lavx2_rem:
    addq    (%rdi), %rax
    addq    $8, %rdi
    decq    %rsi
    jnz     .Lavx2_rem
.Lavx2_done:
    vzeroupper
    ret

# ============================================================
# asm_avx2_propagate(dep_ticks, new_tick, count) -> updated
# 4 dependents per cycle.
# rdi = tick array, rsi = new_tick, rdx = count
# ============================================================
_asm_avx2_propagate:
    xorq    %rax, %rax
    vmovq   %rsi, %xmm2
    vpbroadcastq %xmm2, %ymm2      # ymm2 = [new, new, new, new]
    movq    %rdx, %rcx
    shrq    $2, %rcx
    jz      .Lavx2_prop_tail
.Lavx2_prop_loop:
    vmovdqu (%rdi), %ymm0          # load 4 ticks
    # Compare: pcmpgtq (signed >). new_tick > old_tick?
    vpcmpgtq %ymm0, %ymm2, %ymm1  # mask where new > old
    # Blend: write new_tick where mask is set
    vpblendvb %ymm1, %ymm2, %ymm0, %ymm0
    vmovdqu %ymm0, (%rdi)
    # Count updates (popcnt on mask)
    vpmovmskb %ymm1, %r8d
    popcnt  %r8d, %r8d
    shrq    $3, %r8                 # 8 bytes per lane
    addq    %r8, %rax
    addq    $32, %rdi
    decq    %rcx
    jnz     .Lavx2_prop_loop
.Lavx2_prop_tail:
    andq    $3, %rdx
    jz      .Lavx2_prop_done
.Lavx2_prop_rem:
    cmpq    %rsi, (%rdi)
    jge     .Lavx2_prop_skip
    movq    %rsi, (%rdi)
    incq    %rax
.Lavx2_prop_skip:
    addq    $8, %rdi
    decq    %rdx
    jnz     .Lavx2_prop_rem
.Lavx2_prop_done:
    vzeroupper
    ret

# ============================================================
# asm_avx2_validate(dep_flags, count) -> violations
# Check array of existence flags (0 = missing, nonzero = exists).
# 4 flags per cycle. Count zeros = dangling references.
# rdi = flag array (int64), rsi = count
# ============================================================
_asm_avx2_validate:
    xorq    %rax, %rax
    vpxor   %ymm2, %ymm2, %ymm2    # zero vector
    movq    %rsi, %rcx
    shrq    $2, %rcx
    jz      .Lavx2_val_tail
.Lavx2_val_loop:
    vmovdqu (%rdi), %ymm0
    vpcmpeqq %ymm2, %ymm0, %ymm1   # mask where flag == 0
    vpmovmskb %ymm1, %r8d
    popcnt  %r8d, %r8d
    shrq    $3, %r8
    addq    %r8, %rax
    addq    $32, %rdi
    decq    %rcx
    jnz     .Lavx2_val_loop
.Lavx2_val_tail:
    andq    $3, %rsi
    jz      .Lavx2_val_done
.Lavx2_val_rem:
    cmpq    $0, (%rdi)
    jne     .Lavx2_val_ok
    incq    %rax
.Lavx2_val_ok:
    addq    $8, %rdi
    decq    %rsi
    jnz     .Lavx2_val_rem
.Lavx2_val_done:
    vzeroupper
    ret
