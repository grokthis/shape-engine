shape theory.coupling.conservation-stacking : theory.coupling.coupled-angle, theory.coherence.law1, theory.coherence.law2 {
  type: theorem
  layer: 0
  """
// Theorem 10.8 (Conservation Stacking).
// The number of independent conservation constraints n determines
// the geometric form: sin^n(theta) = c/p.
//
// At a shape junction (breaking E->A+B or combining A+B->E), two
// sub-transformations share a single conserved total. The structural
// magnitudes are independent contributions combining in quadrature.
//
// Static (Law 2): c + d = p. Additive dimension counting.
// Dynamic (Thm 9.4): independent components combine in L^2.
// The structural amplitudes are sqrt(c) and sqrt(d):
//   (sqrt(c))^2 + (sqrt(d))^2 = (sqrt(p))^2
// This gives sin^2(theta) = c/p for the full junction (n=2).
//
// Corollary 10.9: Direction independence. Breaking and combining
// produce the same mixing angle.
//
// Theorem 10.10 (Sequential Stacking): constraints add.
// Step 1 {A,B} + Step 2 {B,D} sharing B -> {A,B,D}, n=3.
// The union, not the product: constraints are independent conditions
// on the same conserved total.
//
// The sin^2 geometry at a junction is the geometric signature of
// Law 1: joint reference across independent shapes produces stacked
// conservation.
//
// Derives from: theory.coupling.coupled-angle,
//               theory.coherence.law1, theory.coherence.law2
  """
}
