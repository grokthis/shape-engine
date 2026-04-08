shape theory.computing.memory : theory.computing.gates, theory.self-reference {
  type: structure
  layer: 0
  """
// Layer 4: Sequential Circuits and Memory.
//
// Combinational circuits have no memory: output depends only on
// current input. Sequential circuits have state: output depends
// on current input AND prior state. This is M' = f(C, S) where
// the circuit's stored state is part of C.
//
// SR Latch: two cross-coupled NOR (or NAND) gates.
//   Set=1: output goes to 1 and stays.
//   Reset=1: output goes to 0 and stays.
//   Both=0: output holds previous value.
//   Both=1: forbidden (incoherent, violates Law 3).
//   The latch IS self-reference in hardware: each gate's output
//   feeds back to the other's input. The circuit references its
//   own prior state. This is Theorem 3.7 in silicon.
//
// D Flip-Flop: captures input on clock edge.
//   Master-slave: two latches. Master opens on clock=0 (captures
//   input). Slave opens on clock=1 (passes to output). The output
//   changes only at the clock edge. This is the discrete moment:
//   M -> M' happens at each clock tick, not continuously.
//   This is Theorem 3.5 (moment discreteness) in hardware.
//
// Register: N flip-flops in parallel. Stores N-bit word.
//   64-bit register: 64 D flip-flops sharing a clock + write-enable.
//   When WE=1 and clock edge: all 64 bits captured simultaneously.
//   When WE=0: register holds its value indefinitely.
//
// Register file: array of registers with read/write ports.
//   Idealized: 32 registers x 64 bits = 2048 flip-flops.
//   2 read ports (read any 2 registers simultaneously).
//   1 write port (write any 1 register per cycle).
//   Address decoder selects which register.
//   Read is combinational (no clock needed).
//   Write is sequential (on clock edge with WE).
//
// Counter: register + incrementer.
//   Counts clock cycles. Program counter is a counter.
//   Can load (jump), increment (next instruction), or hold.
//
// Shift register: chain of flip-flops, each feeding the next.
//   Data shifts one position per clock. Serial-to-parallel
//   and parallel-to-serial conversion.
//
// Derives from: theory.computing.gates, theory.self-reference
  """
}
