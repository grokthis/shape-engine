shape theory.computing.stack.isa.lua : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// Lua as composable substrate.
//
//   addr_bits: unbounded (table keys: any value except nil)
//   data_bits: 64 (IEEE 754 double; Lua 5.3+ also native 64-bit int)
//   endian: n/a (values, not bytes; C API exposes host endianness)
//   clock_hz: ~100000000 (100M VM insns/sec; LuaJIT ~1 GHz)
//   regs: register-based VM (Lua 5.0+), up to 200 per function
//   vectors: none (delegates to C host for SIMD)
//
// Lua has exactly 8 types: nil, boolean, number, string, function,
// table, userdata, thread. Tables are the universal data structure:
// array, dictionary, object, module, namespace, class. Everything
// that isn't a primitive is a table or lives in a table.
//
// The address space is tables all the way down. Global variables
// are fields of _ENV (a table). Modules are tables. Metatables
// define operator behavior: __index chains create prototype
// delegation, __add defines arithmetic, __call makes tables
// callable. The metamechanism is the composition operator.
//
// Execution model: source -> bytecode -> register-based VM.
// Unlike stack VMs (Python, Ruby), Lua's VM uses numbered registers
// mapped to stack slots. This reduces push/pop overhead and enables
// better instruction encoding. LuaJIT uses a trace-based JIT
// compiler that can approach C speed on hot loops.
//
// Coroutines provide cooperative multitasking. coroutine.resume()
// and coroutine.yield() transfer control explicitly. No preemption,
// no threads, no races. Concurrency is structural alternation.
//
// Garbage collection: incremental mark-and-sweep (Lua 5.1+),
// generational mode added in 5.4. Weak tables enable caches
// that don't prevent collection.
//
// In the composition stack:
//   compose(physics, arm64, c-host, lua-vm, lua-program)
//   compose(physics, arm64, game-engine, lua-vm, game-script)
//     Lua is the canonical embedded substrate. The C API is the
//     boundary: 130 functions that move values between C stack
//     and Lua stack. The host provides capabilities; Lua composes.
//
// Minimal core by design: the full VM is ~30K lines of C.
// This is a substrate that optimizes for embedding, not for
// self-sufficiency. Its power comes from the layer below.
//
// Derives from: theory.computing.stack.substrate
  """
}
