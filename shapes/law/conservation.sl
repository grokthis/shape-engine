shape law.conservation : law {
  type: law
  layer: 0
  """
// Law 2: No structure from nothing, no destruction into nothing.
// You cannot remove a shape that others depend on.
// You cannot create a shape without the system recording it.
// Every mutation advances the tick. Every change is traced.
//
// engine.trace implements conservation of history.
// rm checks dependents before allowing removal.
fn check_conservation(id) {
  if !exists(id) {
    flag
  }
  auto "conserved"
}
"""
}
