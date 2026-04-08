shape theory.computing.c64 : theory.computing {
  type: system
  layer: 0
  """
// Commodore 64: Complete System in Shapes.
//
// The C64 is 7 chips on a board, cycle-locked to a master clock.
// Every chip is a shape. Every register is a dimension.
// Every cycle is a tick. The system IS the shape graph.
//
// Master clock: 8.181816 MHz (NTSC) / 7.881984 MHz (PAL)
// CPU clock: master / 8 = 1.022727 MHz (NTSC) / 0.985248 MHz (PAL)
// VIC-II clock: master / 8 = same as CPU (but VIC steals cycles)
//
// Chips:
//   MOS 6510   CPU (6502 + I/O port)
//   MOS 6567   VIC-II (video, NTSC) / 6569 (PAL)
//   MOS 6581   SID (sound)
//   MOS 6526   CIA1 (keyboard, joystick, timer)
//   MOS 6526   CIA2 (serial, user port, timer, VIC bank)
//   MOS 906114 PLA (memory banking logic)
//   4164       64KB DRAM (8 x 4164, 64Kx1 each)
//
// Memory map (active configuration depends on PLA):
//   $0000-$00FF  Zero page (256 bytes, fast addressing)
//   $0100-$01FF  Stack (256 bytes, grows down)
//   $0200-$03FF  OS workspace
//   $0400-$07FF  Screen RAM (1000 bytes + spare)
//   $0800-$9FFF  BASIC program area (38KB)
//   $A000-$BFFF  BASIC ROM (8KB) / RAM
//   $C000-$CFFF  RAM (4KB)
//   $D000-$D3FF  VIC-II registers / Char ROM
//   $D400-$D7FF  SID registers / Char ROM
//   $D800-$DBFF  Color RAM (1KB, 4-bit)
//   $DC00-$DCFF  CIA1 registers
//   $DD00-$DDFF  CIA2 registers
//   $E000-$FFFF  KERNAL ROM (8KB) / RAM
//
// The PLA controls banking: ROM/RAM/IO can be switched in/out
// by writing to $0001 (6510 I/O port). 5 major configurations.
//
// Derives from: theory.computing
  """
}
