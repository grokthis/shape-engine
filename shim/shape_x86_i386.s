# shape_x86_i386.s — Shape engine in Intel i386 (1985, 32-bit).
#
# The original 32-bit x86. CISC: variable-length instructions,
# memory operands, complex addressing modes. 8 general-purpose
# registers (eax, ebx, ecx, edx, esi, edi, ebp, esp).
# The 386 introduced protected mode, paging, and 32-bit flat
# address space. This is where modern x86 begins.
#
# AT&T syntax (GNU as): op src, dst

.global _asm_loop_accum_add
.global _asm_loop_accum_const
.global _asm_nested_accum
.global _asm_pow
.global _asm_add
.global _asm_mul
.global _asm_div

.text

# ============================================================
# asm_loop_accum_add(start, end, init) -> sum
# cdecl: args on stack. [esp+4]=start, [esp+8]=end, [esp+12]=init
# Returns: eax
# ============================================================
_asm_loop_accum_add:
    movl    4(%esp), %ecx       # i = start
    movl    8(%esp), %edx       # end
    movl    12(%esp), %eax      # acc = init
.Lloop_386:
    cmpl    %edx, %ecx
    jge     .Ldone_386
    addl    %ecx, %eax          # acc += i
    incl    %ecx                # i++
    jmp     .Lloop_386
.Ldone_386:
    ret

# Structural shortcut: init + c * (end - start)
_asm_loop_accum_const:
    movl    4(%esp), %ecx       # start
    movl    8(%esp), %edx       # end
    subl    %ecx, %edx          # n = end - start
    movl    16(%esp), %eax      # c
    imull   %edx, %eax          # n * c
    addl    12(%esp), %eax      # init + n*c
    ret

# Structural shortcut: init + n * m
_asm_nested_accum:
    movl    4(%esp), %eax       # n
    imull   8(%esp), %eax       # n * m
    addl    12(%esp), %eax      # init + n*m
    ret

# Repeated squaring
_asm_pow:
    movl    4(%esp), %ecx       # base
    movl    8(%esp), %edx       # exp
    movl    $1, %eax            # result = 1
.Lpow_386:
    testl   %edx, %edx
    jz      .Lpow_386_done
    testl   $1, %edx
    jz      .Lpow_386_sq
    imull   %ecx, %eax          # result *= base
.Lpow_386_sq:
    imull   %ecx, %ecx          # base *= base
    shrl    $1, %edx            # exp >>= 1
    jmp     .Lpow_386
.Lpow_386_done:
    ret

_asm_add:
    movl    4(%esp), %eax
    addl    8(%esp), %eax
    ret

_asm_mul:
    movl    4(%esp), %eax
    imull   8(%esp), %eax
    ret

_asm_div:
    movl    4(%esp), %eax
    cdq                         # sign-extend eax -> edx:eax
    idivl   8(%esp)             # edx:eax / arg -> eax
    ret
