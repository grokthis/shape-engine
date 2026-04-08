// bench_full.c — Full benchmark: C native vs C-on-shapes vs Go numbers.
//
// The C shape engine gets the same structural optimizations as Go:
// pattern recognition, formula collapse, static fusion.
//
// Build: cc -O2 -o bench_full bench_full.c shape_arm64.s
// Run:   ./bench_full

#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <string.h>

// Assembly functions.
extern int64_t asm_loop_accum_add(int64_t start, int64_t end, int64_t init);
extern int64_t asm_loop_accum_const(int64_t start, int64_t end, int64_t init, int64_t c);
extern int64_t asm_nested_accum(int64_t n, int64_t m, int64_t init);
extern int64_t asm_pow(int64_t base, int64_t exp);
extern int64_t asm_add(int64_t a, int64_t b);
extern int64_t asm_mul(int64_t a, int64_t b);
extern int64_t asm_div(int64_t a, int64_t b);

static inline uint64_t now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec;
}

static volatile int64_t sink;

// ============================================================
// C Shape Engine: structural optimizer
//
// Same progression as Go:
//   1. Naive interpreter (iterates)
//   2. Pattern recognition (native loop)
//   3. Formula collapse (Gauss sum)
//   4. Static fusion (no interpreter at all)
// ============================================================

// Level 0: Naive interpreter. Simulates fetch-decode-execute.
typedef enum { OP_ADD, OP_SUB, OP_MUL, OP_CMP_LT, OP_JMP, OP_JZ, OP_INC, OP_LOAD, OP_STORE, OP_HALT } Opcode;

typedef struct { Opcode op; int64_t a, b; } Instr;

__attribute__((noinline))
int64_t c_level0_interpret(void) {
    // for i := 0; i < 1000; i++ { s += i }
    // Compiled to bytecode:
    int64_t regs[4] = {0}; // r0=s, r1=i, r2=1000, r3=temp
    Instr code[] = {
        {OP_LOAD, 0, 0},       // r0 = 0 (s)
        {OP_LOAD, 1, 0},       // r1 = 0 (i)
        {OP_LOAD, 2, 1000},    // r2 = 1000
        // loop:
        {OP_CMP_LT, 1, 2},     // r3 = r1 < r2
        {OP_JZ, 3, 8},         // if !r3, jump to halt
        {OP_ADD, 0, 1},        // r0 += r1
        {OP_INC, 1, 0},        // r1++
        {OP_JMP, 0, 3},        // jump to loop
        {OP_HALT, 0, 0},
    };
    int pc = 0;
    while (1) {
        Instr *ip = &code[pc];
        switch (ip->op) {
        case OP_LOAD:  regs[ip->a] = ip->b; pc++; break;
        case OP_ADD:   regs[ip->a] += regs[ip->b]; pc++; break;
        case OP_INC:   regs[ip->a]++; pc++; break;
        case OP_CMP_LT: regs[3] = regs[ip->a] < regs[ip->b]; pc++; break;
        case OP_JZ:    pc = regs[ip->a] ? pc+1 : (int)ip->b; break;
        case OP_JMP:   pc = (int)ip->b; break;
        case OP_HALT:  return regs[0];
        default: return -1;
        }
    }
}

// Level 1: Native loop. Pattern recognized, loop runs as C for loop.
__attribute__((noinline))
int64_t c_level1_native_loop(void) {
    int64_t s = 0;
    for (int64_t i = 0; i < 1000; i++) {
        s += i;
    }
    return s;
}

// Level 2: Formula collapse. Loop IS Gauss sum.
__attribute__((noinline))
int64_t c_level2_formula(int64_t n) {
    return n * (n - 1) / 2;
}

// Level 3: Static fusion. No function call overhead.
// The compiler inlines the arithmetic when called with constants.
static inline int64_t c_level3_static(void) {
    return 1000 * 999 / 2;
}

// Same for nested: for i in 10 { for j in 10 { s++ } }

