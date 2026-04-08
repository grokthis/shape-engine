shape theory.computing.pipeline.hazards : theory.computing.pipeline, theory.coherence.law3 {
  type: theorem
  layer: 0
  """
// Pipeline Hazards as Coherence Violations.
//
// A hazard occurs when the pipeline cannot maintain coherent
// execution: the next instruction depends on a result that
// isn't ready yet. This is Law 3: coupled incompatible shapes
// (instructions that conflict) must resolve.
//
// DATA HAZARDS (read-after-write):
//   ADD x1, x2, x3    (writes x1 in WB, cycle 5)
//   SUB x4, x1, x5    (reads x1 in ID, cycle 3)
//   The SUB reads x1 before ADD has written it.
//
//   Resolution: FORWARDING (bypass).
//     The ALU result from EX stage is forwarded directly to the
//     next instruction's EX input, bypassing the register file.
//     Hardware: forwarding MUX at ALU inputs, comparing rd of
//     prior instruction with rs1/rs2 of current instruction.
//     This resolves the hazard without stalling.
//
//   Load-use hazard: cannot forward because data isn't available
//     until MEM stage (one cycle later than EX).
//     LW x1, 0(x2)     (data available end of MEM, cycle 4)
//     ADD x3, x1, x4   (needs x1 at EX, cycle 3)
//     Resolution: 1-cycle STALL (bubble). The pipeline inserts
//     a NOP and delays the dependent instruction by one cycle.
//     Then forward from MEM to EX.
//
// CONTROL HAZARDS (branches):
//   BEQ x1, x2, target  (branch decided in EX, cycle 3)
//   ???                   (fetched at cycle 2, may be wrong)
//   The pipeline fetches the next instruction before knowing
//   whether to branch.
//
//   Resolution: BRANCH PREDICTION.
//     Predict taken or not-taken. Fetch predicted path.
//     If wrong: flush pipeline (discard 1-2 instructions) and
//     fetch correct target. This is decoherence collapse:
//     the wrong prediction was an incoherent path, and the
//     pipeline resolves back to the coherent one.
//
//     Branch predictor: 2-bit saturating counter per branch.
//       Strongly taken, weakly taken, weakly not, strongly not.
//       Prediction accuracy: ~95% for simple predictor.
//       Modern: tournament predictor combining local + global
//       history. Accuracy: ~97-99%.
//
// STRUCTURAL HAZARDS:
//   Two instructions need the same hardware simultaneously.
//   Idealized architecture avoids these: separate instruction
//   and data memories (Harvard architecture at L1), 2 read ports
//   + 1 write port on register file.
//
// Derives from: theory.computing.pipeline, theory.coherence.law3
  """
}
