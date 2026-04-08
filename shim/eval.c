// eval.c — Shape engine evaluation functions.
// Separate compilation unit prevents constant folding.

#include "shape.h"

// These are NOT inline. The compiler cannot see through them.
// This is the honest measurement of the shape engine's tight paths.

int64_t shape_loop_accum_add(int64_t start, int64_t end, int64_t init) {
    int64_t acc = init;
    for (int64_t i = start; i < end; i++) {
        acc += i;
    }
    return acc;
}

int64_t shape_loop_accum_const(int64_t start, int64_t end, int64_t init, int64_t c) {
    int64_t acc = init;
    for (int64_t i = start; i < end; i++) {
        acc += c;
    }
    return acc;
}

int64_t shape_nested_accum(int64_t n, int64_t m, int64_t init) {
    int64_t acc = init;
    for (int64_t i = 0; i < n; i++) {
        for (int64_t j = 0; j < m; j++) {
            acc++;
        }
    }
    return acc;
}

int64_t native_loop_1000(void) {
    int64_t s = 0;
    for (int j = 0; j < 1000; j++) s += j;
    return s;
}

int64_t native_nested_10x10(void) {
    int64_t s = 0;
    for (int j = 0; j < 10; j++)
        for (int k = 0; k < 10; k++)
            s++;
    return s;
}

int64_t native_pow_2_20(void) {
    int64_t r = 1;
    for (int j = 0; j < 20; j++) r *= 2;
    return r;
}

// Full eval simulation: register init, bind, loop, read.
int64_t shape_eval_full_loop_1000(const char *sn, const char *in_) {
    Registers r;
    regs_init(&r);
    int si = regs_bind(&r, sn);
    regs_bind(&r, in_);
    regs_set(&r, si, val_int(0));
    int64_t acc = 0;
    for (int64_t j = 0; j < 1000; j++) acc += j;
    regs_set(&r, si, val_int(acc));
    return regs_get(&r, si).i;
}

// Engine operations through function boundary.
void shape_engine_add_n(Engine *e, int n) {
    engine_init(e);
    for (int i = 0; i < n; i++) {
        engine_add(e, "bench.shape");
    }
}
