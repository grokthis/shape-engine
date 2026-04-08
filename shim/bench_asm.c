// bench_asm.c — Benchmark the assembly shape engine.
// Build: cc -O2 -o bench_asm bench_asm.c shape_arm64.s eval.c
// Run:   ./bench_asm

#include <stdio.h>
#include <time.h>
#include <stdint.h>

// Assembly functions.
extern int64_t asm_loop_accum_add(int64_t start, int64_t end, int64_t init);
extern int64_t asm_loop_accum_const(int64_t start, int64_t end, int64_t init, int64_t c);
extern int64_t asm_nested_accum(int64_t n, int64_t m, int64_t init);
extern int64_t asm_pow(int64_t base, int64_t exp);
extern int64_t asm_add(int64_t a, int64_t b);
extern int64_t asm_mul(int64_t a, int64_t b);
extern int64_t asm_div(int64_t a, int64_t b);

// C functions from eval.c for comparison.
extern int64_t native_loop_1000(void);
extern int64_t native_nested_10x10(void);
extern int64_t native_pow_2_20(void);
extern int64_t shape_loop_accum_add(int64_t, int64_t, int64_t);
extern int64_t shape_nested_accum(int64_t, int64_t, int64_t);

static inline uint64_t now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static volatile int64_t sink;

#define BENCH(NAME, ITERS, CODE) do { \
    uint64_t _t0 = now_ns(); \
    for (int _i = 0; _i < (ITERS); _i++) { CODE; } \
    uint64_t _t1 = now_ns(); \
    double _ns = (double)(_t1 - _t0) / (double)(ITERS); \
    printf("  %-45s %8.1f ns/op\n", NAME, _ns); \
} while(0)

int main(void) {
    printf("Shape Engine Assembly Benchmark (M1 Pro, ARM64)\n");
    printf("================================================\n\n");

    // Verify correctness first.
    printf("--- Correctness ---\n");
    printf("  loop_accum_add(0,1000,0)    = %lld (expect 499500)\n", asm_loop_accum_add(0, 1000, 0));
    printf("  loop_accum_const(0,1000,0,1)= %lld (expect 1000)\n", asm_loop_accum_const(0, 1000, 0, 1));
    printf("  nested_accum(10,10,0)       = %lld (expect 100)\n", asm_nested_accum(10, 10, 0));
    printf("  pow(2,20)                   = %lld (expect 1048576)\n", asm_pow(2, 20));
    printf("  add(42,17)                  = %lld (expect 59)\n", asm_add(42, 17));
    printf("  mul(6,7)                    = %lld (expect 42)\n", asm_mul(6, 7));
    printf("  div(100,7)                  = %lld (expect 14)\n", asm_div(100, 7));
    printf("\n");

    // Benchmarks.
    printf("--- Native C (-O2) ---\n");
    BENCH("loop 1000 (sum)", 10000000, { sink = native_loop_1000(); });
    BENCH("nested 10x10", 100000000, { sink = native_nested_10x10(); });
    BENCH("pow 2^20", 100000000, { sink = native_pow_2_20(); });

    printf("\n--- C Shape Engine (-O2) ---\n");
    BENCH("loop 1000 (accum+counter)", 10000000, { sink = shape_loop_accum_add(0, 1000, 0); });
    BENCH("nested 10x10", 100000000, { sink = shape_nested_accum(10, 10, 0); });

    printf("\n--- Assembly (hand-written ARM64) ---\n");
    BENCH("add (1 instruction)", 1000000000, { sink = asm_add(42, 17); });
    BENCH("mul (1 instruction)", 1000000000, { sink = asm_mul(6, 7); });
    BENCH("div (1 instruction)", 1000000000, { sink = asm_div(100, 7); });
    BENCH("loop 1000 (accum+counter, unrolled)", 10000000, { sink = asm_loop_accum_add(0, 1000, 0); });
    BENCH("loop 1000 (accum+const, collapsed)", 10000000, { sink = asm_loop_accum_const(0, 1000, 0, 1); });
    BENCH("nested 10x10 (collapsed to mul)", 100000000, { sink = asm_nested_accum(10, 10, 0); });
    BENCH("pow 2^20 (repeated squaring)", 100000000, { sink = asm_pow(2, 20); });

    printf("\n\n=== FULL COMPARISON ===\n\n");
    printf("%-30s %8s %8s %8s %8s %8s\n", "Operation", "ASM", "C -O2", "C Shape", "Go SL", "Go -O2");
    printf("-----------------------------------------------------------------------\n");

    return 0;
}
