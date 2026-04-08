shape theory.computing.peripheral : theory.computing.system, theory.computing.io {
  type: structure
  layer: 0
  """
// Peripheral Protocol: Shape Bus.
//
// Every peripheral is a shape in mutual contact with the CPU
// through a bus. The bus protocol defines the contact geometry:
// how character crosses the boundary between CPU and device.
//
// Idealized peripheral bus: tree topology.
//   Root: CPU (bus master).
//   Branches: controllers (hubs).
//   Leaves: devices.
//
// The bus has three channels (orthogonal):
//   Address: which device/register (48-bit, CPU -> device).
//   Data: the payload (64-bit, bidirectional).
//   Control: what operation (read/write/interrupt/reset).
//
// Bus transaction (4 phases):
//   1. ARBITRATION: master claims the bus.
//      If multiple masters: priority arbitration. Highest wins.
//      This is Law 3 resolution: incompatible claims resolve.
//   2. ADDRESS: master places address on bus. All devices decode.
//      Exactly one device recognizes its address. This is the
//      decoder: N-bit address -> 1-of-2^N device select.
//   3. DATA: selected device exchanges data with master.
//      Read: device drives data bus. Write: master drives data bus.
//   4. COMPLETION: transaction acknowledged. Bus released.
//
// Device discovery (enumeration):
//   At boot, the bus controller walks the tree.
//   Each slot is probed: "is anyone here?"
//   Present devices respond with their device ID (vendor, type,
//     capabilities). The OS builds a device table.
//   This is structural identification: the system discovers
//   what shapes are in its context.
//
// Memory-mapped I/O:
//   Device registers appear as memory addresses.
//   CPU reads/writes device registers using normal load/store.
//   No special I/O instructions needed.
//   Address space partitioned: lower range = DRAM, upper = devices.
//   The device IS a set of memory locations from the CPU's
//   perspective. Uniform contact geometry.
//
// Interrupt-driven I/O:
//   Device signals completion/event via interrupt line.
//   Interrupt controller prioritizes, delivers to CPU.
//   CPU suspends current work, runs interrupt handler (ISR).
//   ISR reads device status, processes data, acknowledges.
//   CPU resumes. Asynchronous mutual contact.
//
// DMA (Direct Memory Access):
//   For bulk transfers, CPU sets up DMA descriptor:
//     source address, destination address, byte count, direction.
//   DMA controller executes transfer without CPU involvement.
//   On completion: DMA controller interrupts CPU.
//   The DMA controller is a delegated forcing shape: it does
//   the work the CPU initiated but doesn't need to supervise.
//
// Derives from: theory.computing.system, theory.computing.io
  """
}
