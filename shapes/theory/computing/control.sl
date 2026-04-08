shape theory.computing.control : theory.computing.arithmetic, theory.computing.memory {
  type: structure
  layer: 0
  """
// Layer 7: Control Unit and Instruction Set.
//
// The instruction set architecture (ISA) is the structure S
// of the computer as a programmable shape. It defines what
// transformations the machine can perform.
//
// Idealized ISA: 64-bit RISC (Reduced Instruction Set Computer).
//   Fixed 32-bit instruction encoding. Regular format.
//   32 general-purpose 64-bit registers (x0-x31, x0 = hardwired 0).
//   Load/store architecture: only load/store touch memory.
//
// Instruction formats (3 types, orthogonal):
//
//   R-type (register-register):
//     [opcode:7][rd:5][funct3:3][rs1:5][rs2:5][funct7:7]
//     ALU operations: ADD, SUB, AND, OR, XOR, SLT, shifts.
//     rd = rs1 OP rs2.
//
//   I-type (immediate):
//     [opcode:7][rd:5][funct3:3][rs1:5][imm:12]
//     Loads, arithmetic with constant: ADDI, ANDI, LW, JALR.
//     rd = rs1 OP imm.
//
//   S-type (store):
//     [opcode:7][imm:5][funct3:3][rs1:5][rs2:5][imm:7]
//     Stores: SW, SB, SH, SD.
//     mem[rs1 + imm] = rs2.
//
//   B-type (branch):
//     [opcode:7][imm:1][imm:4][funct3:3][rs1:5][rs2:5][imm:6][imm:1]
//     Conditional branches: BEQ, BNE, BLT, BGE.
//     if (rs1 OP rs2) PC = PC + imm.
//
//   U-type (upper immediate):
//     [opcode:7][rd:5][imm:20]
//     LUI, AUIPC. Load 20-bit upper immediate.
//
//   J-type (jump):
//     [opcode:7][rd:5][imm:20]
//     JAL. rd = PC+4; PC = PC + imm.
//
// The instruction decoder: combinational logic that reads the
//   32-bit instruction and produces control signals for every
//   component (ALU operation, register addresses, memory
//   read/write, branch condition, immediate value).
//   This is the structure that interprets structure: the ISA
//   is S, the decoder is how S governs transformation.
//
// Control signals produced:
//   RegWrite: write to register file.
//   ALUSrc: second ALU input from register or immediate.
//   ALUOp: which ALU operation.
//   MemRead/MemWrite: access data memory.
//   MemToReg: result from ALU or memory.
//   Branch/Jump: update PC non-sequentially.
//
// Derives from: theory.computing.arithmetic, theory.computing.memory
  """
}
