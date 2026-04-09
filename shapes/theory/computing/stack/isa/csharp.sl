shape theory.computing.stack.isa.csharp : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// CLR (.NET Common Language Runtime) as composable substrate.
//
//   addr_bits: 64 (managed references, pinned pointers for interop)
//   data_bits: 8/16/32/64/128 (includes decimal for exact arithmetic)
//   endian: little (host-dependent, but x86/ARM64 targets are little)
//   clock_hz: ~1000000000 (RyuJIT compilation approaches native)
//   regs: stack machine (evaluation stack + locals, similar to JVM)
//   vectors: Vector128/256/512 (hardware intrinsics, System.Numerics)
//
// The CLR is structurally similar to the JVM but with key differences
// that affect its shape as a substrate. Value types (structs) live on
// the stack or inline in objects, not heap-allocated. This gives the
// programmer control over memory layout without abandoning GC for
// reference types. The distinction between value and reference is
// a first-class part of the type system.
//
// The address space is the managed heap plus the stack. References
// are tracked by the GC; value types are copied. Span<T> and
// ref structs provide safe views into contiguous memory without
// allocation. This is zero-copy composition at the type level.
//
// CIL (Common Intermediate Language) is the bytecode. Like JVM
// bytecode but richer: supports value types, delegates, generics
// without erasure (reified generics), and unsafe blocks for raw
// pointer access when needed.
//
// Execution model: source -> Roslyn compiler -> CIL -> CLR.
// RyuJIT compiles CIL to native at runtime. Ahead-of-time
// compilation (NativeAOT) produces standalone binaries with no
// runtime dependency. Tiered compilation starts fast, optimizes hot
// paths later.
//
// async/await is native to the runtime: the compiler transforms
// async methods into state machines. Task and ValueTask represent
// asynchronous operations. The runtime schedules continuations on
// the thread pool. No colored function problem at the runtime level.
//
// Garbage collection: generational (gen0/1/2), concurrent,
// compacting. Server GC for throughput, Workstation GC for latency.
// Pinning prevents GC from moving objects during native interop.
//
// In the composition stack:
//   compose(physics, arm64, clr, csharp-program)
//   compose(physics, x86-64, clr, fsharp-program)
//   compose(physics, arm64, clr, unity, game-script)
//     The CLR is multi-language: C#, F#, VB.NET, IronPython all
//     compile to CIL. Unity uses Mono/IL2CPP as substrate variants.
//
// LINQ is structural query: the same syntax queries objects, XML,
// databases, and any IEnumerable. Expression trees reify code as
// data, enabling cross-substrate translation (LINQ-to-SQL compiles
// C# expressions to SQL queries).
//
// Derives from: theory.computing.stack.substrate
  """
}
