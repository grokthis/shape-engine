shape theory.computing.cache : theory.computing.memory.sram, theory.computing.memory.dram {
  type: structure
  layer: 0
  """
// Layer 8: Cache Hierarchy.
//
// The memory hierarchy is an emergence stack: each level is
// faster and smaller, holding the most-referenced data.
// This is structural locality: recent references predict
// future references (temporal locality), and nearby addresses
// predict nearby accesses (spatial locality).
//
// L1 Instruction Cache (L1I): 64 KB per core.
//   4-way set associative. 64-byte lines. 1-cycle access.
//   Read-only (instructions don't self-modify in idealized arch).
//   256 sets x 4 ways x 64 bytes = 65536 bytes.
//
// L1 Data Cache (L1D): 64 KB per core.
//   8-way set associative. 64-byte lines. 1-cycle access.
//   Read/write. Write-back policy (writes go to cache first,
//   written to lower levels on eviction).
//   128 sets x 8 ways x 64 bytes = 65536 bytes.
//
// L2 Unified Cache: 512 KB per core.
//   8-way set associative. 64-byte lines. 8-cycle access.
//   Inclusive of L1 (everything in L1 is also in L2).
//   1024 sets x 8 ways x 64 bytes = 524288 bytes.
//
// L3 Shared Cache: 32 MB shared across all cores.
//   16-way set associative. 64-byte lines. 30-cycle access.
//   Shared: any core can access any line.
//   32768 sets x 16 ways x 64 bytes = 33554432 bytes.
//
// Cache operation:
//   Address decomposition: [tag | set index | block offset]
//   Hit: tag matches in the indexed set. Return data.
//   Miss: fetch line from next level. Evict if set full
//     (LRU replacement: least recently used line evicted).
//
// Coherence protocol (multi-core, MESI):
//   Modified: this cache has the only valid copy, dirty.
//   Exclusive: this cache has the only valid copy, clean.
//   Shared: multiple caches have valid copies, read-only.
//   Invalid: line is not valid.
//   When one core writes, other copies become Invalid.
//   This is Law 3 in hardware: inconsistent copies of shared
//   state must resolve.
//
// Derives from: theory.computing.memory.sram, theory.computing.memory.dram
  """
}
