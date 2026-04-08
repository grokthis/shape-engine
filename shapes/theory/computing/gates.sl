shape theory.computing.gates : theory.computing.silicon.transistor {
  type: structure
  layer: 0
  """
// Layer 2: Logic Gates from CMOS.
//
// Each gate is a CMOS circuit: PMOS pull-up network + NMOS
// pull-down network. The networks are complementary: when one
// is on, the other is off.
//
// NOT (inverter): 1 PMOS + 1 NMOS. 2 transistors.
//   In=0: PMOS on, NMOS off -> out=1.
//   In=1: PMOS off, NMOS on -> out=0.
//   The simplest gate. Negation.
//
// NAND: 2 PMOS parallel + 2 NMOS series. 4 transistors.
//   Both inputs 1: both NMOS on -> out=0.
//   Any input 0: at least one PMOS on -> out=1.
//   NAND is functionally complete: any Boolean function can
//   be built from NAND gates alone.
//
// NOR: 2 PMOS series + 2 NMOS parallel. 4 transistors.
//   Both inputs 0: both PMOS on -> out=1.
//   Any input 1: at least one NMOS on -> out=0.
//   NOR is also functionally complete.
//
// AND: NAND + NOT. 6 transistors. Out=1 iff both inputs=1.
// OR: NOR + NOT. 6 transistors. Out=1 iff any input=1.
// XOR: (A NAND (A NAND B)) NAND (B NAND (A NAND B)). 12 transistors.
//   Out=1 iff inputs differ. The parity gate.
//   XOR is the structural content of "difference."
//
// Buffer (identity): two inverters in series. 4 transistors.
//   Restores signal strength without changing value.
//   The trivial transformation M' = M in hardware.
//
// Transmission gate: NMOS + PMOS in parallel, controlled by
//   complementary signals. Passes input to output when enabled.
//   The hardware multiplexer primitive.
//
// Fan-out: one output driving multiple inputs.
//   Each driven input is a capacitive load.
//   Maximum fan-out limited by drive strength.
//   Buffers inserted when fan-out exceeds capacity.
//
// Derives from: theory.computing.silicon.transistor
  """
}
