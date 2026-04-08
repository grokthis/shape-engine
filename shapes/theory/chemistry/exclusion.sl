shape theory.chemistry.exclusion : theory.chemistry.quantum-numbers, theory.uniqueness, theory.coherence.law3 {
  type: theorem
  layer: 0
  """
// Pauli Exclusion Principle from Structural Identity.
//
// Two electrons cannot occupy the same quantum state at the same
// atom. In shape theory: two identical standing waves on the same
// structure would be the same shape, not two shapes.
//
// Identity is structural (Corollary 16.4a): a shape's identity is
// its complete trace (structure + character). Two electrons at the
// same atom with identical (n, l, m_l, m_s) would have identical
// structure and identical character trajectory. They would be one
// electron, not two. There is no structural content to individuate
// a second copy (same argument as uniqueness of empty_s, Thm 4.6).
//
// Conversely: two electrons differing in ANY quantum number are
// structurally distinct. They are different shapes and can coexist.
//
// For spin-1/2 particles specifically: the standing wave requires
// two traversals to close. The two traversal directions (m_s = +1/2
// and -1/2) are the only spin states. So each spatial orbital
// (n, l, m_l) holds exactly 2 electrons.
//
// For bosons (integer spin): the standing wave closes in one
// traversal. Multiple bosons CAN occupy the same state because
// their character (amplitude) is additive: more bosons = larger
// amplitude = different character from fewer bosons. Each count
// is a structurally distinct shape.
//
// This is Law 3: coupled identical fermions must resolve (they
// cannot both persist as the same shape), while coupled identical
// bosons resolve by superposition (coherent addition).
//
// Derives from: theory.chemistry.quantum-numbers,
//               theory.uniqueness (identity argument),
//               theory.coherence.law3 (incompatible shapes resolve)
  """
}
