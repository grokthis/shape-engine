shape theory.computing.silicon : theory.computing, theory.chemistry.bonding {
  type: structure
  layer: 0
  """
// Layer 0: Silicon Substrate.
//
// Silicon (Z=14): [Ne]3s^2 3p^2. Four valence electrons.
// Same column as carbon: tetrahedral bonding (sp3).
// Pure silicon: covalent crystal lattice, each atom bonded to
// 4 neighbors. Semiconductor: small band gap (1.12 eV).
//
// The band gap is why silicon computes:
//   Insulator: large gap, no current flows.
//   Conductor: no gap, current always flows.
//   Semiconductor: small gap, current flows OR NOT depending
//     on conditions. This conditional flow is the physical
//     basis of switching. Switching is the physical basis of logic.
//
// Doping: introducing impurity atoms to control conductivity.
//   N-type: phosphorus (Z=15, 5 valence e-) donates extra electron.
//     Free electrons available as charge carriers.
//   P-type: boron (Z=5, 3 valence e-) creates electron "hole."
//     Holes move as positive charge carriers.
//
// The P-N junction:
//   P-type meets N-type. At the boundary, electrons and holes
//   recombine, creating a depletion zone with no free carriers.
//   The depletion zone is a voltage barrier.
//   Forward bias (P positive): barrier shrinks, current flows.
//   Reverse bias (P negative): barrier grows, no current.
//   This directional current flow is the diode: the simplest
//   active semiconductor device.
//
// Voltage as character:
//   High voltage (V_DD, typically 0.7-1.2V at modern nodes) = 1.
//   Low voltage (V_SS, ground, 0V) = 0.
//   The binary digit is a voltage level. Character at any point
//   in the circuit is a voltage. Structure is the circuit topology.
//
// Derives from: theory.computing, theory.chemistry.bonding
  """
}
