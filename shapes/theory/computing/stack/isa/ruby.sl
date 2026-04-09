shape theory.computing.stack.isa.ruby : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// Ruby (CRuby/YARV) as composable substrate.
//
//   addr_bits: unbounded (symbol table + object IDs)
//   data_bits: unbounded (arbitrary precision Bignum, 64-bit Float)
//   endian: n/a (object references, not byte layout)
//   clock_hz: ~50000000 (50M insns/sec on YARV, host-dependent)
//   regs: {self: object, block: proc, binding: scope_snapshot}
//   vectors: none (delegates to C extensions for numerical work)
//
// Ruby's computational model is message passing. Every operation is
// a method call on an object. 2 + 3 sends the message :+ to the
// object 2 with argument 3. There are no operators, only methods.
// This is Smalltalk's insight carried through: the address space is
// the set of all objects, and computation is messages between them.
//
// The address space has two layers: the symbol table (names to IDs,
// global and immutable once created) and the object space (IDs to
// heap objects). Instance variables live on objects. Local variables
// live on stack frames. Constants walk the nesting chain upward.
//
// Execution model: source -> AST -> YARV bytecode -> VM. YARV is a
// stack-based VM with inline caches for method dispatch. Ruby 3.1+
// adds YJIT (lazy basic block versioning JIT) for hot paths.
//
// Blocks, procs, and lambdas are closures with different control
// flow semantics. A block carries its binding (the scope snapshot
// at creation). yield transfers control to the block. This is
// structural: the block is a shape that carries its context.
//
// Garbage collection: generational mark-and-sweep with incremental
// and compacting phases (Ruby 2.7+). No reference counting.
//
// In the composition stack:
//   compose(physics, arm64, cruby, ruby-program)
//   compose(physics, x86-64, cruby, rails, ruby-program)
//     Rails is a substrate layer: it provides routing, ORM, and
//     view rendering as structural conventions on top of Ruby.
//
// Open classes mean any object's behavior can be modified at runtime.
// This is maximal flexibility at the cost of predictability.
// Mixins (modules included into classes) provide composition without
// multiple inheritance. The method resolution order is linear.
//
// Derives from: theory.computing.stack.substrate
  """
}
