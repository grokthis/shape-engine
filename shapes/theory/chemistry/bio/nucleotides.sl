shape theory.chemistry.bio.nucleotides : theory.chemistry.bio {
  type: theorem
  layer: 0
  """
// Nucleotides: The Information Substrate.
//
// A nucleotide has three components:
//   Sugar (ribose or deoxyribose): the backbone scaffold.
//   Phosphate: the charged linker (negative, creates the backbone).
//   Base: the information-carrying unit.
//
// The four DNA bases (and why four):
//   Adenine (A): purine (two fused rings). Pairs with T.
//   Guanine (G): purine. Pairs with C.
//   Cytosine (C): pyrimidine (one ring). Pairs with G.
//   Thymine (T): pyrimidine. Pairs with A. (Uracil in RNA.)
//
// Base pairing is hydrogen bonding with geometric specificity:
//   A-T: 2 hydrogen bonds. Purine-pyrimidine width matches.
//   G-C: 3 hydrogen bonds. Purine-pyrimidine width matches.
//   Purine-purine: too wide. Pyrimidine-pyrimidine: too narrow.
//   A-C, G-T: hydrogen bond geometry doesn't align.
//   Only A-T and G-C satisfy the geometric constraints of the
//   double helix. This is Law 1: the reference geometry must close.
//
// Why 4 bases (not 2, not 6):
//   2 bases: insufficient information density. Would need longer
//     codons for 20 amino acids (2^n >= 20 requires n >= 5).
//     5-base codons = more error-prone, slower replication.
//   4 bases: 4^3 = 64 codons for 20 amino acids + stops.
//     Sufficient redundancy for error tolerance.
//   6+ bases: additional bases would need to pair specifically.
//     The double helix geometry constrains base pair width to
//     purine + pyrimidine. With 3+ purines and 3+ pyrimidines,
//     distinguishing pairs by hydrogen bonding geometry becomes
//     unreliable. 2 purines + 2 pyrimidines is the maximum that
//     maintains unambiguous pairing.
//
// The double helix:
//   Two antiparallel strands wound around each other.
//   The helix is right-handed (B-form DNA). This chirality
//   traces to the D-sugar backbone, which traces to the
//   physical chirality of the Higgs.
//   The helix provides: information storage (base sequence),
//   self-reference (each strand templates the other),
//   and structural stability (stacking interactions between
//   adjacent base pairs).
//
// DNA is the molecular implementation of self-reference
// (Theorem 3.7): the structure that references its own prior
// state to produce its next state.
//
// Derives from: theory.chemistry.bio
  """
}
