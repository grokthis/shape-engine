shape theory.computing.c64.timing : theory.computing.c64.cpu, theory.computing.c64.vic, theory.computing.c64.sid, theory.computing.c64.cia {
  type: structure
  layer: 0
  """
// C64 System Timing (cycle-accurate).
//
// All timing derives from the master clock crystal.
// Every chip is locked to this clock. Every cycle is accounted for.
//
// NTSC (6567R8):
//   Master clock: 14.31818 MHz (4x NTSC colorburst)
//   Dot clock: 8.181816 MHz (master x 8/14 for chroma)
//   CPU/VIC clock: 1.022727 MHz (dot clock / 8)
//   Cycles per line: 65 (63 visible + 2 border/sync)
//   Lines per frame: 263 (200 visible + 63 border/vblank)
//   Cycles per frame: 17095
//   Frame rate: 59.826 Hz
//   CPU cycles per second: 1022727
//
// PAL (6569):
//   Master clock: 17.734475 MHz (4x PAL colorburst)
//   Dot clock: 7.881984 MHz
//   CPU/VIC clock: 0.985248 MHz
//   Cycles per line: 63
//   Lines per frame: 312
//   Cycles per frame: 19656
//   Frame rate: 50.125 Hz
//   CPU cycles per second: 985248
//
// Cycle stealing (VIC-II bad lines):
//   Every 8th raster line (when YSCROLL matches), VIC-II needs
//   to read 40 character codes from screen RAM. The VIC halts
//   the CPU for 40 cycles by holding BA low for 3 cycles (to
//   allow the CPU to finish its current memory access), then
//   taking the bus for 40 cycles.
//
//   Normal line: CPU gets 63 (PAL) or 65 (NTSC) cycles.
//   Bad line: CPU gets 23 (PAL) or 25 (NTSC) cycles.
//   Bad lines per frame: 25 (one per text row).
//   Cycles lost: 25 * 40 = 1000 cycles per frame.
//
//   Sprite DMA: each enabled sprite steals 2 cycles per line
//   on lines where the sprite is visible.
//   All 8 sprites: up to 16 extra cycles stolen per line.
//
// CIA timer timing:
//   Timers count down on every phi2 (CPU clock) cycle.
//   Timer A/B each: 16-bit countdown, reload on underflow.
//   Maximum interval: 65535 cycles = ~64ms (NTSC).
//   Minimum interval: 1 cycle = ~978ns (NTSC).
//   Timer B can count Timer A underflows for 32-bit timing.
//
// SID timing:
//   Oscillators: 24-bit phase accumulator incremented every cycle.
//   Frequency resolution: Fclk / 2^24 = 0.06 Hz.
//   Maximum frequency: Fclk / 2 = ~511 KHz (Nyquist).
//   Envelope: counter incremented per cycle, rate table lookup.
//   Filter: updated every cycle (state-variable, 2-pole).
//
// Raster timing for demo effects:
//   Stable raster: double CIA timer IRQ for cycle-exact timing.
//   The canonical method:
//     1. Set CIA1 Timer A to fire at a known raster position.
//     2. First IRQ: set timer for 1 line, acknowledge.
//     3. Second IRQ: now cycle-exact (jitter is 0-1 cycles).
//     4. Use NOP sled to burn the remaining jitter.
//     5. Exact cycle position known. Modify VIC registers.
//   This allows: color splits, open borders, FLD, FLI, AGSP,
//   and all the tricks that make C64 demos legendary.
//
// The whole system is one shape graph ticking at 1 MHz.
// Every cycle, every register, every pixel, every sample
// is structurally determined. The C64 is persistence structure
// at 1,022,727 ticks per second.
//
// Derives from: theory.computing.c64.cpu, theory.computing.c64.vic,
//               theory.computing.c64.sid, theory.computing.c64.cia
  """
}
