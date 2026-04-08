shape theory.chemistry.shells : theory.chemistry.quantum-numbers, theory.chemistry.exclusion, theory.coherence.law0 {
  type: theorem
  layer: 0
  """
// Shell Filling Rules from Coherence.
//
// Aufbau Principle (building up):
// Electrons fill the lowest-energy available state first.
// This is Law 0: the atom persists stably only if its structure
// is coherent. The lowest-energy configuration is the most
// coherent: it minimizes the total mixing angle (least structural
// commitment for the given electron count).
//
// The filling order follows approximate energy ordering:
//   1s, 2s, 2p, 3s, 3p, 4s, 3d, 4p, 5s, 4d, 5p, 6s, 4f, 5d,
//   6p, 7s, 5f, 6d, 7p
//
// The ordering rule: fill by n+l first, then by n within each
// n+l group. This is because the energy of an orbital depends on
// both radial extent (n) and angular commitment (l). The mixing
// angle theta increases with both: more radial nodes AND more
// angular commitment both increase structural complexity.
//
// Hund's Rules (within a subshell):
// 1. Maximize total spin first (fill each m_l with one electron
//    before pairing). This minimizes electron-electron repulsion:
//    same-spin electrons avoid each other (exclusion keeps them
//    in different spatial orbitals), reducing U(1) repulsive
//    coupling. Lower coupling = lower energy = more coherent.
//
// 2. Maximize total orbital angular momentum (consistent with
//    rule 1). More coherent angular distribution around the
//    nucleus means more symmetric contact geometry, satisfying
//    Law 1 (balanced reference) more efficiently.
//
// 3. For less than half-filled subshells: minimize total J = |L-S|.
//    For more than half-filled: maximize J = L+S.
//    This follows from the spin-orbit coupling geometry: the
//    SU(2) chirality of the electron (spin) couples to its
//    angular momentum (orbital). The coupling energy depends on
//    whether spin and orbit are aligned or anti-aligned.
//
// Shell capacities: 2, 8, 18, 32 (= 2n^2).
// Subshell capacities: s=2, p=6, d=10, f=14 (= 2(2l+1)).
//
// Derives from: theory.chemistry.quantum-numbers,
//               theory.chemistry.exclusion,
//               theory.coherence.law0 (lowest energy = most coherent)
  """
}
