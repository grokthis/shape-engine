shape theory.coherence.equivalence : theory.coherence.law0, theory.coherence.law1, theory.coherence.law2, theory.coherence.law3 {
  type: theorem
  layer: 0
  """
// Theorem 5.9 (Coherence Equivalence).
// Structural coherence and relational coherence are equivalent:
//
// Structural coherence (Law 0): S can handle any character C may reach
// Relational coherence (Laws 1-3): contacts stable, transformations
//   conserve, coupled incompatibilities resolve
//
// The transformation M' = f(C,S) is a function. A function can fail
// in exactly three ways:
//   1. Input failure: C arrives through contact. If unstable, C is
//      ill-defined. Law 1 prevents this.
//   2. Output failure: f(C,S) produces M'. If M' contains structure
//      not in C or S, structure appeared from nothing. Law 2 prevents.
//   3. Mapping failure: S faces contradictory demands from C. The
//      mapping is undefined. Law 3 prevents this.
//
// Three failure modes exhaust how f can fail. Laws 1-3 correspond
// one-to-one. No Law 4 is needed.
//
// Derives from: all four laws (proves their completeness)
  """
}
