shape theory.computing.stack.syscall : theory.computing.stack.passthrough {
  type: structure
  layer: 0
  """
// Syscall Interface: How Layers Talk to the Base.
//
// Every layer in the stack can make syscalls. A syscall is a
// request from the guest (emulated layer) to the host (base
// layer) to perform an operation the guest cannot do itself.
//
// The syscall does NOT go through intermediate layers. It is
// a direct reference from the calling layer to the base.
// Intermediate layers are unaware of the syscall.
//
// Syscall mechanism:
//   1. Guest layer executes a trap instruction.
//      6502: BRK. ARM64: SVC. RISC-V: ECALL. x86: SYSCALL.
//      Shape engine: ecall opcode.
//   2. The substrate layer intercepts the trap.
//      Instead of forwarding to the next emulation layer,
//      it reads the syscall number and arguments from the
//      guest's registers.
//   3. The substrate dispatches to the base shape engine.
//      The base engine performs the operation on the real host.
//   4. The result is placed in the guest's return register.
//   5. The guest resumes execution.
//
// Syscall ABI (per ISA):
//   6502:     A = syscall number, X/Y = args. BRK to invoke.
//   ARM64:    x8 = number, x0-x5 = args. SVC #0 to invoke.
//   RISC-V:   a7 = number, a0-a5 = args. ECALL to invoke.
//   x86-64:   rax = number, rdi/rsi/rdx/r10/r8/r9 = args. SYSCALL.
//   Shape:    first arg = number, rest = args. ecall opcode.
//
// The syscall numbers are unified across all ISAs at the
// passthrough level. The per-ISA ABI maps native register
// conventions to the unified numbering.
//
// Syscall table:
//   0: exit(code)              Terminate the stack.
//   1: write(fd, buf, len)     Write to file descriptor.
//   2: read(fd, buf, len)      Read from file descriptor.
//   3: open(path, flags)       Open a file/shape.
//   4: close(fd)               Close a file descriptor.
//   5: stat(path, buf)         Get shape/file metadata.
//   6: mmap(addr, len, ...)    Map memory region.
//   7: brk(addr)               Adjust heap.
//   8: ioctl(fd, cmd, arg)     Device control.
//   9: clock_gettime(id, buf)  Read clock (tick counter).
//  10: shape_get(id)           Read a shape by ID. (Shape-specific)
//  11: shape_edit(id, content) Edit a shape. (Shape-specific)
//  12: shape_add(id, content)  Create a shape. (Shape-specific)
//  13: shape_deps(id)          Get dependencies. (Shape-specific)
//  14: shape_children(prefix)  List children. (Shape-specific)
//
// Syscalls 0-9 map to POSIX. Any program expecting POSIX
// syscalls works unchanged. Syscalls 10-14 are shape-specific:
// they give direct access to the base shape graph.
//
// The shape-specific syscalls are the key: a program running
// at any depth in the stack can directly read and edit shapes
// in the base engine. The emulation layers handle computation;
// the shape graph is shared.
//
// Derives from: theory.computing.stack.passthrough
  """
}
