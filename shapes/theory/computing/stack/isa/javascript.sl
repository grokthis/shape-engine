shape theory.computing.stack.isa.javascript : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// JavaScript (V8/SpiderMonkey/JSC) as composable substrate.
//
//   addr_bits: unbounded (property chains on prototype tree)
//   data_bits: 64 (IEEE 754 double), plus BigInt (unbounded)
//   endian: n/a (object graph, not byte layout; TypedArrays are host-endian)
//   clock_hz: ~1000000000 (JIT-compiled hot paths approach native speed)
//   regs: {scope_chain: list, this: object, arguments: object}
//   vectors: none native (WASM SIMD available as substrate below)
//
// JavaScript's address space is the prototype chain. Property lookup
// walks from object to __proto__ to __proto__ until null. This is
// not inheritance in the class sense: it is structural delegation.
// Every object is a dictionary with a hidden class (V8) or shape
// (SpiderMonkey) that optimizes repeated access patterns.
//
// The execution model has two phases: parsing/compilation and the
// event loop. V8 compiles to bytecode (Ignition), profiles, then
// JIT-compiles hot functions to native (TurboFan). Deoptimization
// falls back to bytecode when assumptions break.
//
// Single-threaded with cooperative concurrency: the event loop
// processes one callback at a time. Promises and async/await are
// syntactic structure over microtask queues. No preemption, no
// data races, no locks. Concurrency is sequential at the task level.
//
// Garbage collection: generational mark-and-sweep (V8: Scavenge
// for young generation, Mark-Compact for old). No reference counting.
// WeakRef and FinalizationRegistry for weak references.
//
// In the composition stack:
//   compose(physics, arm64, browser, v8, javascript-program)
//   compose(physics, x86-64, node, v8, javascript-program)
//   compose(physics, arm64, browser, v8, wasm, shape-engine)
//     The shape engine running as WASM inside V8 inside a browser.
//     JavaScript is the glue layer between DOM and computation.
//
// closures capture their enclosing scope by reference, not by value.
// This makes closures structural: they carry their context with them.
// The module system (ESM) is static: imports are live bindings,
// not copies. The dependency graph is resolved at parse time.
//
// Derives from: theory.computing.stack.substrate
  """
}
