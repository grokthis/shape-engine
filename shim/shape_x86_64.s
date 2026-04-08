# shape_x86_64.s — Shape engine in x86-64 / AMD64 (2003, 64-bit).
#
# AMD64 doubled the registers (rax-r15), widened to 64-bit,
# introduced RIP-relative addressing, and moved to register-based
# calling convention (System V ABI: rdi, rsi, rdx, rcx, r8, r9).
# This is the architecture most servers and desktops run today.
#
# AT&T syntax.

.global _asm_loop_accum_add
.global _asm_loop_accum_const
.global _asm_nested_accum
.global _asm_pow
.global _asm_add
.global _asm_mul
.global _asm_div

.text
.align 4

# ============================================================
# System V AMD64 ABI: rdi, rsi, rdx, rcx, r8, r9
# Return: rax
# ============================================================

# asm_loop_accum_add(start, end, init) -> sum
_asm_loop_accum_add:
    movq    %rdi, %rcx          # i = start
    movq    %rdx, %rax          # acc = init
.Lloop_64:
    cmpq    %rsi, %rcx
    jge     .Ldone_64
    addq    %rcx, %rax          # acc += i
    incq    %rcx                # i++
    jmp     .Lloop_64
.Ldone_64:
    ret

# Structural shortcut: init + c * (end - start). Three instructions.
_asm_loop_accum_const:
    movq    %rsi, %rax          # end
    subq    %rdi, %rax          # n = end - start
    imulq   %rcx, %rax          # n * c
    addq    %rdx, %rax          # init + n*c
    ret

# Structural shortcut: init + n * m
_asm_nested_accum:
    movq    %rdi, %rax          # n
    imulq   %rsi, %rax          # n * m
    addq    %rdx, %rax          # init + n*m
    ret

# Repeated squaring
_asm_pow:
    movq    %rdi, %rcx          # base
    movq    %rsi, %rdx          # exp
    movq    $1, %rax            # result = 1
.Lpow_64:
    testq   %rdx, %rdx
    jz      .Lpow_64_done
    testq   $1, %rdx
    jz      .Lpow_64_sq
    imulq   %rcx, %rax          # result *= base
.Lpow_64_sq:
    imulq   %rcx, %rcx          # base *= base
    shrq    $1, %rdx            # exp >>= 1
    jmp     .Lpow_64
.Lpow_64_done:
    ret

_asm_add:
    leaq    (%rdi,%rsi), %rax   # rax = rdi + rsi (LEA trick)
    ret

_asm_mul:
    movq    %rdi, %rax
    imulq   %rsi, %rax
    ret

_asm_div:
    movq    %rdi, %rax
    cqo                         # sign-extend rax -> rdx:rax
    idivq   %rsi                # rdx:rax / rsi -> rax
    ret
