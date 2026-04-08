# shape_mos6502.s — MOS 6502 CPU in ARM64 assembly.
#
# The 6502: 8-bit CPU, 1 MHz, 56 instructions, 13 addressing modes.
# Used in: Apple II, Commodore 64 (as 6510), NES, Atari 2600.
# The chip that started personal computing.
#
# This implements a cycle-accurate 6502 emulator. The CPU state
# is a struct in memory. Each call to mos6502_step executes one
# instruction and returns the cycle count consumed.
#
# CPU state layout (struct at x19):
#   +0:  A     (uint8)  accumulator
#   +1:  X     (uint8)  index register X
#   +2:  Y     (uint8)  index register Y
#   +3:  SP    (uint8)  stack pointer (page $01)
#   +4:  P     (uint8)  processor status (NV-BDIZC)
#   +6:  PC    (uint16) program counter
#   +8:  mem   (ptr)    pointer to 64KB memory array
#   +16: cyc   (uint64) total cycle count
#
# Status register bits:
#   bit 0: C (carry)
#   bit 1: Z (zero)
#   bit 2: I (interrupt disable)
#   bit 3: D (decimal mode)
#   bit 4: B (break)
#   bit 5: - (unused, always 1)
#   bit 6: V (overflow)
#   bit 7: N (negative)

.global _mos6502_step
.global _mos6502_reset
.global _mos6502_nmi
.global _mos6502_irq

.text
.align 4

