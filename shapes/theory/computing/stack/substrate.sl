shape theory.computing.stack.substrate : theory.computing.stack {
  type: definition
  layer: 0
  """
// The Substrate Interface.
//
// Every layer in a computation stack implements this interface.
// It is the contact geometry between layers: the structure
// through which character crosses the boundary.
//
// Interface:
//
//   read(addr: uint, width: uint) -> value: uint
//     Read `width` bytes from address `addr`.
//     Width: 1 (byte), 2 (halfword), 4 (word), 8 (doubleword).
//     The address space is layer-specific: a 6502 has 16-bit
//     addresses (64KB), an ARM64 has 48-bit (256TB virtual).
//
//   write(addr: uint, width: uint, value: uint)
//     Write `value` to address `addr`.
//     Same width options as read.
//
//   step() -> cycles: uint
//     Execute one instruction at the current PC.
//     Returns the number of substrate cycles consumed.
//     This is the transformation law at the architecture level:
//     M' = f(C, S) where C = (registers, memory) and S = ISA.
//
//   reset()
//     Set all registers and state to power-on defaults.
//     PC loaded from the reset vector.
//     This is the hardware empty_s: structure present, character
//     cleared.
//
//   interrupt(vector: uint)
//     Deliver an interrupt. Push state, jump to handler.
//     NMI (non-maskable): always taken.
//     IRQ (maskable): taken if interrupts enabled.
//     This is forcing (Definition 11.1): an external shape
//     forces the substrate to resolve new contact.
//
//   state() -> snapshot
//     Return the complete state: all registers, flags, PC, SP.
//     Used for: debugging, checkpointing, migration.
//
//   load_state(snapshot)
//     Restore from a snapshot. The inverse of state().
//     Used for: resuming, forking, time-travel debugging.
//
// Properties:
//
//   addr_bits: uint     Address space width (16, 32, 48, 64)
//   data_bits: uint     Data path width (8, 16, 32, 64)
//   endian: enum        Byte order (little, big)
//   clock_hz: uint      Native clock frequency
//   regs: map           Register file description
//   vectors: map        Reset, NMI, IRQ vector addresses
//
// A substrate IS a shape:
//   ID: the ISA identifier
//   Structure: the instruction set (what governs transformation)
//   Character: the current state (registers, memory, PC)
//   Tick: the cycle count
//
// Derives from: theory.computing.stack
  """
}
