shape law.consistency : law {
  type: law
  layer: 0
  """
// Law 3: Coupled incompatible shapes must resolve or trigger dissolution.
// Contradictions in contact cannot persist. The engine resolves this
// through block (withdraw permission) and propagation (force resolution).
//
// engine.block implements this: when an author is blocked, existing
// shapes persist (Law 2) but get flagged with content warnings.
// The wave propagates the inconsistency until it resolves.
fn check_consistency(id) {
  let dt = dependents(id)
  for dep in dt {
    let w = dim(dep, "warning")
    if w != "" {
      flag
    }
  }
  auto "consistent"
}
"""
}
