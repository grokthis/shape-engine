shape theory.computing.pipeline : theory.computing.control, theory.computing.arithmetic, theory.computing.memory {
  type: structure
  layer: 0
  """
// Layer 6: The 5-Stage Pipeline.
//
// The pipeline is the moment sequence of instruction execution.
// Each stage is one clock cycle. Multiple instructions in flight
// simultaneously, each at a different stage.
//
// Stage 1: FETCH (IF)
//   PC -> instruction memory -> instruction register.
//   PC = PC + 4 (next instruction) or branch target.
//   Components: PC register, instruction SRAM, adder (+4),
//     branch target MUX.
//
// Stage 2: DECODE (ID)
//   Instruction -> register file reads + immediate generation.
//   Read rs1 and rs2 from register file (2 read ports).
//   Sign-extend immediate field.
//   Generate control signals (decoder).
//   Components: register file, immediate generator, control unit.
//
// Stage 3: EXECUTE (EX)
//   ALU operates on decoded operands.
//   For R-type: ALU(rs1_val, rs2_val).
//   For I-type: ALU(rs1_val, immediate).
//   For load/store: ALU computes effective address (rs1 + offset).
//   For branch: compare rs1, rs2 and compute target.
//   Components: ALU, branch comparator, forwarding MUX.
//
// Stage 4: MEMORY (MEM)
//   Data memory access (loads and stores only).
//   Load: read data memory at ALU result address.
//   Store: write rs2_val to data memory at ALU result address.
//   Other instructions: pass through (no memory access).
//   Components: data cache (L1D), store buffer.
//
// Stage 5: WRITEBACK (WB)
//   Write result to register file.
//   For ALU ops: write ALU result to rd.
//   For loads: write memory data to rd.
//   For stores/branches: no writeback.
//   Components: writeback MUX, register file write port.
//
// Pipeline registers (between stages):
//   IF/ID: holds fetched instruction + PC.
//   ID/EX: holds decoded operands + control + immediate + PC.
//   EX/MEM: holds ALU result + store data + control.
//   MEM/WB: holds result (from ALU or memory) + control.
//   Each is a bank of flip-flops capturing the full state of
//   that pipeline boundary on every clock edge.
//
// Throughput: 1 instruction per cycle (ideal).
// Latency: 5 cycles per instruction.
// CPI (cycles per instruction): 1.0 ideal, ~1.2-1.5 real
//   (stalls from hazards).
//
// Derives from: theory.computing.control, theory.computing.arithmetic,
//               theory.computing.memory
  """
}
