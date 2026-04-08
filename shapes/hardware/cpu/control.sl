// Control unit: instruction decode and execute.
//
// The CPU cycle IS a shape evaluation:
//   1. Fetch: read instruction at mem[pc]
//   2. Decode: parse instruction into opcode + operands
//   3. Execute: dispatch to ALU/memory/branch
//   4. Writeback: store result
//   5. Advance: pc++  (or pc = target for branch)
//
// The control unit IS the evaluator. Each instruction IS a shape.
// The program IS a sequence of shapes. Execution IS wave propagation
// through the instruction sequence.

shape hardware.cpu.control : hardware.cpu {
  type: unit
  layer: 2
  deps: [hardware.cpu.alu, hardware.cpu.registers, hardware.cpu.memory]
  """
// Instruction set (RISC, register-register):
//
//   Arithmetic:
//     add  rd, rs1, rs2    rd = rs1 + rs2
//     sub  rd, rs1, rs2    rd = rs1 - rs2
//     mul  rd, rs1, rs2    rd = rs1 * rs2
//     div  rd, rs1, rs2    rd = rs1 / rs2
//     mod  rd, rs1, rs2    rd = rs1 % rs2
//
//   Immediate:
//     addi rd, rs1, imm    rd = rs1 + imm
//     li   rd, imm         rd = imm
//
//   Bitwise:
//     and  rd, rs1, rs2    rd = rs1 & rs2
//     or   rd, rs1, rs2    rd = rs1 | rs2
//     xor  rd, rs1, rs2    rd = rs1 ^ rs2
//     shl  rd, rs1, rs2    rd = rs1 << rs2
//     shr  rd, rs1, rs2    rd = rs1 >> rs2
//
//   Memory:
//     lw   rd, addr        rd = mem[addr]
//     sw   rs, addr        mem[addr] = rs
//     push rs              sp--, mem[sp] = rs
//     pop  rd              rd = mem[sp], sp++
//
//   Branch:
//     beq  rs1, rs2, off   if rs1 == rs2: pc += off
//     bne  rs1, rs2, off   if rs1 != rs2: pc += off
//     blt  rs1, rs2, off   if rs1 < rs2: pc += off
//     bge  rs1, rs2, off   if rs1 >= rs2: pc += off
//     jmp  addr            pc = addr
//     jal  rd, addr        rd = pc+1, pc = addr  (call)
//     ret                  pc = r15 (return)
//
//   System:
//     halt                 stop execution
//     nop                  no operation
//     ecall                system call (print, input, etc.)
"""
}