__attribute__((noinline))
int64_t c_nested_interpret(void) {
    int64_t regs[4] = {0}; // r0=s, r1=i, r2=j
    for (regs[1] = 0; regs[1] < 10; regs[1]++) {
        for (regs[2] = 0; regs[2] < 10; regs[2]++) {
            regs[0]++;
        }
    }
    return regs[0];
}

__attribute__((noinline))
int64_t c_nested_native(void) {
    int64_t s = 0;
    for (int i = 0; i < 10; i++)
        for (int j = 0; j < 10; j++)
            s++;
    return s;
}

__attribute__((noinline))
int64_t c_nested_formula(int64_t n, int64_t m) {
    return n * m;
}

// Same for pow(2, 20)

__attribute__((noinline))
int64_t c_pow_naive(int64_t base, int64_t exp) {
    int64_t r = 1;
    for (int64_t i = 0; i < exp; i++) r *= base;
    return r;
}

__attribute__((noinline))
int64_t c_pow_squaring(int64_t base, int64_t exp) {
    int64_t r = 1;
    while (exp > 0) {
        if (exp & 1) r *= base;
        base *= base;
        exp >>= 1;
    }
    return r;
}

// Constant pow: compile-time.
static inline int64_t c_pow_static(void) {
    return 1 << 20; // 2^20 = bit shift
}

// ============================================================
// Benchmark harness
// ============================================================

typedef struct { const char *name; double ns; } Result;
static Result results[64];
static int nresults;

#define BENCH(NAME, ITERS, CODE) do { \
    uint64_t _t0 = now_ns(); \
    for (int _i = 0; _i < (ITERS); _i++) { CODE; } \
    uint64_t _t1 = now_ns(); \
    results[nresults++] = (Result){NAME, (double)(_t1-_t0)/(double)(ITERS)}; \
} while(0)

