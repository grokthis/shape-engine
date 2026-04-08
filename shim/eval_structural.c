// eval_structural.c — Structural evaluator.
//
// Each shape-lang pattern becomes a C function.
// The C compiler optimizes each function to minimal instructions.
// The structure encodes all the way down to the CPU.
//
// This is NOT an interpreter. It's a set of structural transforms
// that the compiler maps directly to hardware operations.

#include <stdint.h>

// ============================================================
// Pattern: for i in range(start, end) { acc += i }
// Structure: Gauss sum. O(1).
// C compiler emits: sub, add, mul, asr (4 instructions).
// ============================================================
int64_t structural_sum_range(int64_t start, int64_t end, int64_t init) {
    int64_t n = end - start;
    // Sum of arithmetic sequence: n * (first + last) / 2
    // first = start, last = end - 1
    return init + n * (start + end - 1) / 2;
}

// ============================================================
// Pattern: for i in range(start, end) { acc += c }
// Structure: multiplication. O(1).
// C compiler emits: sub, mul, add (3 instructions).
// ============================================================
int64_t structural_accum_const(int64_t start, int64_t end, int64_t init, int64_t c) {
    return init + (end - start) * c;
}

// ============================================================
// Pattern: for i in range(n) { for j in range(m) { acc++ } }
// Structure: multiplication. O(1).
// C compiler emits: mul, add (2 instructions).
// ============================================================
int64_t structural_nested_count(int64_t n, int64_t m, int64_t init) {
    return init + n * m;
}

// ============================================================
// Pattern: pow(base, exp) where exp >= 0
// Structure: repeated squaring. O(log n).
// C compiler emits: tight loop with mul, lsr, tst.
// ============================================================
int64_t structural_pow(int64_t base, int64_t exp) {
    int64_t result = 1;
    while (exp > 0) {
        if (exp & 1) result *= base;
        base *= base;
        exp >>= 1;
    }
    return result;
}

// ============================================================
// Pattern: sum(list) where list is range(n)
// Structure: Gauss sum. O(1).
// sum(range(n)) = n*(n-1)/2
// ============================================================
int64_t structural_sum_range_n(int64_t n) {
    return n * (n - 1) / 2;
}

// ============================================================
// Pattern: for i in range(n) { acc *= i } (factorial, start=1)
// Structure: sequential multiply (can't collapse further).
// But: for small n, lookup table. For large n, Stirling approx.
// ============================================================
int64_t structural_factorial(int64_t n) {
    // Lookup table for small values (0! through 20!).
    static const int64_t table[] = {
        1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880,
        3628800, 39916800, 479001600, 6227020800LL,
        87178291200LL, 1307674368000LL, 20922789888000LL,
        355687428096000LL, 6402373705728000LL,
        121645100408832000LL, 2432902008176640000LL
    };
    if (n >= 0 && n <= 20) return table[n];
    // Overflow for int64 beyond 20!
    int64_t result = table[20];
    for (int64_t i = 21; i <= n; i++) result *= i;
    return result;
}

// ============================================================
// Pattern: for i in range(n) { if condition { count++ } }
// Structure: filter + count. Can't collapse without knowing
// the condition. But: if condition is i % k == 0, then
// count = n / k.
// ============================================================
int64_t structural_count_divisible(int64_t n, int64_t k) {
    if (k == 0) return 0;
    return n / k;
}

// ============================================================
// Pattern: for i in range(n) { acc = acc * base + digit[i] }
// Structure: Horner's method (polynomial evaluation).
// Can't collapse to O(1) but is already optimal O(n).
// ============================================================
int64_t structural_horner(const int64_t *digits, int64_t n, int64_t base) {
    int64_t acc = 0;
    for (int64_t i = 0; i < n; i++) {
        acc = acc * base + digits[i];
    }
    return acc;
}

// ============================================================
// Full eval simulation: recognize pattern, dispatch to
// structural function, return result.
//
// This is what the shape engine does at eval time.
// In C, the compiler optimizes each path to minimal instructions.
// The structure flows through the compiler to the CPU.
// ============================================================

typedef enum {
    PATTERN_SUM_RANGE,      // for i in range(n) { s += i }
    PATTERN_ACCUM_CONST,    // for i in range(n) { s += c }
    PATTERN_NESTED_COUNT,   // for i { for j { s++ } }
    PATTERN_POW,            // pow(base, exp)
    PATTERN_FACTORIAL,      // for i in 1..n { s *= i }
    PATTERN_GENERAL_LOOP,   // no collapse, iterate
} Pattern;

typedef struct {
    Pattern pattern;
    int64_t a, b, c, init;
} ShapeExpr;

int64_t structural_eval(ShapeExpr *expr) {
    switch (expr->pattern) {
    case PATTERN_SUM_RANGE:
        return structural_sum_range(0, expr->a, expr->init);
    case PATTERN_ACCUM_CONST:
        return structural_accum_const(0, expr->a, expr->init, expr->b);
    case PATTERN_NESTED_COUNT:
        return structural_nested_count(expr->a, expr->b, expr->init);
    case PATTERN_POW:
        return structural_pow(expr->a, expr->b);
    case PATTERN_FACTORIAL:
        return structural_factorial(expr->a);
    case PATTERN_GENERAL_LOOP: {
        // Fallback: iterate honestly.
        int64_t acc = expr->init;
        for (int64_t i = 0; i < expr->a; i++) {
            acc += i;
        }
        return acc;
    }
    }
    return 0;
}
