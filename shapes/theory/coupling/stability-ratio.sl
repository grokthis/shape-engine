shape theory.coupling.stability-ratio : theory.coupling.load-bearing {
  type: definition
  layer: 0
  """
// Definition 10.11 (Stability Ratio).
//   rho(A,B) = min(lambda(A,B), lambda(B,A)) / max(lambda(A,B), lambda(B,A))
//
// rho=0: complete one-way dependency (dominance).
// rho=1: perfectly balanced mutual dependency.
//
// Since lambda = sin(theta), the stability ratio is the ratio of
// the smaller to the larger mixing angle.
//
// Derives from: theory.coupling.load-bearing
  """
}
