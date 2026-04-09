shape theory.computing.stack.dilate : theory.computing.stack {
  type: definition
  layer: 0
  """
// Time Dilation.
//
// When substrate A runs inside substrate B, A experiences more ticks
// per B-tick. This is time dilation: the inner system's clock runs
// faster relative to the outer system's clock.
//
// The dilation factor is structural, not configured. It emerges from
// the ratio of inner to outer tick rates. A RISC-V core running at
// 1GHz inside a shape engine ticking at 1MHz dilates time by 1000x:
// the inner system completes 1000 operations per outer tick.
//
// Application to signatures:
//
// The signature fold (hash over all shapes under a prefix) is a
// computation that can be time-dilated. By pre-sorting the shape
// index at mutation time (O(log n) insert), the fold at read time
// becomes a linear scan over contiguous memory: binary search to
// find the prefix boundary, then stream 32-byte hashes into SHA-256.
//
// The dilation: the O(n log n) sort that would happen at fold time
// is distributed across O(n) mutations, each paying O(log n). From
// the fold's perspective, the sort already happened. Time dilated.
//
// This is general. Any computation that can be partially evaluated
// at write time runs faster at read time. The pre-computation is
// the inner substrate; the fold is the outer substrate. The ratio
// of work moved from read to write is the dilation factor.
//
// Properties:
//
//   inner_tick_rate: uint    Ticks per unit time in inner substrate
//   outer_tick_rate: uint    Ticks per unit time in outer substrate
//   factor: float            inner / outer (the dilation)
//
// A time-dilated computation:
//   Structure: the pre-computed index (what governs the fold)
//   Character: the fold result (what changes per invocation)
//   Tick: the outer tick at which the fold was computed
//
// The key insight: the index never invalidates because each shape
// carries its own hash. The sort order is invariant under mutation
// (IDs don't change). Only inserts and removes modify the index,
// and they do so in O(log n) — the dilation cost.
//
// Derives from: theory.computing.stack
  """
}
