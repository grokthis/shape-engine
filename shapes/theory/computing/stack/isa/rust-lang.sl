shape theory.computing.stack.isa.rust-lang : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// Rust as composable substrate.
//
//   addr_bits: 64 (raw pointers, references, smart pointers)
//   data_bits: 8/16/32/64/128 (i8..i128, f32, f64, bool, char)
//   endian: target-dependent (compiles to native, usually little)
//   clock_hz: ~3000000000 (compiles to native, comparable to C)
//   regs: target registers (LLVM backend allocates to hardware)
//   vectors: SIMD via std::arch intrinsics, portable SIMD (nightly)
//
// Rust's defining structural property is ownership. Every value has
// exactly one owner. When the owner goes out of scope, the value is
// dropped. No GC, no reference counting (unless explicitly opted in
// with Rc/Arc). Memory safety is enforced at compile time through
// the borrow checker: you can have one mutable reference OR any
// number of immutable references, never both.
//
// This is Law 1 (stable reference) enforced by the compiler. Every
// reference must be valid for its lifetime. Dangling references are
// a compile error, not a runtime crash. The borrow checker is a
// static coherence verifier for memory.
//
// The address space is flat memory (stack + heap) with typed access.
// No null pointers: Option<T> encodes presence/absence. No
// exceptions: Result<T, E> encodes success/failure. Algebraic data
// types (enums with data) and pattern matching enforce exhaustive
// handling. The type system makes illegal states unrepresentable.
//
// Execution model: source -> MIR (Mid-level IR) -> LLVM IR -> native.
// No runtime, no VM, no interpreter. The binary is bare metal with
// a thin platform abstraction (std). no_std strips even that,
// targeting embedded and kernel contexts directly.
//
// Zero-cost abstractions: iterators, closures, generics, and trait
// dispatch compile to the same code you would write by hand. The
// abstraction is erased at compile time. Monomorphization turns
// generic code into specialized concrete implementations.
//
// Traits are the composition mechanism: they define shared behavior
// without inheritance. impl Trait for Type adds capability to any
// type. This is structural, not hierarchical.
//
// In the composition stack:
//   compose(physics, arm64, rust-program)
//   compose(physics, riscv, rust-firmware)
//   compose(physics, wasm, rust-wasm-module)
//     Rust compiles to WASM as a first-class target. The shape
//     engine could be written in Rust and compiled to WASM,
//     with the borrow checker guaranteeing memory coherence
//     that WASM's linear memory model does not enforce.
//
// Derives from: theory.computing.stack.substrate
  """
}
