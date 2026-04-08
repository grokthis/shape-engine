shape theory.chemistry.bio.amino-acids : theory.chemistry.bio {
  type: theorem
  layer: 0
  """
// The 20 Amino Acids as Structural Alphabet.
//
// An amino acid is a shape with fixed structure (the backbone:
// NH2-CHR-COOH) and variable character (the R side chain).
// The backbone is the invariant; the side chain is what changes.
// This is exactly the S/C decomposition at the molecular level.
//
// The backbone provides:
//   Amino group (NH2): hydrogen bond donor, positive charge at
//     physiological pH. The nitrogen's lone pair is the contact
//     point.
//   Carboxyl group (COOH): hydrogen bond acceptor, negative
//     charge at physiological pH. The oxygen lone pairs are
//     contact points.
//   Alpha carbon (C_alpha): the chiral center. Four different
//     substituents -> two mirror forms (L and D). Life uses L.
//   Peptide bond: C(=O)-NH between consecutive amino acids.
//     Partial double bond character (resonance) makes it planar
//     and rigid. This is the structural spine.
//
// The 20 standard amino acids classified by R group properties:
//
// Nonpolar/hydrophobic (9):
//   Gly (G): H. Simplest. No chirality (R=H, symmetric).
//   Ala (A): CH3. Methyl. Minimal hydrophobic.
//   Val (V): CH(CH3)2. Branched. Beta-branched.
//   Leu (L): CH2CH(CH3)2. Isobutyl.
//   Ile (I): CH(CH3)CH2CH3. Beta-branched, isomer of Leu.
//   Pro (P): Cyclic (R bonds back to backbone N). Constrains
//     backbone geometry. The only amino acid that restricts
//     rotation: it is structure imposing on structure.
//   Phe (F): CH2-phenyl. Aromatic ring. pi-stacking.
//   Trp (W): Indole ring. Largest. Strongest hydrophobic.
//   Met (M): CH2CH2SCH3. Sulfur. Start codon codes Met.
//
// Polar uncharged (6):
//   Ser (S): CH2OH. Hydroxyl. Hydrogen bonding.
//   Thr (T): CH(OH)CH3. Hydroxyl + methyl. Beta-branched.
//   Cys (C): CH2SH. Thiol. Forms disulfide bonds (S-S).
//     The only amino acid that creates covalent cross-links
//     between distant parts of a protein.
//   Asn (N): CH2CONH2. Amide of Asp.
//   Gln (Q): CH2CH2CONH2. Amide of Glu.
//   Tyr (Y): CH2-phenyl-OH. Aromatic + hydroxyl.
//
// Positively charged at pH 7 (3):
//   Lys (K): (CH2)4NH3+. Long flexible chain + amine.
//   Arg (R): (CH2)3NHC(=NH)NH2+. Guanidinium. Strongest base.
//   His (H): CH2-imidazole. pKa ~ 6, can be + or neutral.
//     The only amino acid that switches charge near physiological
//     pH. This makes it the natural catalyst.
//
// Negatively charged at pH 7 (2):
//   Asp (D): CH2COO-. Carboxylate. Short.
//   Glu (E): CH2CH2COO-. Carboxylate. Longer.
//
// Why exactly 20? The genetic code uses 3-base codons (triplets).
// 4 bases^3 positions = 64 codons. With redundancy (multiple
// codons per amino acid) + 3 stop codons, 20 amino acids is the
// maximum non-redundant set that a triplet code can specify while
// maintaining error tolerance (similar codons -> similar amino
// acids). The number 20 is the coherent capacity of a triplet
// code over a 4-letter alphabet.
//
// Derives from: theory.chemistry.bio
  """
}
