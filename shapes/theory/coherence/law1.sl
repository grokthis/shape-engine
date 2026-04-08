shape theory.coherence.law1 : theory.coherence, theory.contact.self {
  type: law
  layer: 0
  """
// Law 1 (Stable Reference).
// Every contact must be stable. For any contact through which
// character enters a transformation, one of:
//
//   1. Closure: the contact is reciprocal (character flows in both
//      directions) and the resulting contact shape is bounded
//   2. Invariance: the source of character is invariant (M' = M)
//   3. Boundedness: the source is internally coherent and the
//      receiving structure tolerates its bounded evolution
//
// Derivation from self-contact: self-contact satisfies closure
// trivially (A contacts A). But the bounded condition is non-trivial:
// a shape's transformation must produce character that its own
// structure can handle at the next step. Stable self-contact requires
// stable self-reference.
//
// Extension to mutual contact: if A depends on B but B transforms
// without regard to A, A's persistence is hostage to B's trajectory.
// This is dominance: the incoherent anti-configuration.
//
// Derives from: theory.coherence, theory.contact.self
  """
}
