/*
 * shape_shim.h — Unified interface across all ISA shims.
 *
 * The shape engine's assembly shims implement the same operations
 * on every architecture. This header provides the common interface.
 * Compile with the appropriate .s file for your target.
 *
 * Supported targets:
 *   ARM64       shape_arm64.s       Apple Silicon, Cortex-A, Graviton
 *   RV32I       shape_riscv32i.s    Minimal RISC-V (no multiply)
 *   RV64I       shape_riscv64i.s    64-bit RISC-V (no multiply)
 *   RV64IM      shape_riscv_m.s     RISC-V with multiply/divide
 *   RV64IMA     shape_riscv_a.s     RISC-V with atomics
 *   RV64GV      shape_riscv_v.s     RISC-V with vectors
 *   i386        shape_x86_i386.s    Intel 386 (32-bit, 1985)
 *   x86-64      shape_x86_64.s      AMD64 (64-bit, 2003)
 *   SSE2        shape_x86_sse2.s    Pentium 4 (128-bit SIMD, 2001)
 *   AVX2        shape_x86_avx2.s    Haswell (256-bit SIMD, 2013)
 *   AVX-512     shape_x86_avx512.s  Skylake-X (512-bit SIMD, 2017)
 *
 * The structural insight: every shim computes the same result.
 * The Gauss sum is 3 instructions on every ISA. The loop is O(n)
 * on every ISA. The structural shortcut erases the ISA difference.
 * What changes is the number of ticks, not the answer.
 *
 * Wave propagation throughput scales with SIMD width:
 *   Scalar:   1 dep/cycle   (ARM64, RV64, x86-64)
 *   SSE2:     2 deps/cycle  (128-bit)
 *   AVX2:     4 deps/cycle  (256-bit)
 *   AVX-512:  8 deps/cycle  (512-bit)
 *   RV64V:    VLEN/64 deps/cycle (scalable, hardware-defined)
 */

#ifndef SHAPE_SHIM_H
#define SHAPE_SHIM_H

#include <stdint.h>

/* --- Core arithmetic (all ISAs) --- */

/* Loop accumulator: for i in [start, end) { acc += i } */
int64_t asm_loop_accum_add(int64_t start, int64_t end, int64_t init);

/* Structural shortcut: init + c * (end - start) */
int64_t asm_loop_accum_const(int64_t start, int64_t end, int64_t init, int64_t c);

/* Nested loop shortcut: init + n * m */
int64_t asm_nested_accum(int64_t n, int64_t m, int64_t init);

/* Exponentiation by repeated squaring */
int64_t asm_pow(int64_t base, int64_t exp);

/* Primitives */
int64_t asm_add(int64_t a, int64_t b);
int64_t asm_mul(int64_t a, int64_t b);
int64_t asm_div(int64_t a, int64_t b);

/* --- Atomics (RV64IMA, x86-64) --- */

/* Atomic tick increment. Returns old value. */
int64_t asm_atomic_tick_inc(int64_t *tick_addr);

/* Compare-and-swap. Returns 1 if swapped, 0 if not. */
int64_t asm_atomic_cas(int64_t *addr, int64_t expected, int64_t desired);

/* Atomic fetch-and-add. Returns old value. */
int64_t asm_atomic_add(int64_t *addr, int64_t val);

/* --- SIMD wave propagation (SSE2, AVX2, AVX-512, RV64V) --- */

/* Sum int64 array. Width depends on ISA. */
int64_t asm_vec_accum(int64_t *array, int64_t len);

/* Stamp dependents: set tick to new_tick where old < new. */
int64_t asm_vec_propagate(int64_t *dep_ticks, int64_t new_tick, int64_t count);

/* Count dangling references (zero flags). */
int64_t asm_vec_validate(int64_t *dep_flags, int64_t count);

/*
 * ISA capability matrix:
 *
 * Feature        | RV32I | RV64I | RV64IM | RV64IMA | RV64GV | i386 | x64 | SSE2 | AVX2 | AVX512
 * ---------------|-------|-------|--------|---------|--------|------|-----|------|------|-------
 * add            |   Y   |   Y   |   Y    |    Y    |   Y    |  Y   |  Y  |  Y   |  Y   |   Y
 * mul (hardware) |   N   |   N   |   Y    |    Y    |   Y    |  Y   |  Y  |  Y   |  Y   |   Y
 * div (hardware) |   N   |   N   |   Y    |    Y    |   Y    |  Y   |  Y  |  Y   |  Y   |   Y
 * atomic CAS     |   N   |   N   |   N    |    Y    |   Y    |  N   |  Y  |  Y   |  Y   |   Y
 * SIMD accum     |   N   |   N   |   N    |    N    |   Y    |  N   |  N  |  2x  |  4x  |   8x
 * SIMD propagate |   N   |   N   |   N    |    N    |   Y    |  N   |  N  |  2x  |  4x  |   8x
 * SIMD validate  |   N   |   N   |   N    |    N    |   Y    |  N   |  N  |  N   |  4x  |   8x
 * opmask         |   N   |   N   |   N    |    N    |   N    |  N   |  N  |  N   |  N   |   Y
 * Gauss shortcut |   Y   |   Y   |   Y    |    Y    |   Y    |  Y   |  Y  |  Y   |  Y   |   Y
 *
 * The last row is the point. The structural shortcut works on EVERY ISA.
 * The Gauss sum is 3 instructions regardless of architecture.
 * SIMD accelerates the loop version. The formula doesn't need SIMD.
 * Structural recognition makes the hardware irrelevant.
 */

#endif /* SHAPE_SHIM_H */
