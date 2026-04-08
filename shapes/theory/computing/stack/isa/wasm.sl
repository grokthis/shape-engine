shape theory.computing.stack.isa.wasm : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// WebAssembly as composable substrate.
//
//   addr_bits: 32 (wasm32) or 64 (wasm64, memory64 proposal)
//   data_bits: 32/64 (i32, i64, f32, f64)
//   endian: little
//   clock_hz: host-dependent (V8 ~1-3 GHz effective)
//   regs: stack machine (no named registers, operand stack)
//   vectors: v128 (fixed 128-bit SIMD, 2x i64 or 4x i32)
//
// WASM is the universal substrate: runs in every browser,
// every cloud edge, every WASI runtime. Same bytecode everywhere.
//
// For the shape engine: the JS shape-engine.js already exists
// as a native JS projection. The WASM shim (shape_wasm.wat)
// provides the low-level arithmetic and wave propagation.
// The two can coexist: JS for the graph, WASM for the hot path.
//
// In the composition stack:
//   compose(physics, arm64, browser, wasm, shape-engine, shape-os)
//     Shape OS running on the shape engine compiled to WASM
//     running in a browser on ARM64 hardware.
//
// The benchmark page embeds this stack. The live shell IS
// a shape engine running in WASM in the page that describes
// the shape engine. Self-reference at the presentation level.
//
// Assembly shim: shim/shape_wasm.wat
//
// Derives from: theory.computing.stack.substrate
  """
}
