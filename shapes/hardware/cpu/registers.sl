// Register file: named storage slots.
//
// Each register IS a shape with an integer value.
// Read is a shape lookup. Write is a shape edit.
// On hardware: a bank of flip-flops addressed by index.
// In the engine: shapes under hardware.cpu.reg.N

shape hardware.cpu.registers : hardware.cpu {
  type: unit
  layer: 1
  """
// Initialize N general-purpose registers.
// r0-r15: general purpose
// pc: program counter
// sp: stack pointer
// flags: zero, negative, carry, overflow

let n_regs = 16
for i in range(n_regs) {
  add_shape("hardware.cpu.reg.r" + i, "register", "0", 1)
}
add_shape("hardware.cpu.reg.pc", "register", "0", 1)
add_shape("hardware.cpu.reg.sp", "register", "0", 1)
add_shape("hardware.cpu.reg.flags", "register", "0", 1)
"""
}

shape hardware.cpu.registers.read : hardware.cpu.registers {
  type: exec
  layer: 1
  """
// Read register by name. Returns integer value.
let reg_id = "hardware.cpu.reg." + reg_name
if exists(reg_id) {
  to_int(content(reg_id))
} else {
  0
}
"""
}

shape hardware.cpu.registers.write : hardware.cpu.registers {
  type: exec
  layer: 1
  """
// Write value to register by name.
let reg_id = "hardware.cpu.reg." + reg_name
if exists(reg_id) {
  set_content(reg_id, to_string(value))
}
"""
}
