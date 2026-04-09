shape theory.computing.stack.isa.swift : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// Swift as composable substrate.
//
//   addr_bits: 64 (managed references via ARC, unsafe pointers available)
//   data_bits: 8/16/32/64 (Int8..Int64, Float, Double, Float16 on ARM)
//   endian: target-dependent (ARM64 little, compiles to native)
//   clock_hz: ~2500000000 (LLVM-compiled, near C performance)
//   regs: target registers (LLVM backend, same as Rust/C)
//   vectors: SIMD via Accelerate framework and LLVM auto-vectorization
//
// Swift's memory model is ARC: Automatic Reference Counting. Not a
// garbage collector. Every strong reference increments a counter;
// when it hits zero, the object is deallocated immediately. This is
// deterministic destruction: you know when dealloc happens. Weak and
// unowned references break cycles. The programmer manages ownership
// topology, not individual allocations.
//
// ARC vs GC is a structural difference: GC substrates (Java, Go,
// Python) batch collection, trading latency spikes for simplicity.
// ARC distributes the cost across every retain/release, trading
// constant overhead for predictable latency. For real-time contexts
// (games, audio, UI), ARC's shape is preferable.
//
// Value semantics are central: structs, enums, and tuples are value
// types (copied on assignment). Classes are reference types. Swift
// encourages value types for most data, reserving classes for shared
// mutable state. Copy-on-write optimizes large value types (Array,
// String, Dictionary) to avoid unnecessary copying.
//
// Protocol-oriented programming: protocols define capability, not
// hierarchy. Protocol extensions provide default implementations.
// This is composition over inheritance, enforced by convention and
// enabled by the type system. Generics with protocol constraints
// enable compile-time polymorphism.
//
// Optionals (T?) encode nil as a type-level concept. No null pointer
// exceptions. Pattern matching with if let, guard let, and switch
// forces explicit handling of absence. This is Law 1 at the type
// level: references must be valid or explicitly marked as possibly
// absent.
//
// Execution model: source -> SIL (Swift Intermediate Language) ->
// LLVM IR -> native. SIL enables Swift-specific optimizations
// (ARC optimization, devirtualization, generic specialization)
// before handing off to LLVM for target-specific codegen.
//
// In the composition stack:
//   compose(physics, arm64, swift-runtime, swift-program)
//   compose(physics, arm64, swift-runtime, swiftui, app)
//     SwiftUI is a declarative substrate: views are value types
//     that describe UI structure. The framework diffs and renders.
//     This is structural: the view IS the specification.
//
// Derives from: theory.computing.stack.substrate
  """
}
