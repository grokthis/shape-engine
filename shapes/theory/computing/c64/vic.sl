shape theory.computing.c64.vic : theory.computing.c64 {
  type: unit
  layer: 0
  """
// MOS 6567/6569 VIC-II (Video Interface Chip).
//
// The VIC-II generates the video output and steals CPU cycles
// to read character/bitmap/sprite data from RAM.
//
// NTSC (6567): 263 raster lines, 65 cycles/line = 17095 cycles/frame
//   Visible: 200 lines x 320 pixels. 59.826 Hz refresh.
// PAL (6569): 312 raster lines, 63 cycles/line = 19656 cycles/frame
//   Visible: 200 lines x 320 pixels. 50.125 Hz refresh.
//
// Registers ($D000-$D03F, 47 registers):
//   $D000-$D00F  Sprite X/Y positions (8 sprites x 2 bytes)
//   $D010        Sprite X MSB (bit 8 of each sprite's X)
//   $D011        Control register 1:
//     Bit 0-2: YSCROLL (fine Y scroll, 0-7)
//     Bit 3: RSEL (0=24 rows, 1=25 rows)
//     Bit 4: DEN (display enable)
//     Bit 5: BMM (bitmap mode)
//     Bit 6: ECM (extended color mode)
//     Bit 7: RST8 (raster bit 8)
//   $D012        Raster counter (bits 0-7)
//   $D015        Sprite enable (1 bit per sprite)
//   $D016        Control register 2:
//     Bit 0-2: XSCROLL (fine X scroll, 0-7)
//     Bit 3: CSEL (0=38 cols, 1=40 cols)
//     Bit 4: MCM (multicolor mode)
//   $D018        Memory pointers:
//     Bit 1-3: Character memory base (x 2KB)
//     Bit 4-7: Screen memory base (x 1KB)
//   $D019        Interrupt register (raster, sprite collision, etc.)
//   $D01A        Interrupt enable
//   $D01B-$D01C  Sprite priority and multicolor
//   $D01D        Sprite X expand
//   $D01E-$D01F  Sprite collision registers
//   $D020        Border color
//   $D021-$D024  Background colors 0-3
//   $D025-$D026  Sprite multicolor 0-1
//   $D027-$D02E  Sprite colors (8 sprites)
//
// Display modes:
//   Standard text: 40x25 characters, 8x8 pixels each.
//     Screen RAM: character code (0-255).
//     Char ROM/RAM: 8 bytes per character (bitmap).
//     Color RAM ($D800): foreground color per character.
//   Multicolor text: 4x8 pixel cells, 4 colors per cell.
//   Bitmap (hires): 320x200 pixels, 2 colors per 8x8 cell.
//   Bitmap (multicolor): 160x200, 4 colors per 4x8 cell.
//   ECM: 4 background colors, selected by bits 6-7 of char code.
//
// Sprites: 8 hardware sprites, 24x21 pixels each.
//   Each sprite: 63 bytes (3 bytes x 21 rows).
//   Sprite pointers: last 8 bytes of screen RAM.
//   Priority, multicolor, expand X/Y, collision detection.
//   Sprite-sprite and sprite-background collision registers.
//
// Bad lines: when YSCROLL matches raster line (mod 8), VIC-II
//   steals 40 cycles from the CPU to read character pointers.
//   CPU gets only 23 cycles on bad lines (NTSC).
//   This is the fundamental timing constraint for C64 demos.
//
// Raster interrupt: VIC-II can trigger IRQ at any raster line.
//   Used for: split-screen effects, stable raster timing,
//   multiplexing sprites beyond the 8 hardware limit.
//
// Derives from: theory.computing.c64
  """
}
