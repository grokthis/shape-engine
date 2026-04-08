shape law.persistence : law {
  type: law
  layer: 0
  """
// Law 0: A shape persists stably only if its structure is coherent.
// Incoherent shapes dissolve. This is the axiom.
//
// The engine implements this as: validate() checks all shapes,
// edit() propagates waves to maintain coherence after mutation,
// the store persists only what the engine holds.
//
// On a shape machine, this law IS the persistence mechanism.
// In emulation, engine.validate + engine.store implement it.
fn check_persistence(id) {
  if !exists(id) {
    absorb
  }
  let dp = deps(id)
  for dep in dp {
    if !exists(dep) {
      flag
    }
  }
  auto "persists"
}
"""
}
