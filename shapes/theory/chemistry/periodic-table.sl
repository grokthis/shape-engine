shape theory.chemistry.periodic-table : theory.chemistry.shells, theory.chemistry.nucleus {
  type: theorem
  layer: 0
  """
// The Periodic Table as Canopy.
//
// The periodic table is the complete enumeration of coherent
// atomic configurations: every nuclear charge Z with its
// ground-state electron configuration.
//
// Structure generates the table:
//   Z determines the nucleus (number of protons).
//   Shell filling rules determine electron configuration.
//   Electron configuration determines chemical properties.
//   The table IS the canopy of these rules.
//
// Periods (rows): determined by principal quantum number n.
//   Period 1: n=1 filling (2 elements: H, He)
//   Period 2: n=2 filling (8 elements: Li-Ne)
//   Period 3: n=3 s,p filling (8 elements: Na-Ar)
//   Period 4: n=4 s, n=3 d, n=4 p (18 elements: K-Kr)
//   Period 5: n=5 s, n=4 d, n=5 p (18 elements: Rb-Xe)
//   Period 6: n=6 s, n=4 f, n=5 d, n=6 p (32 elements: Cs-Rn)
//   Period 7: n=7 s, n=5 f, n=6 d, n=7 p (32 elements: Fr-Og)
//
// Groups (columns): determined by valence electron count.
//   Elements in the same group have the same valence configuration.
//   Same valence = same chemical behavior = same position in canopy.
//
// Blocks: determined by the subshell being filled.
//   s-block (groups 1-2): filling s orbitals. 2 groups.
//   p-block (groups 13-18): filling p orbitals. 6 groups.
//   d-block (groups 3-12): filling d orbitals. 10 groups.
//   f-block (lanthanides, actinides): filling f orbitals. 14 groups.
//   Total groups: 2 + 6 + 10 + 14 = 32 = 2(4)^2... but the table
//     shows 18 because f-block is extracted. The 32 reflects the
//     maximum shell capacity at n=4.
//
// Why the table has its shape:
//   The n+l filling rule creates the characteristic "step" pattern.
//   3d fills after 4s because 4s has lower n+l (4+0=4 vs 3+2=5).
//   4f fills after 6s for the same reason (6+0=6 vs 4+3=7).
//   The table's shape is the geometry of shell filling projected
//   onto the Z axis.
//
// Derives from: theory.chemistry.shells, theory.chemistry.nucleus
  """
}
