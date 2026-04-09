shape theory.computing.stack.isa.go-lang : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// Go as composable substrate.
//
//   addr_bits: 64 (pointers, but no arithmetic; GC-managed)
//   data_bits: 8/16/32/64 (int8..int64, float32, float64, complex128)
//   endian: target-dependent (compiles to native, usually little)
//   clock_hz: ~2000000000 (compiled, ~1.5-3x slower than C typically)
//   regs: target registers (Go compiler allocates to hardware)
//   vectors: none exposed (compiler auto-vectorizes some loops)
//
// Go's defining structural property is goroutines: lightweight
// threads multiplexed onto OS threads by the Go runtime scheduler.
// A goroutine starts at ~2KB stack (grows dynamically) versus ~1MB
// for an OS thread. Millions of goroutines are practical. This is
// CSP (Communicating Sequential Processes): concurrency through
// message passing on channels, not shared memory with locks.
//
// Channels are typed conduits: ch <- value sends, value := <-ch
// receives. select multiplexes across channels. The concurrency
// model is structural: goroutines are independent shapes,
// channels are the contact surfaces between them.
//
// The address space is GC-managed heap plus stack. Escape analysis
// determines whether a value lives on stack or heap. The programmer
// doesn't choose. Pointers exist but pointer arithmetic doesn't.
// Slices, maps, and channels are reference types backed by runtime
// structures.
//
// Interfaces are implicit: any type that implements the methods
// satisfies the interface. No "implements" declaration. This is
// structural typing, not nominal. The empty interface (any) accepts
// all types, with type assertions to recover the concrete type.
//
// Execution model: source -> Go compiler -> native binary with
// embedded runtime. The runtime includes the goroutine scheduler,
// GC, channel implementation, and netpoller. No VM, no interpreter,
// but not bare metal either: the runtime is always present.
//
// Garbage collection: concurrent, tri-color mark-and-sweep.
// Sub-millisecond pause times. No generational collection.
// The GC is optimized for latency, not throughput.
//
// In the composition stack:
//   compose(physics, arm64, go-runtime, go-program)
//   compose(physics, arm64, go-runtime, shape-engine, shape-os)
//     The shape engine is written in Go. Go is the substrate
//     that the shape engine runs on. The Go runtime provides
//     GC, goroutines, and the OS abstraction. The shape engine
//     provides structural composition on top.
//
// Compilation is fast by design (~seconds for large programs).
// The language is deliberately minimal: no generics until 1.18,
// no exceptions (error values instead), no inheritance (composition
// via embedding). Simplicity as structural constraint.
//
// Derives from: theory.computing.stack.substrate
  """
}
