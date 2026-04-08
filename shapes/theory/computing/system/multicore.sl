shape theory.computing.system.multicore : theory.computing.system, theory.computing.cache {
  type: structure
  layer: 0
  """
// Multi-Core Processor.
//
// Idealized: 8 cores on one die.
// Each core: independent pipeline + L1I + L1D + L2.
// Shared: L3 cache + memory controller + I/O.
//
// Per core:
//   5-stage pipeline (fetch, decode, execute, memory, writeback).
//   64 KB L1I + 64 KB L1D (private).
//   512 KB L2 (private).
//   Branch predictor (private).
//   32 x 64-bit registers (private).
//
// Shared:
//   32 MB L3 cache (16-way, shared across all 8 cores).
//   Memory controller (dual channel DDR5, 64 GB).
//   Coherence directory (tracks which core has each cache line).
//   Ring bus or mesh interconnect between cores and L3 slices.
//
// Cache coherence (MESI protocol):
//   When core 0 writes to address X:
//     1. Core 0 sends invalidate on bus.
//     2. All other cores with X in Shared/Exclusive -> Invalid.
//     3. Core 0 moves to Modified.
//   When core 1 reads X (held Modified by core 0):
//     1. Core 1 misses in its cache.
//     2. Coherence directory identifies core 0 has it Modified.
//     3. Core 0 writes back to L3, transitions to Shared.
//     4. Core 1 gets copy, transitions to Shared.
//   This is Law 3 operating continuously: inconsistent copies
//   of shared state must resolve at every access.
//
// Total transistor budget (approximate):
//   Per core: ~500M transistors.
//   L3 cache (32 MB): ~3B transistors.
//   Memory controller + I/O: ~500M transistors.
//   Total: ~7.5B transistors.
//   At 3nm node: die area ~150 mm^2.
//
// Clock: 3.5 GHz base, 5.0 GHz boost (single-core turbo).
// Power: 125W TDP (thermal design power).
// Performance: ~8 IPC x 8 cores x 4 GHz avg = ~256 billion
//   operations per second (idealized peak).
//
// Derives from: theory.computing.system, theory.computing.cache
  """
}
