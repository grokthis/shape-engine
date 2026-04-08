shape theory.chemistry.quantum-numbers : theory.chemistry, theory.physics.lattice, theory.physics.su2, theory.dimension.chirality {
  type: theorem
  layer: 0
  """
// Quantum Numbers from Lattice Geometry.
//
// An electron orbiting a nucleus is a standing wave on spherical
// geometry (the Planck lattice is spherical, Theorem 2.2). The
// standing wave must satisfy Law 1 (closure) on this geometry.
//
// The independent structural parameters of the standing wave are
// the quantum numbers. Each counts an independent way the electron
// can organize around the nucleus:
//
// n (principal, 1,2,3,...):
//   The emergence layer of the electron shell. How many radial
//   nodes the standing wave has. Higher n = further from nucleus =
//   higher energy. n counts the radial structure: the number of
//   complete wavelengths between nucleus and outer boundary.
//   This is the mixing angle scope: n determines the persistence
//   magnitude p of the electron's orbital.
//
// l (angular momentum, 0..n-1):
//   Chiral commitment on the SU(2)-complex. How much of the
//   electron's structure is in angular form vs radial form.
//   l=0 (s): spherically symmetric, no angular commitment.
//   l=1 (p): one axis of angular commitment (3 orientations).
//   l=2 (d): two axes of angular commitment (5 orientations).
//   l=3 (f): three axes of angular commitment (7 orientations).
//   The maximum l = n-1 because angular commitment cannot exceed
//   the total structural capacity at that shell.
//
// m_l (magnetic, -l..+l):
//   Generator projection of the angular momentum. Which of the
//   {X, Y, Z} generators (and their combinations) the angular
//   commitment projects onto. For l=1: m_l = -1,0,+1 gives
//   three orthogonal orientations (p_x, p_y, p_z corresponding
//   to the three generators). For l=2: five projections. For l=3:
//   seven. The count 2l+1 is the number of independent orientations
//   on a sphere for a given angular commitment.
//
// m_s (spin, +1/2 or -1/2):
//   Chirality direction on the SU(2)-complex. The electron is
//   spin-1/2: its standing wave closes over two traversals of
//   the SU(2) triangle. Two traversal directions (aligned or
//   anti-aligned with the Higgs-defined forward). This gives
//   exactly 2 spin states per orbital.
//
// Total states per shell n:
//   Sum over l=0..n-1 of (2l+1) * 2 = 2n^2.
//   n=1: 2.  n=2: 8.  n=3: 18.  n=4: 32.
//
// Derives from: theory.chemistry, theory.physics.lattice (spherical),
//               theory.physics.su2 (chirality/spin),
//               theory.dimension.chirality (angular structure)
  """
}
