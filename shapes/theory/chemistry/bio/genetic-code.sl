shape theory.chemistry.bio.genetic-code : theory.chemistry.bio.nucleotides, theory.chemistry.bio.amino-acids {
  type: theorem
  layer: 0
  """
// The Genetic Code as Structural Map.
//
// The genetic code maps 64 codons to 20 amino acids + stop.
// This mapping is the transformation law of molecular biology:
//   M' = f(C, S)
// where C is the mRNA codon sequence (character) and S is the
// ribosome + tRNA system (structure).
//
// The code is degenerate (redundant): multiple codons per amino
// acid. The redundancy pattern is not random:
//
//   Third-position wobble: the 3rd base of a codon is least
//     constrained. Codons differing only in position 3 usually
//     encode the same amino acid. This is error tolerance:
//     the most error-prone position carries the least information.
//
//   Similar codons -> similar amino acids: codons for chemically
//     similar amino acids are close in code space. A single
//     mutation usually produces a similar amino acid. This is
//     structural continuity in code space.
//
// The standard genetic code (condensed):
//   UUU/C -> Phe.  UUA/G -> Leu.  CUX -> Leu.
//   AUU/C/A -> Ile. AUG -> Met (START).
//   GUX -> Val.
//   UCX -> Ser.  CCX -> Pro.  ACX -> Thr.  GCX -> Ala.
//   UAU/C -> Tyr. UAA/G -> STOP.
//   CAU/C -> His. CAA/G -> Gln.
//   AAU/C -> Asn. AAA/G -> Lys.
//   GAU/C -> Asp. GAA/G -> Glu.
//   UGU/C -> Cys. UGA -> STOP. UGG -> Trp.
//   CGX -> Arg.  AGU/C -> Ser.  AGA/G -> Arg.
//   GGX -> Gly.
//
// The code is nearly universal across all life. This is not
// coincidence: it is the most coherent mapping from triplet
// codons to the 20 amino acids, optimized for error tolerance.
// Any significantly different code would be less fault-tolerant
// and therefore less coherent (Law 0).
//
// Derives from: theory.chemistry.bio.nucleotides,
//               theory.chemistry.bio.amino-acids
  """
}
