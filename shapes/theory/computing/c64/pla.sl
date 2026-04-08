shape theory.computing.c64.pla : theory.computing.c64 {
  type: unit
  layer: 0
  """
// MOS 906114-01 PLA (Programmable Logic Array).
//
// The PLA is the memory banking controller. It decodes the
// address bus and the 6510 I/O port ($0001) to determine
// what responds to each memory access: RAM, ROM, or I/O.
//
// Inputs:
//   A15-A12: address bus high nibble (which 4KB page)
//   LORAM (bit 0 of $0001): 1 = BASIC ROM enabled
//   HIRAM (bit 1 of $0001): 1 = KERNAL ROM enabled
//   CHAREN (bit 2 of $0001): 1 = I/O, 0 = Char ROM
//   GAME, EXROM: cartridge control lines
//   VA14: VIC-II address bit 14
//   AEC: address enable control (CPU or VIC has the bus)
//
// Outputs:
//   CASRAM: chip select for DRAM
//   BASIC: chip select for BASIC ROM
//   KERNAL: chip select for KERNAL ROM
//   CHAROM: chip select for Character ROM
//   I/O: chip select for I/O region (VIC, SID, CIA, Color RAM)
//   GR/W: gate for cartridge ROM/RAM
//
// Default configuration ($0001 = $37, LORAM=HIRAM=CHAREN=1):
//   $0000-$9FFF: RAM
//   $A000-$BFFF: BASIC ROM
//   $C000-$CFFF: RAM
//   $D000-$D3FF: VIC-II I/O
//   $D400-$D7FF: SID I/O
//   $D800-$DBFF: Color RAM
//   $DC00-$DCFF: CIA1
//   $DD00-$DDFF: CIA2
//   $E000-$FFFF: KERNAL ROM
//
// All-RAM configuration ($0001 = $30):
//   $0000-$FFFF: RAM (64KB flat)
//   Used for: copying ROM to RAM, large programs.
//
// VIC-II always sees RAM (and Char ROM in banks 0 and 2).
// The CPU and VIC-II see different memory maps simultaneously.
// This is structural isolation at the hardware level:
// two shapes (CPU, VIC) in the same context (address space)
// with different contact geometries (different memory maps).
//
// Derives from: theory.computing.c64
  """
}
