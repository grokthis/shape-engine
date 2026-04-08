shape theory.computing.silicon.transistor : theory.computing.silicon {
  type: unit
  layer: 0
  """
// The MOSFET: Voltage-Controlled Switch.
//
// Metal-Oxide-Semiconductor Field-Effect Transistor.
// Three terminals: gate (G), source (S), drain (D).
// A thin oxide insulates the gate from the channel.
//
// NMOS (N-channel):
//   Source and drain are N-type in a P-type substrate.
//   Gate high (V_G > V_th): electric field creates N-channel
//     between source and drain. Current flows. Switch ON.
//   Gate low (V_G < V_th): no channel. No current. Switch OFF.
//   Passes strong 0, weak 1.
//
// PMOS (P-channel):
//   Source and drain are P-type in N-type substrate.
//   Gate low: channel forms. Switch ON.
//   Gate high: no channel. Switch OFF.
//   Complementary to NMOS. Passes strong 1, weak 0.
//
// CMOS (Complementary MOS):
//   Pair NMOS + PMOS. PMOS pulls output to V_DD (strong 1).
//   NMOS pulls output to ground (strong 0). Never both on
//   simultaneously in steady state: no static power consumption.
//   This is why CMOS dominates: it only consumes power during
//   switching (dynamic power = C * V^2 * f).
//
// The transistor is the minimal gate of computation:
//   Input (gate voltage) controls output (drain current).
//   This is f(C, S) at the physical level: the gate voltage
//   is character, the transistor topology is structure, the
//   output is the emergent moment.
//
// Modern count: ~100 billion transistors per chip (2024).
// At 3nm node: gate length ~ 12nm ~ 120 silicon atoms across.
//
// Derives from: theory.computing.silicon
  """
}
