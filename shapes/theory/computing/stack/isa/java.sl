shape theory.computing.stack.isa.java : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// JVM (Java Virtual Machine) as composable substrate.
//
//   addr_bits: 32 (compressed oops) or 64 (object references)
//   data_bits: 8/16/32/64 (byte, short, int, long, float, double)
//   endian: big (JVM spec mandates big-endian bytecode encoding)
//   clock_hz: ~1000000000 (JIT-compiled code approaches native)
//   regs: stack machine (operand stack + local variable array per frame)
//   vectors: platform-dependent (auto-vectorization via C2/Graal JIT)
//
// The JVM is a typed stack machine. Each method invocation creates
// a frame with an operand stack and a local variable array. Bytecode
// opcodes (200+) manipulate the stack: iload pushes an int, iadd
// pops two and pushes their sum, invokevirtual dispatches a method.
//
// The address space is the heap: a flat graph of objects, each with
// a class pointer and field data. References are pointers into this
// heap, managed entirely by the GC. No pointer arithmetic, no manual
// free. The type system is the address discipline: every reference
// is typed, every field offset is known at class load time.
//
// Strong static typing with class-based OOP. Every value is either
// a primitive (8 types, stack-allocated) or a reference to a heap
// object. Generics are erased at compile time (type erasure), so
// the VM sees only Object references with casts. This is a layer
// violation papered over by the compiler.
//
// Execution model: source -> javac -> .class bytecode -> JVM.
// The JVM interprets bytecode, profiles execution, then JIT-compiles
// hot methods to native code (C1 for quick compilation, C2/Graal
// for optimized). Deoptimization falls back to interpreter when
// speculative optimizations fail.
//
// Garbage collection: generational (young/old), with multiple
// collector options (G1, ZGC, Shenandoah). Concurrent collection
// minimizes pause times. The GC is the most engineered component.
//
// In the composition stack:
//   compose(physics, arm64, jvm, java-program)
//   compose(physics, x86-64, jvm, kotlin-program)
//   compose(physics, arm64, jvm, clojure-program)
//     The JVM is a multi-language substrate. Kotlin, Scala, Clojure,
//     Groovy all compile to JVM bytecode. The VM doesn't know or
//     care which language produced the bytecode.
//
// "Write once, run anywhere" is substrate independence: the same
// bytecode runs on any JVM, regardless of hardware. The JVM is
// the abstraction boundary between language and machine.
//
// Derives from: theory.computing.stack.substrate
  """
}
