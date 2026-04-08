shape theory.computing.os : theory.computing.boot, theory.computing.peripheral, theory.computing.network {
  type: system
  layer: 0
  """
// The Operating System as Coherence Manager.
//
// The OS is the shape that manages all other shapes running
// on the hardware. It is the structure S of the computer as
// a multi-process system: it governs how processes transform,
// how they contact each other, and how resources are allocated.
//
// The OS implements the Laws of Coherence at the software level:
//   Law 0: processes that crash are killed (incoherence dissolves).
//   Law 1: every resource reference must be valid (file descriptors,
//     memory pointers, handles). Dangling references = segfault.
//   Law 2: memory and CPU time are conserved. Allocation and
//     deallocation must balance. Leaks accumulate until OOM.
//   Law 3: resource contention must resolve. Deadlock is the
//     failure mode: two processes each holding what the other needs.
//     The OS must prevent or detect and resolve deadlocks.
//
// Core OS responsibilities:
//
// PROCESS MANAGEMENT:
//   Process: an executing program. Has its own virtual address
//     space (context), register state, open files, permissions.
//   Process states: created -> ready -> running -> blocked -> terminated.
//   Scheduler: decides which ready process runs next.
//     Policy: priority + time slicing. Each process gets a quantum
//     (time slice, ~1-10ms). Preemption: running process loses CPU
//     when quantum expires or higher priority process arrives.
//   Context switch: save current process state (registers, PC, page
//     table base), load next process state. ~1-5 microseconds.
//   Threads: lightweight processes sharing the same address space.
//     Cheaper context switch (no page table change).
//
// MEMORY MANAGEMENT:
//   Virtual memory: each process sees a flat 64-bit address space.
//   Pages: 4KB units. Page table maps virtual -> physical.
//   Allocation: process requests memory, OS finds free physical
//     frames and maps them. Deallocation: unmap and free frames.
//   Demand paging: pages loaded from storage only when accessed.
//     Page fault -> OS loads page from storage -> resume.
//   Swap: when physical memory is full, evict least-recently-used
//     pages to storage. Load them back on demand.
//   Protection: each process can only access its own pages.
//     Hardware enforced via page table permissions.
//
// FILESYSTEM:
//   Hierarchical namespace: /path/to/file.
//   Files: named byte sequences with metadata (inode).
//   Directories: maps names to inodes.
//   Permissions: read/write/execute per user/group/other.
//   The filesystem is the persistent shape store: shapes (files)
//   with identity (inode), structure (permissions, type), and
//   character (contents).
//
// DEVICE DRIVERS:
//   Each hardware device has a driver: software that translates
//   between the OS's abstract interface and the device's specific
//   protocol. The driver is the contact shape between OS and device.
//   Standard interface: open, close, read, write, ioctl.
//   The OS doesn't know device specifics; it talks to the driver.
//   The driver doesn't know OS internals; it talks to the device.
//   This is structural isolation through a defined interface.
//
// INTER-PROCESS COMMUNICATION (IPC):
//   Processes need to communicate. The OS provides:
//   Pipes: unidirectional byte stream between processes.
//   Shared memory: multiple processes map the same physical frames.
//   Message queues: structured messages between processes.
//   Signals: asynchronous notifications (like hardware interrupts
//     but for processes). SIGTERM, SIGKILL, SIGINT, etc.
//   Sockets: bidirectional byte stream (local or network).
//   IPC is mutual contact between process shapes, mediated by OS.
//
// Derives from: theory.computing.boot, theory.computing.peripheral,
//               theory.computing.network
  """
}