int main(void) {
    printf("Full Benchmark: C Optimization Levels (M1 Pro, -O2)\n");
    printf("====================================================\n\n");

    // Verify correctness.
    printf("Correctness:\n");
    printf("  interpret loop 1000:  %lld (expect 499500)\n", c_level0_interpret());
    printf("  native loop 1000:    %lld (expect 499500)\n", c_level1_native_loop());
    printf("  formula(1000):       %lld (expect 499500)\n", c_level2_formula(1000));
    printf("  static:              %lld (expect 499500)\n", c_level3_static());
    printf("  nested interpret:    %lld (expect 100)\n", c_nested_interpret());
    printf("  nested native:       %lld (expect 100)\n", c_nested_native());
    printf("  nested formula:      %lld (expect 100)\n", c_nested_formula(10, 10));
    printf("  pow naive 2^20:      %lld (expect 1048576)\n", c_pow_naive(2, 20));
    printf("  pow squaring 2^20:   %lld (expect 1048576)\n", c_pow_squaring(2, 20));
    printf("  pow static:          %lld (expect 1048576)\n", c_pow_static());
    printf("  asm loop 1000:       %lld (expect 499500)\n", asm_loop_accum_add(0, 1000, 0));
    printf("  asm collapsed:       %lld (expect 1000)\n", asm_loop_accum_const(0, 1000, 0, 1));
    printf("  asm nested:          %lld (expect 100)\n", asm_nested_accum(10, 10, 0));
    printf("  asm pow:             %lld (expect 1048576)\n", asm_pow(2, 20));
    printf("\n");

    // ---- Loop 1000: sum of 0..999 ----
    printf("=== for i := 0; i < 1000; i++ { s += i } ===\n\n");

    BENCH("C bytecode interpreter",    1000000, { sink = c_level0_interpret(); });
    BENCH("C native loop",             10000000, { sink = c_level1_native_loop(); });
    BENCH("C formula collapse",        100000000, { sink = c_level2_formula(1000); });
    BENCH("C static fusion",           1000000000, { sink = c_level3_static(); });
    BENCH("ARM64 honest loop",         10000000, { sink = asm_loop_accum_add(0, 1000, 0); });
    BENCH("ARM64 collapsed (const)",   100000000, { sink = asm_loop_accum_const(0, 1000, 0, 1); });

    // ---- Nested 10x10 ----
    printf("\n=== for i := 0; i < 10; i++ { for j { s++ } } ===\n\n");

    BENCH("C nested interpret",        10000000, { sink = c_nested_interpret(); });
    BENCH("C nested native",           100000000, { sink = c_nested_native(); });
    BENCH("C nested formula",          1000000000, { sink = c_nested_formula(10, 10); });
    BENCH("ARM64 nested collapsed",    1000000000, { sink = asm_nested_accum(10, 10, 0); });

    // ---- Pow 2^20 ----
    printf("\n=== pow(2, 20) ===\n\n");

    BENCH("C pow naive (O(n))",        100000000, { sink = c_pow_naive(2, 20); });
    BENCH("C pow squaring (O(log n))", 100000000, { sink = c_pow_squaring(2, 20); });
    BENCH("C pow static (bit shift)",  1000000000, { sink = c_pow_static(); });
    BENCH("ARM64 pow squaring",        100000000, { sink = asm_pow(2, 20); });

    // ---- Single ops ----
    printf("\n=== Single operations ===\n\n");

    BENCH("ARM64 add (1 instr)",       1000000000, { sink = asm_add(42, 17); });
    BENCH("ARM64 mul (1 instr)",       1000000000, { sink = asm_mul(6, 7); });
    BENCH("ARM64 div (1 instr)",       1000000000, { sink = asm_div(100, 7); });

    // ---- Print results ----
    printf("\n\n========================================\n");
    printf("RESULTS\n");
    printf("========================================\n\n");

    printf("%-35s %10s\n", "Benchmark", "ns/op");
    printf("%-35s %10s\n", "---", "---");
    for (int i = 0; i < nresults; i++) {
        printf("%-35s %10.1f\n", results[i].name, results[i].ns);
    }

    printf("\n\n========================================\n");
    printf("CROSS-PLATFORM COMPARISON\n");
    printf("========================================\n\n");

    printf("%-30s %8s %8s %8s %8s %8s\n", "for i<1000 { s+=i }", "ASM", "C -O2", "C Shape", "Go Shp", "Go Nat");
    printf("%-30s %8s %8s %8s %8s %8s\n", "---", "---", "---", "---", "---", "---");

    // Find our results.
    double asm_loop = 0, asm_collapsed = 0, c_interp = 0, c_native = 0, c_formula = 0, c_static = 0;
    for (int i = 0; i < nresults; i++) {
        if (strcmp(results[i].name, "ARM64 honest loop") == 0) asm_loop = results[i].ns;
        if (strcmp(results[i].name, "ARM64 collapsed (const)") == 0) asm_collapsed = results[i].ns;
        if (strcmp(results[i].name, "C bytecode interpreter") == 0) c_interp = results[i].ns;
        if (strcmp(results[i].name, "C native loop") == 0) c_native = results[i].ns;
        if (strcmp(results[i].name, "C formula collapse") == 0) c_formula = results[i].ns;
        if (strcmp(results[i].name, "C static fusion") == 0) c_static = results[i].ns;
    }

    printf("%-30s %7.1fns %7.1fns %7.1fns %7.1fns %7.1fns\n", "Bytecode interpreter", 0.0, c_interp, 0.0, 0.0, 0.0);
    printf("%-30s %7.1fns %7.1fns %7.1fns %7.1fns %7.1fns\n", "Native loop", asm_loop, c_native, 0.0, 866.0, 321.0);
    printf("%-30s %7.1fns %7.1fns %7.1fns %7.1fns %7.1fns\n", "Formula collapse", asm_collapsed, c_formula, 0.0, 10.7, 0.0);
    printf("%-30s %7.1fns %7.1fns %7.1fns %7.1fns %7.1fns\n", "Static fusion", 0.0, c_static, 0.0, 10.7, 0.0);

    printf("\nGo shape-lang numbers from Go benchmark suite.\n");
    printf("Go native = Go compiler, no shape engine.\n");

    return 0;
}
