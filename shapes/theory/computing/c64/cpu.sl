shape theory.computing.c64.cpu : theory.computing.c64 {
  type: unit
  layer: 0
  """
// MOS 6510 CPU (6502 + I/O port).
//
// The 6502 core:
//   8-bit data bus, 16-bit address bus (64KB).
//   Registers: A (accumulator), X, Y (index), SP, P (status), PC.
//   Status: N V - B D I Z C (negative, overflow, -, break,
//     decimal, interrupt, zero, carry).
//   Little-endian.
//
// Clock: 1.022727 MHz (NTSC) / 0.985248 MHz (PAL).
// ~978 ns per cycle (NTSC). ~1015 ns per cycle (PAL).
//
// Addressing modes (13):
//   Implied         CLC, SEC, INX, etc.          1-2 bytes, 2 cycles
//   Accumulator     ASL A, LSR A, etc.           1 byte, 2 cycles
//   Immediate       LDA #$FF                     2 bytes, 2 cycles
//   Zero Page       LDA $FF                      2 bytes, 3 cycles
//   Zero Page,X     LDA $FF,X                    2 bytes, 4 cycles
//   Zero Page,Y     LDX $FF,Y                    2 bytes, 4 cycles
//   Absolute        LDA $FFFF                    3 bytes, 4 cycles
//   Absolute,X      LDA $FFFF,X                  3 bytes, 4-5 cycles
//   Absolute,Y      LDA $FFFF,Y                  3 bytes, 4-5 cycles
//   Indirect        JMP ($FFFF)                  3 bytes, 5 cycles
//   (Indirect,X)    LDA ($FF,X)                  2 bytes, 6 cycles
//   (Indirect),Y    LDA ($FF),Y                  2 bytes, 5-6 cycles
//   Relative        BEQ $FF (signed offset)      2 bytes, 2-4 cycles
//
// +1 cycle if page boundary crossed on indexed/indirect modes.
// +1 cycle if branch taken. +2 if branch crosses page boundary.
//
// 6510 additions over 6502:
//   $0000: data direction register (DDR). Each bit: 0=input, 1=output.
//   $0001: I/O port. Controls PLA banking:
//     Bit 0: LORAM (1=BASIC ROM at $A000)
//     Bit 1: HIRAM (1=KERNAL ROM at $E000)
//     Bit 2: CHAREN (1=I/O at $D000, 0=Char ROM)
//     Bit 3: Cassette data output
//     Bit 4: Cassette switch sense
//     Bit 5: Cassette motor (0=on)
//
// 56 documented instructions across 151 valid opcodes.
// 105 opcodes are "illegal" (undocumented but deterministic).
//
// The 6510 instruction set (all documented opcodes):
//
// Load/Store:
//   LDA, LDX, LDY        Load register from memory
//   STA, STX, STY        Store register to memory
//
// Transfer:
//   TAX, TAY, TXA, TYA   Register to register
//   TSX, TXS             Stack pointer transfers
//
// Stack:
//   PHA, PLA              Push/pull accumulator
//   PHP, PLP              Push/pull processor status
//
// Arithmetic:
//   ADC                   Add with carry
//   SBC                   Subtract with borrow
//   INC, DEC              Increment/decrement memory
//   INX, INY              Increment index registers
//   DEX, DEY              Decrement index registers
//
// Logic:
//   AND, ORA, EOR         Bitwise operations
//   BIT                   Bit test
//
// Shift:
//   ASL, LSR              Arithmetic/logical shift
//   ROL, ROR              Rotate through carry
//
// Compare:
//   CMP, CPX, CPY         Compare register with memory
//
// Branch:
//   BCC, BCS              Branch on carry clear/set
//   BEQ, BNE              Branch on zero set/clear
//   BMI, BPL              Branch on negative set/clear
//   BVS, BVC              Branch on overflow set/clear
//
// Jump:
//   JMP                   Jump (absolute or indirect)
//   JSR                   Jump to subroutine
//   RTS                   Return from subroutine
//   RTI                   Return from interrupt
//
// Flag:
//   CLC, SEC              Clear/set carry
//   CLD, SED              Clear/set decimal
//   CLI, SEI              Clear/set interrupt disable
//   CLV                   Clear overflow
//
// System:
//   BRK                   Software interrupt
//   NOP                   No operation
//
// Derives from: theory.computing.c64
  """
}
