shape theory.computing.system : theory.computing.pipeline, theory.computing.cache, theory.computing.memory.dram {
  type: system
  layer: 0
  """
// Layer 9: System Architecture.
//
// The CPU core (pipeline + cache + control) connects to the
// rest of the system through buses and controllers.
//
// Memory controller:
//   Translates cache misses into DRAM commands.
//   Manages banks, rows, columns, refresh, timing.
//   Reorders requests to maximize row hits.
//   Typically on-die (integrated memory controller).
//
// Virtual memory (MMU - Memory Management Unit):
//   Translates virtual addresses to physical addresses.
//   Page table: maps 4KB virtual pages to physical frames.
//   TLB (Translation Lookaside Buffer): cache of page table
//     entries. 64-entry L1 TLB, ~1024-entry L2 TLB.
//   TLB miss -> page table walk (hardware or software).
//   Page fault -> OS loads page from disk/swap.
//   Protection: each page has read/write/execute permissions.
//   Virtual memory is the hardware implementation of context
//     (Definition 5.4): each process has its own address space
//     (its own context), isolated from other processes.
//
// Interrupt controller:
//   External events (I/O completion, timer, error) signal
//   the CPU asynchronously. The interrupt controller prioritizes
//   and delivers interrupts.
//   On interrupt: save current state (PC, registers) to stack,
//     jump to interrupt handler, handle, restore state, return.
//   This is forcing (Definition 11.1) in hardware: an external
//     shape forces the CPU to resolve a new contact.
//
// Bus interconnect:
//   Connects CPU, memory, I/O devices.
//   System bus: 64-bit data, 48-bit address, control signals.
//   Arbitration: when multiple masters request the bus, the
//     arbiter grants access (round-robin or priority).
//
// DMA (Direct Memory Access):
//   I/O devices transfer data directly to/from memory without
//   CPU involvement. CPU sets up transfer (source, dest, size),
//   DMA controller executes, interrupts CPU on completion.
//
// Derives from: theory.computing.pipeline, theory.computing.cache,
//               theory.computing.memory.dram
  """
}