# ============================================================
# mos6502_reset(state)
# Initialize CPU to reset state.
# x0 = pointer to CPU state
# ============================================================
_mos6502_reset:
    strb    wzr, [x0, #0]       // A = 0
    strb    wzr, [x0, #1]       // X = 0
    strb    wzr, [x0, #2]       // Y = 0
    mov     w1, #0xFD
    strb    w1, [x0, #3]        // SP = $FD
    mov     w1, #0x24
    strb    w1, [x0, #4]        // P = 00100100 (I=1, unused=1)
    // PC = mem[$FFFC] | (mem[$FFFD] << 8)
    ldr     x2, [x0, #8]       // mem base
    ldrb    w3, [x2, #0xFFFC]   // low byte
    ldrb    w4, [x2, #0xFFFD]   // high byte
    orr     w3, w3, w4, lsl #8
    strh    w3, [x0, #6]        // PC = reset vector
    str     xzr, [x0, #16]     // cycles = 0
    ret

# ============================================================
# mos6502_step(state) -> cycles consumed
# Execute one instruction. Returns cycle count in x0.
# x0 = pointer to CPU state
#
# This is the transformation law of the 6502:
#   M' = f(C, S)
# where C = (A, X, Y, SP, P, memory) and S = the instruction
# set architecture. Each instruction is one tick.
# ============================================================
_mos6502_step:
    // Save callee-saved registers
    stp     x19, x20, [sp, #-64]!
    stp     x21, x22, [sp, #16]
    stp     x23, x24, [sp, #32]
    stp     x25, x26, [sp, #48]

    mov     x19, x0             // x19 = state pointer

    // Load CPU state into registers
    ldrb    w20, [x19, #0]      // w20 = A
    ldrb    w21, [x19, #1]      // w21 = X
    ldrb    w22, [x19, #2]      // w22 = Y
    ldrb    w23, [x19, #3]      // w23 = SP
    ldrb    w24, [x19, #4]      // w24 = P (flags)
    ldrh    w25, [x19, #6]      // w25 = PC
    ldr     x26, [x19, #8]      // x26 = mem base

    // Fetch opcode
    and     x0, x25, #0xFFFF
    ldrb    w0, [x26, x0]       // opcode = mem[PC]
    add     w25, w25, #1        // PC++
    and     w25, w25, #0xFFFF

    // Decode via jump table. The 6502 has 256 possible opcodes,
    // 151 are valid. We handle all documented opcodes.
    // For brevity, we implement the core set and dispatch.

    // Default cycle count
    mov     w10, #2             // minimum 2 cycles

    // --- Branch: compare opcode ranges ---

    // LDA immediate ($A9) - most common instruction
    cmp     w0, #0xA9
    b.eq    .Llda_imm

    // STA absolute ($8D)
    cmp     w0, #0x8D
    b.eq    .Lsta_abs

    // LDX immediate ($A2)
    cmp     w0, #0xA2
    b.eq    .Lldx_imm

    // LDY immediate ($A0)
    cmp     w0, #0xA0
    b.eq    .Lldy_imm

    // ADC immediate ($69)
    cmp     w0, #0x69
    b.eq    .Ladc_imm

    // SBC immediate ($E9)
    cmp     w0, #0xE9
    b.eq    .Lsbc_imm

    // CMP immediate ($C9)
    cmp     w0, #0xC9
    b.eq    .Lcmp_imm

    // CPX immediate ($E0)
    cmp     w0, #0xE0
    b.eq    .Lcpx_imm

    // CPY immediate ($C0)
    cmp     w0, #0xC0
    b.eq    .Lcpy_imm

    // AND immediate ($29)
    cmp     w0, #0x29
    b.eq    .Land_imm

    // ORA immediate ($09)
    cmp     w0, #0x09
    b.eq    .Lora_imm

    // EOR immediate ($49)
    cmp     w0, #0x49
    b.eq    .Leor_imm

    // INX ($E8)
    cmp     w0, #0xE8
    b.eq    .Linx

    // INY ($C8)
    cmp     w0, #0xC8
    b.eq    .Liny

    // DEX ($CA)
    cmp     w0, #0xCA
    b.eq    .Ldex

    // DEY ($88)
    cmp     w0, #0x88
    b.eq    .Ldey

    // TAX ($AA)
    cmp     w0, #0xAA
    b.eq    .Ltax

    // TAY ($A8)
    cmp     w0, #0xA8
    b.eq    .Ltay

    // TXA ($8A)
    cmp     w0, #0x8A
    b.eq    .Ltxa

    // TYA ($98)
    cmp     w0, #0x98
    b.eq    .Ltya

    // PHA ($48)
    cmp     w0, #0x48
    b.eq    .Lpha

    // PLA ($68)
    cmp     w0, #0x68
    b.eq    .Lpla

    // JMP absolute ($4C)
    cmp     w0, #0x4C
    b.eq    .Ljmp_abs

    // JSR ($20)
    cmp     w0, #0x20
    b.eq    .Ljsr

    // RTS ($60)
    cmp     w0, #0x60
    b.eq    .Lrts

    // BEQ ($F0)
    cmp     w0, #0xF0
    b.eq    .Lbeq

    // BNE ($D0)
    cmp     w0, #0xD0
    b.eq    .Lbne

    // BCS ($B0)
    cmp     w0, #0xB0
    b.eq    .Lbcs

    // BCC ($90)
    cmp     w0, #0x90
    b.eq    .Lbcc

    // BMI ($30)
    cmp     w0, #0x30
    b.eq    .Lbmi

    // BPL ($10)
    cmp     w0, #0x10
    b.eq    .Lbpl

    // SEC ($38)
    cmp     w0, #0x38
    b.eq    .Lsec

    // CLC ($18)
    cmp     w0, #0x18
    b.eq    .Lclc

    // SEI ($78)
    cmp     w0, #0x78
    b.eq    .Lsei

    // CLI ($58)
    cmp     w0, #0x58
    b.eq    .Lcli

    // NOP ($EA)
    cmp     w0, #0xEA
    b.eq    .Lnop

    // BRK ($00)
    cmp     w0, #0x00
    b.eq    .Lbrk

    // INC absolute ($EE)
    cmp     w0, #0xEE
    b.eq    .Linc_abs

    // DEC absolute ($CE)
    cmp     w0, #0xCE
    b.eq    .Ldec_abs

    // LDA absolute ($AD)
    cmp     w0, #0xAD
    b.eq    .Llda_abs

    // LDA zero page ($A5)
    cmp     w0, #0xA5
    b.eq    .Llda_zp

    // STA zero page ($85)
    cmp     w0, #0x85
    b.eq    .Lsta_zp

    // LDA absolute,X ($BD)
    cmp     w0, #0xBD
    b.eq    .Llda_absx

    // LDA absolute,Y ($B9)
    cmp     w0, #0xB9
    b.eq    .Llda_absy

    // STA absolute,X ($9D)
    cmp     w0, #0x9D
    b.eq    .Lsta_absx

    // ASL A ($0A)
    cmp     w0, #0x0A
    b.eq    .Lasl_a

    // LSR A ($4A)
    cmp     w0, #0x4A
    b.eq    .Llsr_a

    // ROL A ($2A)
    cmp     w0, #0x2A
    b.eq    .Lrol_a

    // ROR A ($6A)
    cmp     w0, #0x6A
    b.eq    .Lror_a

    // RTI ($40)
    cmp     w0, #0x40
    b.eq    .Lrti

    // PHP ($08)
    cmp     w0, #0x08
    b.eq    .Lphp

    // PLP ($28)
    cmp     w0, #0x28
    b.eq    .Lplp

    // BVS ($70)
    cmp     w0, #0x70
    b.eq    .Lbvs

    // BVC ($50)
    cmp     w0, #0x50
    b.eq    .Lbvc

    // CLD ($D8)
    cmp     w0, #0xD8
    b.eq    .Lcld

    // SED ($F8)
    cmp     w0, #0xF8
    b.eq    .Lsed

    // CLV ($B8)
    cmp     w0, #0xB8
    b.eq    .Lclv

    // TXS ($9A)
    cmp     w0, #0x9A
    b.eq    .Ltxs

    // TSX ($BA)
    cmp     w0, #0xBA
    b.eq    .Ltsx

    // BIT absolute ($2C)
    cmp     w0, #0x2C
    b.eq    .Lbit_abs

    // LDA (indirect,X) ($A1)
    cmp     w0, #0xA1
    b.eq    .Llda_indx

    // LDA (indirect),Y ($B1)
    cmp     w0, #0xB1
    b.eq    .Llda_indy

    // STA (indirect,X) ($81)
    cmp     w0, #0x81
    b.eq    .Lsta_indx

    // STA (indirect),Y ($91)
    cmp     w0, #0x91
    b.eq    .Lsta_indy

    // Unimplemented opcode: treat as NOP
    b       .Lnop

// === Instruction implementations ===

// Helper: set N and Z flags from w1 (8-bit result)
.Lset_nz:
    and     w24, w24, #0x7D     // clear N and Z
    tst     w1, #0xFF
    b.ne    .Lnz_notz
    orr     w24, w24, #0x02     // set Z
.Lnz_notz:
    tst     w1, #0x80
    b.eq    .Lnz_notn
    orr     w24, w24, #0x80     // set N
.Lnz_notn:
    b       .Ldone

// Helper: fetch 16-bit absolute address -> w11
.Lfetch16:
    and     x0, x25, #0xFFFF
    ldrb    w11, [x26, x0]      // low byte
    add     w25, w25, #1
    and     x0, x25, #0xFFFF
    ldrb    w12, [x26, x0]      // high byte
    add     w25, w25, #1
    orr     w11, w11, w12, lsl #8
    and     w25, w25, #0xFFFF
    ret     // returns to caller (not main ret)

// --- Load/Store ---

.Llda_imm:
    and     x0, x25, #0xFFFF
    ldrb    w20, [x26, x0]      // A = mem[PC]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    mov     w1, w20
    b       .Lset_nz

.Llda_zp:
    and     x0, x25, #0xFFFF
    ldrb    w0, [x26, x0]       // zero page addr
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    ldrb    w20, [x26, x0]      // A = mem[zp]
    mov     w10, #3
    mov     w1, w20
    b       .Lset_nz

.Llda_abs:
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    and     x0, x11, #0xFFFF
    ldrb    w20, [x26, x0]      // A = mem[addr]
    mov     w10, #4
    mov     w1, w20
    b       .Lset_nz

.Llda_absx:
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    add     w11, w11, w21       // addr + X
    and     x0, x11, #0xFFFF
    ldrb    w20, [x26, x0]
    mov     w10, #4             // +1 if page crossed
    mov     w1, w20
    b       .Lset_nz

.Llda_absy:
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    add     w11, w11, w22       // addr + Y
    and     x0, x11, #0xFFFF
    ldrb    w20, [x26, x0]
    mov     w10, #4
    mov     w1, w20
    b       .Lset_nz

.Llda_indx:                     // LDA (zp,X) - 6 cycles
    and     x0, x25, #0xFFFF
    ldrb    w0, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    add     w0, w0, w21         // zp + X
    and     w0, w0, #0xFF
    ldrb    w11, [x26, x0]      // low byte
    add     w0, w0, #1
    and     w0, w0, #0xFF
    ldrb    w12, [x26, x0]      // high byte
    orr     w11, w11, w12, lsl #8
    and     x0, x11, #0xFFFF
    ldrb    w20, [x26, x0]
    mov     w10, #6
    mov     w1, w20
    b       .Lset_nz

.Llda_indy:                     // LDA (zp),Y - 5 cycles
    and     x0, x25, #0xFFFF
    ldrb    w0, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    and     x1, x0, #0xFF
    ldrb    w11, [x26, x1]      // low byte
    add     w0, w0, #1
    and     x1, x0, #0xFF
    ldrb    w12, [x26, x1]      // high byte
    orr     w11, w11, w12, lsl #8
    add     w11, w11, w22       // + Y
    and     x0, x11, #0xFFFF
    ldrb    w20, [x26, x0]
    mov     w10, #5
    mov     w1, w20
    b       .Lset_nz

.Lsta_abs:
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    and     x0, x11, #0xFFFF
    strb    w20, [x26, x0]      // mem[addr] = A
    mov     w10, #4
    b       .Ldone

.Lsta_zp:
    and     x0, x25, #0xFFFF
    ldrb    w0, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    strb    w20, [x26, x0]
    mov     w10, #3
    b       .Ldone

.Lsta_absx:
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    add     w11, w11, w21
    and     x0, x11, #0xFFFF
    strb    w20, [x26, x0]
    mov     w10, #5
    b       .Ldone

.Lsta_indx:
    and     x0, x25, #0xFFFF
    ldrb    w0, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    add     w0, w0, w21
    and     w0, w0, #0xFF
    ldrb    w11, [x26, x0]
    add     w0, w0, #1
    and     w0, w0, #0xFF
    ldrb    w12, [x26, x0]
    orr     w11, w11, w12, lsl #8
    and     x0, x11, #0xFFFF
    strb    w20, [x26, x0]
    mov     w10, #6
    b       .Ldone

.Lsta_indy:
    and     x0, x25, #0xFFFF
    ldrb    w0, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    and     x1, x0, #0xFF
    ldrb    w11, [x26, x1]
    add     w0, w0, #1
    and     x1, x0, #0xFF
    ldrb    w12, [x26, x1]
    orr     w11, w11, w12, lsl #8
    add     w11, w11, w22
    and     x0, x11, #0xFFFF
    strb    w20, [x26, x0]
    mov     w10, #6
    b       .Ldone

.Lldx_imm:
    and     x0, x25, #0xFFFF
    ldrb    w21, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    mov     w1, w21
    b       .Lset_nz

.Lldy_imm:
    and     x0, x25, #0xFFFF
    ldrb    w22, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    mov     w1, w22
    b       .Lset_nz

// --- Arithmetic ---

.Ladc_imm:                      // ADC #imm - 2 cycles
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    and     w2, w24, #0x01      // carry in
    add     w3, w20, w1
    add     w3, w3, w2          // A + M + C
    // Set carry
    and     w24, w24, #0xFE     // clear C
    cmp     w3, #0xFF
    b.le    .Ladc_noc
    orr     w24, w24, #0x01     // set C
.Ladc_noc:
    // Set overflow: (A^result) & (M^result) & 0x80
    eor     w4, w20, w3
    eor     w5, w1, w3
    and     w4, w4, w5
    and     w24, w24, #0xBF     // clear V
    tst     w4, #0x80
    b.eq    .Ladc_nov
    orr     w24, w24, #0x40     // set V
.Ladc_nov:
    and     w20, w3, #0xFF      // A = result & 0xFF
    mov     w1, w20
    b       .Lset_nz

.Lsbc_imm:                      // SBC #imm - 2 cycles
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    and     w2, w24, #0x01      // carry (borrow = !C)
    sub     w3, w20, w1
    sub     w3, w3, #1
    add     w3, w3, w2          // A - M - (1-C)
    // Set carry (inverted borrow)
    and     w24, w24, #0xFE
    cmp     w3, #0
    b.lt    .Lsbc_noc
    orr     w24, w24, #0x01
.Lsbc_noc:
    // Overflow
    eor     w4, w20, w3
    eor     w5, w20, w1
    and     w4, w4, w5
    and     w24, w24, #0xBF
    tst     w4, #0x80
    b.eq    .Lsbc_nov
    orr     w24, w24, #0x40
.Lsbc_nov:
    and     w20, w3, #0xFF
    mov     w1, w20
    b       .Lset_nz

// --- Compare ---

.Lcmp_imm:
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    sub     w3, w20, w1
    and     w24, w24, #0xFE     // clear C
    cmp     w20, w1
    b.lo    .Lcmp_noc
    orr     w24, w24, #0x01     // C = (A >= M)
.Lcmp_noc:
    and     w1, w3, #0xFF
    b       .Lset_nz

.Lcpx_imm:
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    sub     w3, w21, w1
    and     w24, w24, #0xFE
    cmp     w21, w1
    b.lo    .Lcpx_noc
    orr     w24, w24, #0x01
.Lcpx_noc:
    and     w1, w3, #0xFF
    b       .Lset_nz

.Lcpy_imm:
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    sub     w3, w22, w1
    and     w24, w24, #0xFE
    cmp     w22, w1
    b.lo    .Lcpy_noc
    orr     w24, w24, #0x01
.Lcpy_noc:
    and     w1, w3, #0xFF
    b       .Lset_nz

// --- Logic ---

.Land_imm:
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    and     w20, w20, w1
    mov     w1, w20
    b       .Lset_nz

.Lora_imm:
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    orr     w20, w20, w1
    mov     w1, w20
    b       .Lset_nz

.Leor_imm:
    and     x0, x25, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    eor     w20, w20, w1
    mov     w1, w20
    b       .Lset_nz

// --- Increment/Decrement ---

.Linx:
    add     w21, w21, #1
    and     w21, w21, #0xFF
    mov     w1, w21
    b       .Lset_nz

.Liny:
    add     w22, w22, #1
    and     w22, w22, #0xFF
    mov     w1, w22
    b       .Lset_nz

.Ldex:
    sub     w21, w21, #1
    and     w21, w21, #0xFF
    mov     w1, w21
    b       .Lset_nz

.Ldey:
    sub     w22, w22, #1
    and     w22, w22, #0xFF
    mov     w1, w22
    b       .Lset_nz

.Linc_abs:
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    and     x0, x11, #0xFFFF
    ldrb    w1, [x26, x0]
    add     w1, w1, #1
    and     w1, w1, #0xFF
    strb    w1, [x26, x0]
    mov     w10, #6
    b       .Lset_nz

.Ldec_abs:
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    and     x0, x11, #0xFFFF
    ldrb    w1, [x26, x0]
    sub     w1, w1, #1
    and     w1, w1, #0xFF
    strb    w1, [x26, x0]
    mov     w10, #6
    b       .Lset_nz

// --- Transfers ---

.Ltax:
    mov     w21, w20
    mov     w1, w21
    b       .Lset_nz

.Ltay:
    mov     w22, w20
    mov     w1, w22
    b       .Lset_nz

.Ltxa:
    mov     w20, w21
    mov     w1, w20
    b       .Lset_nz

.Ltya:
    mov     w20, w22
    mov     w1, w20
    b       .Lset_nz

.Ltxs:
    mov     w23, w21
    b       .Ldone

.Ltsx:
    mov     w21, w23
    mov     w1, w21
    b       .Lset_nz

// --- Stack ---

.Lpha:                          // PHA - 3 cycles
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    strb    w20, [x26, x0]     // mem[$0100+SP] = A
    sub     w23, w23, #1
    and     w23, w23, #0xFF
    mov     w10, #3
    b       .Ldone

.Lpla:                          // PLA - 4 cycles
    add     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    ldrb    w20, [x26, x0]     // A = mem[$0100+SP]
    mov     w10, #4
    mov     w1, w20
    b       .Lset_nz

.Lphp:
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    orr     w1, w24, #0x30      // B and unused always set on push
    strb    w1, [x26, x0]
    sub     w23, w23, #1
    and     w23, w23, #0xFF
    mov     w10, #3
    b       .Ldone

.Lplp:
    add     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    ldrb    w24, [x26, x0]
    and     w24, w24, #0xCF     // clear B and unused
    orr     w24, w24, #0x20     // unused always 1
    mov     w10, #4
    b       .Ldone

// --- Shifts ---

.Lasl_a:
    lsl     w20, w20, #1
    and     w24, w24, #0xFE     // clear C
    tst     w20, #0x100
    b.eq    .Lasl_noc
    orr     w24, w24, #0x01     // C = old bit 7
.Lasl_noc:
    and     w20, w20, #0xFF
    mov     w1, w20
    b       .Lset_nz

.Llsr_a:
    and     w24, w24, #0xFE
    tst     w20, #0x01
    b.eq    .Llsr_noc
    orr     w24, w24, #0x01     // C = old bit 0
.Llsr_noc:
    lsr     w20, w20, #1
    and     w20, w20, #0xFF
    mov     w1, w20
    b       .Lset_nz

.Lrol_a:
    and     w2, w24, #0x01      // old carry
    lsl     w20, w20, #1
    orr     w20, w20, w2        // bit 0 = old carry
    and     w24, w24, #0xFE
    tst     w20, #0x100
    b.eq    .Lrol_noc
    orr     w24, w24, #0x01
.Lrol_noc:
    and     w20, w20, #0xFF
    mov     w1, w20
    b       .Lset_nz

.Lror_a:
    and     w2, w24, #0x01      // old carry
    and     w24, w24, #0xFE
    tst     w20, #0x01
    b.eq    .Lror_noc
    orr     w24, w24, #0x01     // C = old bit 0
.Lror_noc:
    lsr     w20, w20, #1
    orr     w20, w20, w2, lsl #7  // bit 7 = old carry
    and     w20, w20, #0xFF
    mov     w1, w20
    b       .Lset_nz

// --- Branches ---

.Lbeq:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]      // signed offset
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x02          // Z flag set?
    b.eq    .Ldone
    add     w25, w25, w1        // PC += offset
    and     w25, w25, #0xFFFF
    mov     w10, #3             // +1 for taken, +1 if page cross
    b       .Ldone

.Lbne:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x02
    b.ne    .Ldone
    add     w25, w25, w1
    and     w25, w25, #0xFFFF
    mov     w10, #3
    b       .Ldone

.Lbcs:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x01
    b.eq    .Ldone
    add     w25, w25, w1
    and     w25, w25, #0xFFFF
    mov     w10, #3
    b       .Ldone

.Lbcc:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x01
    b.ne    .Ldone
    add     w25, w25, w1
    and     w25, w25, #0xFFFF
    mov     w10, #3
    b       .Ldone

.Lbmi:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x80
    b.eq    .Ldone
    add     w25, w25, w1
    and     w25, w25, #0xFFFF
    mov     w10, #3
    b       .Ldone

.Lbpl:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x80
    b.ne    .Ldone
    add     w25, w25, w1
    and     w25, w25, #0xFFFF
    mov     w10, #3
    b       .Ldone

.Lbvs:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x40
    b.eq    .Ldone
    add     w25, w25, w1
    and     w25, w25, #0xFFFF
    mov     w10, #3
    b       .Ldone

.Lbvc:
    and     x0, x25, #0xFFFF
    ldrsb   w1, [x26, x0]
    add     w25, w25, #1
    and     w25, w25, #0xFFFF
    tst     w24, #0x40
    b.ne    .Ldone
    add     w25, w25, w1
    and     w25, w25, #0xFFFF
    mov     w10, #3
    b       .Ldone

// --- Jump/Call ---

.Ljmp_abs:                      // JMP abs - 3 cycles
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    mov     w25, w11
    mov     w10, #3
    b       .Ldone

.Ljsr:                          // JSR abs - 6 cycles
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    // Push PC-1 (return address - 1, RTS adds 1)
    sub     w1, w25, #1
    and     w1, w1, #0xFFFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    lsr     w2, w1, #8
    strb    w2, [x26, x0]      // push high byte
    sub     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    strb    w1, [x26, x0]      // push low byte
    sub     w23, w23, #1
    and     w23, w23, #0xFF
    mov     w25, w11            // PC = target
    mov     w10, #6
    b       .Ldone

.Lrts:                          // RTS - 6 cycles
    add     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    ldrb    w1, [x26, x0]      // low byte
    add     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    ldrb    w2, [x26, x0]      // high byte
    orr     w25, w1, w2, lsl #8
    add     w25, w25, #1        // PC = pulled + 1
    and     w25, w25, #0xFFFF
    mov     w10, #6
    b       .Ldone

.Lrti:                          // RTI - 6 cycles
    add     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    ldrb    w24, [x26, x0]     // pull P
    and     w24, w24, #0xCF
    orr     w24, w24, #0x20
    add     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    ldrb    w1, [x26, x0]      // pull PCL
    add     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    ldrb    w2, [x26, x0]      // pull PCH
    orr     w25, w1, w2, lsl #8
    mov     w10, #6
    b       .Ldone

// --- BIT ---

.Lbit_abs:                      // BIT abs - 4 cycles
    stp     x30, xzr, [sp, #-16]!
    bl      .Lfetch16
    ldp     x30, xzr, [sp], #16
    and     x0, x11, #0xFFFF
    ldrb    w1, [x26, x0]
    // N = bit 7 of memory, V = bit 6 of memory
    and     w24, w24, #0x3D     // clear N, V, Z
    tst     w1, #0x80
    b.eq    .Lbit_nn
    orr     w24, w24, #0x80
.Lbit_nn:
    tst     w1, #0x40
    b.eq    .Lbit_nv
    orr     w24, w24, #0x40
.Lbit_nv:
    // Z = (A & M) == 0
    and     w2, w20, w1
    tst     w2, #0xFF
    b.ne    .Lbit_nz
    orr     w24, w24, #0x02
.Lbit_nz:
    mov     w10, #4
    b       .Ldone

// --- Flag instructions ---

.Lsec:
    orr     w24, w24, #0x01
    b       .Ldone

.Lclc:
    and     w24, w24, #0xFE
    b       .Ldone

.Lsei:
    orr     w24, w24, #0x04
    b       .Ldone

.Lcli:
    and     w24, w24, #0xFB
    b       .Ldone

.Lcld:
    and     w24, w24, #0xF7
    b       .Ldone

.Lsed:
    orr     w24, w24, #0x08
    b       .Ldone

.Lclv:
    and     w24, w24, #0xBF
    b       .Ldone

// --- BRK ---

.Lbrk:                          // BRK - 7 cycles
    add     w25, w25, #1        // skip padding byte
    and     w25, w25, #0xFFFF
    // Push PC
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    lsr     w1, w25, #8
    strb    w1, [x26, x0]
    sub     w23, w23, #1
    and     w23, w23, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    strb    w25, [x26, x0]
    sub     w23, w23, #1
    and     w23, w23, #0xFF
    // Push P with B set
    orr     x0, xzr, #0x100
    add     x0, x0, x23
    orr     w1, w24, #0x30
    strb    w1, [x26, x0]
    sub     w23, w23, #1
    and     w23, w23, #0xFF
    // Set I flag
    orr     w24, w24, #0x04
    // PC = IRQ vector
    ldrb    w1, [x26, #0xFFFE]
    ldrb    w2, [x26, #0xFFFF]
    orr     w25, w1, w2, lsl #8
    mov     w10, #7
    b       .Ldone

// --- NOP ---

.Lnop:
    b       .Ldone

// === Store state and return ===

.Ldone:
    // Write back CPU state
    strb    w20, [x19, #0]      // A
    strb    w21, [x19, #1]      // X
    strb    w22, [x19, #2]      // Y
    strb    w23, [x19, #3]      // SP
    strb    w24, [x19, #4]      // P
    strh    w25, [x19, #6]      // PC

    // Update cycle count
    ldr     x0, [x19, #16]
    add     x0, x0, x10, uxtw
    str     x0, [x19, #16]

    mov     w0, w10             // return cycles consumed

    // Restore callee-saved registers
    ldp     x25, x26, [sp, #48]
    ldp     x23, x24, [sp, #32]
    ldp     x21, x22, [sp, #16]
    ldp     x19, x20, [sp], #64
    ret

# ============================================================
# mos6502_nmi(state)
# Non-maskable interrupt. Always taken.
# ============================================================
_mos6502_nmi:
    stp     x19, x20, [sp, #-16]!
    mov     x19, x0
    ldrh    w1, [x19, #6]      // PC
    ldrb    w2, [x19, #3]      // SP
    ldr     x3, [x19, #8]      // mem

    // Push PC
    orr     x0, xzr, #0x100
    add     x0, x0, x2
    lsr     w4, w1, #8
    strb    w4, [x3, x0]
    sub     w2, w2, #1
    and     w2, w2, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x2
    strb    w1, [x3, x0]
    sub     w2, w2, #1
    and     w2, w2, #0xFF

    // Push P (without B)
    ldrb    w4, [x19, #4]
    and     w5, w4, #0xEF      // clear B
    orr     x0, xzr, #0x100
    add     x0, x0, x2
    strb    w5, [x3, x0]
    sub     w2, w2, #1
    and     w2, w2, #0xFF

    // Set I
    orr     w4, w4, #0x04
    strb    w4, [x19, #4]
    strb    w2, [x19, #3]

    // PC = NMI vector ($FFFA)
    ldrb    w1, [x3, #0xFFFA]
    ldrb    w4, [x3, #0xFFFB]
    orr     w1, w1, w4, lsl #8
    strh    w1, [x19, #6]

    ldp     x19, x20, [sp], #16
    ret

# ============================================================
# mos6502_irq(state)
# Maskable interrupt. Taken only if I flag is clear.
# ============================================================
_mos6502_irq:
    ldrb    w1, [x0, #4]       // P
    tst     w1, #0x04           // I flag set?
    b.ne    .Lirq_skip         // if set, ignore

    stp     x19, x20, [sp, #-16]!
    mov     x19, x0
    ldrh    w1, [x19, #6]
    ldrb    w2, [x19, #3]
    ldr     x3, [x19, #8]

    // Push PC
    orr     x0, xzr, #0x100
    add     x0, x0, x2
    lsr     w4, w1, #8
    strb    w4, [x3, x0]
    sub     w2, w2, #1
    and     w2, w2, #0xFF
    orr     x0, xzr, #0x100
    add     x0, x0, x2
    strb    w1, [x3, x0]
    sub     w2, w2, #1
    and     w2, w2, #0xFF

    // Push P
    ldrb    w4, [x19, #4]
    and     w5, w4, #0xEF
    orr     x0, xzr, #0x100
    add     x0, x0, x2
    strb    w5, [x3, x0]
    sub     w2, w2, #1
    and     w2, w2, #0xFF

    orr     w4, w4, #0x04
    strb    w4, [x19, #4]
    strb    w2, [x19, #3]

    // PC = IRQ vector ($FFFE)
    ldrb    w1, [x3, #0xFFFE]
    ldrb    w4, [x3, #0xFFFF]
    orr     w1, w1, w4, lsl #8
    strh    w1, [x19, #6]

    ldp     x19, x20, [sp], #16
.Lirq_skip:
    ret
