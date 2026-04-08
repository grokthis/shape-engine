// bench.c — Shape engine C benchmark.
// Build: cc -O2 -o bench bench.c eval.c
// Run:   ./bench

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "shape.h"

// Functions in eval.c (separate compilation unit, no constant folding).
extern int64_t shape_loop_accum_add(int64_t start, int64_t end, int64_t init);
extern int64_t shape_loop_accum_const(int64_t start, int64_t end, int64_t init, int64_t c);
extern int64_t shape_nested_accum(int64_t n, int64_t m, int64_t init);
extern int64_t native_loop_1000(void);
extern int64_t native_nested_10x10(void);
extern int64_t native_pow_2_20(void);
extern int64_t shape_eval_full_loop_1000(const char *sn, const char *in_);
extern void shape_engine_add_n(Engine *e, int n);

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
    printf("  %-42s %8.1f ns/op\n", NAME, _ns); \
} while(0)

int main(void) {
    printf("Shape Engine C Benchmark (M1 Pro, -O2)\n");
    printf("=======================================\n\n");

    static char arena_buf[1024 * 1024];
    Arena arena;
    arena_init(&arena, arena_buf, sizeof(arena_buf));
    Engine eng;
    InternTable itab;
    memset(&itab, 0, sizeof(itab));
    const char *sn = intern(&itab, "s");
    const char *in_ = intern(&itab, "i");

    printf("--- Native C ---\n");
    BENCH("loop 1000 (sum i)", 10000000, { sink = native_loop_1000(); });
    BENCH("nested 10x10 (count)", 100000000, { sink = native_nested_10x10(); });
    BENCH("pow 2^20", 100000000, { sink = native_pow_2_20(); });

    printf("\n--- C Shape Engine (tight patterns) ---\n");
    BENCH("loop 1000 (accum + counter)", 10000000, { sink = shape_loop_accum_add(0, 1000, 0); });
    BENCH("loop 1000 (accum + const 1)", 10000000, { sink = shape_loop_accum_const(0, 1000, 0, 1); });
    BENCH("nested 10x10 (accum)", 100000000, { sink = shape_nested_accum(10, 10, 0); });
    BENCH("eval full loop 1000 (regs+loop)", 1000000, { sink = shape_eval_full_loop_1000(sn, in_); });

    printf("\n--- C Shape Engine (operations) ---\n");
    BENCH("engine_add (single)", 10000000, {
        engine_init(&eng);
        engine_add(&eng, "bench.shape");
    });

    engine_init(&eng);
    for (int i = 0; i < 100; i++) {
        char *id = (char *)arena_alloc(&arena, 16);
        snprintf(id, 16, "bench.s%d", i);
        engine_add(&eng, id);
    }
    BENCH("engine_get (100 shapes, linear)", 10000000, {
        sink = (int64_t)(size_t)engine_get(&eng, "bench.s50");
    });

    engine_init(&eng);
    engine_add(&eng, "bench.target")->content = "v0";
    BENCH("engine_edit", 100000000, {
        engine_edit(&eng, "bench.target", "v1");
    });

    BENCH("arena 1000 allocs + reset", 10000000, {
        arena_reset(&arena);
        for (int j = 0; j < 1000; j++) arena_alloc(&arena, 16);
    });

    Registers regs;
    regs_init(&regs);
    int si = regs_bind(&regs, sn);
    BENCH("register set+get", 100000000, {
        regs_set(&regs, si, val_int(42));
        sink = regs_get(&regs, si).i;
    });

    BENCH("val_int create", 100000000, {
        Value v = val_int(42); sink = v.i;
    });

    // Summary
    printf("\n\n=== CROSS-PLATFORM COMPARISON ===\n\n");
    printf("%-25s %10s %10s %10s %10s\n", "Operation", "Native C", "C Shape", "Go Shape", "Go Native");
    printf("%-25s %10s %10s %10s %10s\n", "", "-O2", "engine", "lang", "-O2");
    printf("-------------------------------------------------------------------\n");

    return 0;
}
