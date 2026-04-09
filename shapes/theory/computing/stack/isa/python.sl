shape theory.computing.stack.isa.python : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// Python 3 as composable substrate.
//
//   addr_bits: unbounded (names in namespace dicts, not integers)
//   data_bits: unbounded (arbitrary precision int, 64-bit float)
//   endian: n/a (object references, not byte layout)
//   clock_hz: ~30000000 (30M bytecodes/sec on CPython, host-dependent)
//   regs: {locals: dict, globals: dict, builtins: dict, stack: list}
//   vectors: none (no SIMD; numpy delegates to C substrate below)
//
// Python's address space is a chain of dictionaries: locals, then
// enclosing scopes, then globals, then builtins. Every name lookup
// is a hash table probe. The "registers" are stack frames on a
// bytecode VM (CPython), each frame holding its own local namespace.
//
// Data is dynamically typed: every value is a heap-allocated object
// with a type pointer and reference count. Integers are arbitrary
// precision. Strings are immutable Unicode sequences. Lists and
// dicts are the universal containers. The GIL serializes all
// bytecode execution to a single thread.
//
// Execution model: source -> AST -> bytecode -> CPython VM loop.
// The eval loop is a giant switch on opcodes (LOAD_FAST, CALL,
// BINARY_OP, etc). Each opcode manipulates the operand stack.
// Function calls push new frames. Exceptions unwind them.
//
// Garbage collection: reference counting (immediate) plus cyclic
// GC (generational mark-and-sweep for reference cycles).
//
// In the composition stack:
//   compose(physics, arm64, cpython, python-program)
//   compose(physics, x86-64, cpython, numpy, python-program)
//     NumPy is a substrate boundary: Python dispatches to C/Fortran
//     which dispatches to SIMD on the hardware. Three layers crossed
//     in a single function call.
//
// The stdlib is a built-in namespace of ~300 modules. import is
// the composition operator: it brings another shape into scope.
// Everything is an object. Classes are objects. Functions are objects.
// Modules are objects. The uniformity makes Python a natural shape
// language, but the interpreter overhead places it high in the stack.
//
// Derives from: theory.computing.stack.substrate
  """
}