shape hardware.cpu.control.cycle : hardware.cpu.control {
  type: exec
  layer: 2
  """
// Execute one CPU cycle.
// Reads instruction from program memory, decodes, executes.
//
// Instructions are stored as shapes: hardware.cpu.prog.N
// where N is the instruction index.
//
// Each instruction shape has dimensions:
//   op: the opcode
//   rd, rs1, rs2: register names
//   imm: immediate value
//   addr: memory/branch address

let pc_val = to_int(content("hardware.cpu.reg.pc"))
let instr_id = "hardware.cpu.prog." + to_string(pc_val)

if !exists(instr_id) {
  // No instruction: halt.
  print("HALT at pc=" + pc_val)
} else {
  let op = dim(instr_id, "op")
  let rd = dim(instr_id, "rd")
  let rs1 = dim(instr_id, "rs1")
  let rs2 = dim(instr_id, "rs2")
  let imm = to_int(dim(instr_id, "imm"))
  let addr = to_int(dim(instr_id, "addr"))

  // Read source registers.
  let v1 = to_int(content("hardware.cpu.reg." + rs1))
  let v2 = to_int(content("hardware.cpu.reg." + rs2))

  let next_pc = pc_val + 1
  let result = 0

  // Decode and execute.
  if op == "add" { set result = v1 + v2 }
  else if op == "sub" { set result = v1 - v2 }
  else if op == "mul" { set result = v1 * v2 }
  else if op == "div" { if v2 != 0 { set result = v1 / v2 } }
  else if op == "mod" { if v2 != 0 { set result = v1 % v2 } }
  else if op == "addi" { set result = v1 + imm }
  else if op == "li" { set result = imm }
  else if op == "and" { set result = bit_and(v1, v2) }
  else if op == "or" { set result = bit_or(v1, v2) }
  else if op == "xor" { set result = bit_xor(v1, v2) }
  else if op == "shl" { set result = bit_shl(v1, v2) }
  else if op == "shr" { set result = bit_shr(v1, v2) }
  else if op == "beq" { if v1 == v2 { set next_pc = pc_val + imm } }
  else if op == "bne" { if v1 != v2 { set next_pc = pc_val + imm } }
  else if op == "blt" { if v1 < v2 { set next_pc = pc_val + imm } }
  else if op == "bge" { if v1 >= v2 { set next_pc = pc_val + imm } }
  else if op == "jmp" { set next_pc = addr }
  else if op == "halt" { set next_pc = pc_val }
  else if op == "nop" { }
  else if op == "ecall" {
    // System call: v1 = call number, v2 = argument.
    if v1 == 1 { print(v2) }
  }

  // Writeback.
  if rd != "" {
    if op != "beq" {
      if op != "bne" {
        if op != "blt" {
          if op != "bge" {
            if op != "jmp" {
              if op != "halt" {
                if op != "nop" {
                  if op != "ecall" {
                    set_content("hardware.cpu.reg." + rd, to_string(result))
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Advance PC.
  set_content("hardware.cpu.reg.pc", to_string(next_pc))
}
"""
}

shape hardware.cpu.control.run : hardware.cpu.control {
  type: exec
  layer: 2
  """
// Run the CPU until halt.
// Executes cycles until pc doesn't advance (halt instruction).

let max_cycles = 10000
let cycles = 0
let prev_pc = 0 - 1

while cycles < max_cycles {
  let pc = to_int(content("hardware.cpu.reg.pc"))
  if pc == prev_pc {
    break
  }
  set prev_pc = pc

  // Execute one cycle (inline the cycle logic for performance).
  let instr_id = "hardware.cpu.prog." + to_string(pc)
  if !exists(instr_id) {
    break
  }

  let op = dim(instr_id, "op")
  let rd = dim(instr_id, "rd")
  let rs1 = dim(instr_id, "rs1")
  let rs2 = dim(instr_id, "rs2")
  let imm = to_int(dim(instr_id, "imm"))
  let addr = to_int(dim(instr_id, "addr"))
  let v1 = to_int(content("hardware.cpu.reg." + rs1))
  let v2 = to_int(content("hardware.cpu.reg." + rs2))
  let next_pc = pc + 1
  let result = 0

  if op == "add" { set result = v1 + v2 }
  else if op == "sub" { set result = v1 - v2 }
  else if op == "mul" { set result = v1 * v2 }
  else if op == "addi" { set result = v1 + imm }
  else if op == "li" { set result = imm }
  else if op == "beq" { if v1 == v2 { set next_pc = pc + imm } }
  else if op == "bne" { if v1 != v2 { set next_pc = pc + imm } }
  else if op == "blt" { if v1 < v2 { set next_pc = pc + imm } }
  else if op == "bge" { if v1 >= v2 { set next_pc = pc + imm } }
  else if op == "jmp" { set next_pc = addr }
  else if op == "halt" { set next_pc = pc }
  else if op == "ecall" { if v1 == 1 { print(v2) } }

  if rd != "" {
    if op != "beq" {
      if op != "bne" {
        if op != "blt" {
          if op != "bge" {
            if op != "jmp" {
              if op != "halt" {
                if op != "ecall" {
                  set_content("hardware.cpu.reg." + rd, to_string(result))
                }
              }
            }
          }
        }
      }
    }
  }

  set_content("hardware.cpu.reg.pc", to_string(next_pc))
  set cycles = cycles + 1
}
print("Executed " + cycles + " cycles")
"""
}
