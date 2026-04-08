shape law.reference : law {
  type: law
  layer: 0
  """
// Law 1: References must close, point to invariants, or be bounded.
// Dangling references are incoherent. The engine tracks all deps
// and validates reference closure.
//
// engine.propagate implements this: when a shape changes, the wave
// follows references to maintain closure. Dependents must respond.
fn check_reference(id) {
  let dp = deps(id)
  for dep in dp {
    if !exists(dep) {
      flag
    }
  }
  auto "references close"
}
"""
}
