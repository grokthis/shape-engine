shape theory.computing.memory.dram : theory.computing.memory {
  type: unit
  layer: 0
  """
// DRAM: Dynamic Random Access Memory.
//
// 1-transistor, 1-capacitor cell (1T1C):
//   Capacitor stores charge (1) or no charge (0).
//   Access transistor connects capacitor to bit line.
//   Read: word line high, charge flows to bit line, sense amp
//     detects. Reading is destructive: must write back.
//   Write: word line high, drive bit line to charge/discharge
//     capacitor.
//
// Dynamic: capacitor leaks. Must refresh every ~64ms.
//   Refresh = read every row and write it back.
//   Refresh is coherence maintenance: the stored state would
//   dissolve (leak to incoherence) without active upkeep.
//   This is Law 0 in hardware: persistence requires active
//   coherence maintenance.
//
// Dense (1 transistor per bit vs 6 for SRAM) but slower.
// Main memory: 8-64 GB. ~50-100ns access (~100-200 cycles).
//
// Organization:
//   Banks: independent memory arrays, can operate in parallel.
//   Rows (pages): ~8KB each. Opening a row loads it into the
//     row buffer (sense amps). Subsequent accesses to same row
//     are fast (row hit). Different row requires precharge +
//     activate (row miss). This is the memory equivalent of
//     cache locality.
//   Columns: individual words within a row.
//   Ranks and channels: parallel access paths.
//
// Idealized main memory: 64 GB.
//   Organized as 8 banks x 8 GB.
//   Row size: 8 KB. Column access: 64 bits (8 bytes).
//   Burst length: 8 (64 bytes per access = one cache line).
//
// Derives from: theory.computing.memory
  """
}
