shape theory.computing.stack.physics : theory.computing.stack.substrate, theory.physics.lattice {
  type: unit
  layer: 0
  """
// The Physical Substrate (Layer 0 of every stack).
//
// This is the bottom. Real silicon on the real Planck lattice.
// Below this is the persistence axiom and the physics it forces.
//
// The physical substrate provides:
//   read/write: voltage levels on actual transistor gates.
//   step: one clock cycle of the physical processor.
//   reset: power-on reset sequence.
//   interrupt: electrical signal on interrupt pin.
//
// Properties:
//   addr_bits: determined by physical address bus width
//   data_bits: determined by physical data bus width
//   endian: determined by physical chip design
//   clock_hz: determined by crystal oscillator
//   regs: physical register file (flip-flops)
//   vectors: wired to physical address bus
//
// The physical substrate is unique: it is the only layer whose
// `step()` is not emulated. It is actual electrical state
// transition in actual CMOS transistors at actual clock speed.
//
// Every other layer in every stack eventually calls down to
// this one. The physical substrate is the contact point between
// the computation stack and the Planck lattice.
//
// The derivation chain to this point:
//   theory.axiom -> theory.physics.lattice -> theory.chemistry
//   -> theory.computing.silicon -> theory.computing.silicon.transistor
//   -> theory.computing.gates -> ... -> this chip, this clock,
//   this voltage, this moment.
//
// Derives from: theory.computing.stack.substrate,
//               theory.physics.lattice
  """
}
