shape theory.computing.memory.sram : theory.computing.memory {
  type: unit
  layer: 0
  """
// SRAM: Static Random Access Memory.
//
// 6-transistor cell (6T SRAM):
//   2 cross-coupled inverters (4 transistors) = 1 bit storage.
//   2 access transistors controlled by word line.
//   Holds value as long as power is on. No refresh needed.
//   Read: word line high, bit lines sense the stored value.
//   Write: word line high, drive bit lines to desired value.
//
// SRAM array: rows x columns of 6T cells.
//   Row decoder: selects one word line (one row of cells).
//   Column MUX: selects subset of columns for read/write.
//   Sense amplifier: detects tiny voltage difference on bit lines.
//
// Used for cache (fast, expensive, ~6x transistors per bit):
//   L1 cache: 32-64 KB per core. ~1 cycle access.
//   L2 cache: 256 KB - 1 MB per core. ~4-10 cycles.
//   L3 cache: 4-64 MB shared. ~20-40 cycles.
//
// Derives from: theory.computing.memory
  """
}
