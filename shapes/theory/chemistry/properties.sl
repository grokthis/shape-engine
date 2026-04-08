shape theory.chemistry.properties : theory.chemistry.periodic-table, theory.chemistry.bonding, theory.mixing.complexity-capacity {
  type: theorem
  layer: 0
  """
// Periodic Properties from Structural Geometry.
//
// Each property is a structural measurement of the atom's
// electron configuration. The periodic trends follow from
// shell structure + nuclear charge.
//
// Ionization Energy (IE):
//   Energy to remove the outermost electron. Measures how tightly
//   the valence electron is bound. IE = structural complexity of
//   removing an electron while maintaining coherence.
//   Trend: increases across a period (higher Z, same shell =
//     stronger U(1) coupling to nucleus). Decreases down a group
//     (higher n = further from nucleus = weaker coupling).
//   Exceptions: half-filled and filled subshells have extra
//     stability (Hund's rules). IE dips at B (2p^1 vs 2s^2) and
//     O (2p^4 vs 2p^3) because breaking symmetry costs less than
//     breaking a filled/half-filled subshell.
//
// Electron Affinity (EA):
//   Energy released when adding an electron. Measures how much
//   more coherent the atom becomes with one more electron.
//   Trend: increases across a period (approaching filled shell).
//   Halogens (group 17) have highest EA: one electron from
//   closed shell.
//
// Electronegativity (EN):
//   Tendency to attract bonding electrons. Emergent from IE + EA.
//   EN = (IE + EA) / 2 (Mulliken scale).
//   Measures the atom's structural pull on shared electrons.
//   Fluorine is highest: small radius + high nuclear charge +
//   one electron from closed shell. Maximum structural demand.
//
// Atomic Radius:
//   Determined by outermost electron shell. Higher n = larger
//   radius (more radial nodes = further from nucleus).
//   Decreases across period: higher Z at same n pulls electrons
//   closer (stronger U(1) coupling, same shielding).
//   Increases down group: higher n.
//   The radius is the structural extent of the atom's standing
//   wave pattern.
//
// Metallic Character:
//   Tendency to lose electrons (low IE, low EA).
//   Structural capacity exceeds complexity: the atom has more
//   destination space than source specification. It gives up
//   electrons easily.
//   Increases down group (weaker binding), decreases across
//   period (stronger binding).
//
// Reactivity:
//   Distance from closed-shell configuration. Atoms far from
//   closed shell (groups 1, 17) are most reactive: they have
//   the most to gain structurally from bonding.
//   Noble gases (group 18): closed shell, maximum coherence,
//   minimal reactivity. They already satisfy all Laws.
//
// Derives from: theory.chemistry.periodic-table,
//               theory.chemistry.bonding,
//               theory.mixing.complexity-capacity (structural measures)
  """
}
