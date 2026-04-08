shape theory.computing.stack.isa.x86 : theory.computing.stack.substrate {
  type: unit
  layer: 0
  """
// x86/x86-64 as composable substrate.
//
// The x86 family, 1978-present. CISC, backward-compatible
// through 5 decades of extensions.
//
// Generations (each a superset of the previous):
//
//   8086 (1978): 16-bit, 1MB address, segment:offset.
//     Registers: AX, BX, CX, DX, SI, DI, BP, SP, CS, DS, ES, SS.
//     No protection. Real mode only.
//
//   80286 (1982): + protected mode, 16MB address.
//
//   80386 (1985): 32-bit, 4GB address, flat model.
//     Registers: EAX-ESP (32-bit), paging (virtual memory).
//     Assembly shim: shim/shape_x86_i386.s
//
//   80486 (1989): + on-chip FPU, + on-chip cache (8KB).
//
//   Pentium (1993): superscalar (2 pipelines), 64-bit data bus.
//     + MMX (64-bit SIMD on FP registers, integer only).
//
//   Pentium III (1999): + SSE (128-bit XMM0-7, single-precision float).
//
//   Pentium 4 (2001): + SSE2 (double-precision float, 128-bit integer).
//     Assembly shim: shim/shape_x86_sse2.s
//
//   AMD64 / x86-64 (2003): 64-bit, 256TB virtual address.
//     Registers: RAX-R15 (16 x 64-bit), XMM0-15.
//     Assembly shim: shim/shape_x86_64.s
//
//   Core 2 (2006): + SSSE3, + SSE4.
//
//   Sandy Bridge (2011): + AVX (256-bit YMM, VEX encoding).
//
//   Haswell (2013): + AVX2 (256-bit integer SIMD), + FMA, + BMI.
//     Assembly shim: shim/shape_x86_avx2.s
//
//   Skylake-X (2017): + AVX-512 (512-bit ZMM0-31, opmask k0-k7).
//     Assembly shim: shim/shape_x86_avx512.s
//
//   Alder Lake (2021): + hybrid big.LITTLE (P-cores + E-cores).
//
//   Sapphire Rapids (2023): + AMX (matrix extensions).
//
// The x86 ISA is the accumulation of 45 years of extensions.
// Each generation adds without removing. This is why x86 is
// complex: it carries its entire history in the instruction set.
// A modern x86 chip can execute 8086 code unchanged.
//
// From a shape perspective: x86 is a maximally deep emergence
// stack within a single ISA. Each extension is an emergence
// layer. The base (8086) is always there. Everything else
// emerges from it without replacing it.
//
// Derives from: theory.computing.stack.substrate
  """
}
