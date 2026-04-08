shape theory.chemistry.bio.cell : theory.chemistry.bio.protein, theory.chemistry.bio.nucleotides, theory.chemistry.bio.metabolism, theory.self-reference {
  type: theorem
  layer: 0
  """
// The Cell as Self-Referential Shape.
//
// A cell is the minimal self-referential biological shape:
// a molecular system that includes itself in its own context
// and actively maintains its own coherence.
//
// The cell implements the transformation law at the biological
// scale:
//   S = the genome (DNA) + cellular machinery (ribosomes,
//       enzymes, membranes). The structure.
//   C = the current molecular state (metabolite concentrations,
//       protein levels, signaling states). The character.
//   M' = f(C, S): the cell at the next moment, produced by
//       gene expression, metabolism, and signaling.
//
// Self-reference (Theorem 3.7):
//   DNA encodes the proteins that replicate DNA.
//   DNA encodes the proteins that transcribe DNA.
//   DNA encodes the proteins that translate mRNA into proteins.
//   The cell references its own prior state at every step.
//   This is mandatory prior-state reference at the molecular level.
//
// The membrane as contact boundary:
//   The lipid bilayer defines self/not-self. It is the structural
//   boundary of the cell shape. What enters the cell's context
//   (through transport proteins) and what doesn't is determined
//   by the membrane's structure. This is Definition 5.4 (Context)
//   made physical.
//
// Cell division as branching:
//   DNA replication + cell division produces two cells from one.
//   This is a branch point (Definition 12.1): the structure
//   admits two coherent outcomes (two daughter cells with
//   potentially different character). The structural weight of
//   each outcome is equal (symmetric division) or unequal
//   (asymmetric division, as in stem cells).
//
// Cell types as structural equivalence classes:
//   All cells in an organism share the same genome (same S).
//   Different cell types express different genes (different C
//   trajectories through the same S). A neuron and a liver cell
//   are different traces through the same structure.
//   Differentiation is structural change (Definition 16.5):
//   gradual, recognizable, each step coherent.
//
// Derives from: theory.chemistry.bio.protein,
//               theory.chemistry.bio.nucleotides,
//               theory.chemistry.bio.metabolism,
//               theory.self-reference
  """
}
