// Memory: addressable array of values.
//
// Each memory cell IS a shape. Address IS the shape ID suffix.
// Read is content(). Write is set_content(). The memory bus
// IS the shape graph's dependency connections.
//
// On hardware: SRAM/DRAM arrays.
// In the engine: shapes under hardware.cpu.mem.ADDR

shape hardware.cpu.memory : hardware.cpu {
  type: unit
  layer: 1
  """
// Initialize memory. Default 4096 cells (4KB at 8 bits, 32KB at 64 bits).
// Memory is sparse: only allocated cells exist as shapes.
// Reading unallocated memory returns 0.
"""
}

shape hardware.cpu.memory.read : hardware.cpu.memory {
  type: exec
  layer: 1
  """
// Read from memory address. Returns integer value.
let cell_id = "hardware.cpu.mem." + to_string(addr)
if exists(cell_id) {
  to_int(content(cell_id))
} else {
  0
}
"""
}

shape hardware.cpu.memory.write : hardware.cpu.memory {
  type: exec
  layer: 1
  """
// Write value to memory address.
let cell_id = "hardware.cpu.mem." + to_string(addr)
if exists(cell_id) {
  set_content(cell_id, to_string(value))
} else {
  add_shape(cell_id, "memcell", to_string(value), 1)
}
"""
}

shape hardware.cpu.memory.stack : hardware.cpu.memory {
  type: exec
  layer: 2
  """
// Stack operations built on memory + sp register.
//
// push(value): sp--, mem[sp] = value
// pop(): value = mem[sp], sp++
//
// The stack IS memory addressed by the stack pointer.
// Push and pop ARE read/write with sp mutation.
"""
}
