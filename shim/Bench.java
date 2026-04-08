// Bench.java — Shape engine benchmark in Java.
// Built from the fastest structure: primitive int arrays for AST,
// integer tags, no boxing, no object allocation in the hot path.
//
// javac Bench.java && java Bench

public class Bench {

    // AST tags. Same as every other substrate.
    static final int T_LET = 1, T_SET = 2, T_FOR = 3;
    static final int T_INT = 20, T_IDENT = 24, T_BINOP = 25, T_CALL = 27;

    // Operators as ints.
    static final int OP_ADD = 1, OP_SUB = 2;

    // AST encoded as flat int array. No objects.
    // Layout: [tag, ...fields]
    // Pointers are indices into the array.
    //
    // Program: let s = 0; for i in range(1000) { set s = s + i }
    //
    // Index  Contents
    // 0-2:   [T_INT, 0]                          init value
    // 2-4:   [T_LET, 0]                          let s = ^0  (name=0=s, expr=idx 0)
    // 4-6:   [T_INT, 1000]                       range arg
    // 6-8:   [T_IDENT, 0]                        ident s
    // 8-10:  [T_IDENT, 1]                        ident i
    // 10-14: [T_BINOP, OP_ADD, 6, 8]             s + i (left=idx 6, right=idx 8)
    // 14-17: [T_SET, 0, 10]                      set s = ^10
    // 17-22: [T_FOR, 1, 4, 14, 1]               for i, range_arg=idx 4, body=idx 14, body_len=1
    // 22-24: [2, 17]                             program: 2 stmts at idx 2 and idx 17

    // evalFast: recognize the pattern directly on the int array.
    // No object creation. No method dispatch. Just array reads and arithmetic.
    static long evalFast(int[] ast, int progIdx) {
        int nstmts = ast[progIdx];
        if (nstmts != 2) return Long.MIN_VALUE;

        int s0 = ast[progIdx + 1]; // first stmt index
        int s1 = ast[progIdx + 2]; // second stmt index

        // s0 must be T_LET
        if (ast[s0] != T_LET) return Long.MIN_VALUE;
        int letName = ast[s0 + 1];
        int exprIdx = ast[s0 + 2]; // points to init expr
        if (ast[exprIdx] != T_INT) return Long.MIN_VALUE;
        long init = ast[exprIdx + 1];

        // s1 must be T_FOR
        if (ast[s1] != T_FOR) return Long.MIN_VALUE;
        int loopVar = ast[s1 + 1];
        int rangeArgIdx = ast[s1 + 2];
        int bodyIdx = ast[s1 + 3];
        // int bodyLen = ast[s1 + 4]; // unused, we check body directly

        // range arg must be T_INT
        if (ast[rangeArgIdx] != T_INT) return Long.MIN_VALUE;
        long end = ast[rangeArgIdx + 1];
        long count = end; // start=0

        // body must be T_SET with same name
        if (ast[bodyIdx] != T_SET) return Long.MIN_VALUE;
        if (ast[bodyIdx + 1] != letName) return Long.MIN_VALUE;
        int setExprIdx = ast[bodyIdx + 2];

        // set expr must be T_BINOP
        if (ast[setExprIdx] != T_BINOP) return Long.MIN_VALUE;
        int op = ast[setExprIdx + 1];
        int leftIdx = ast[setExprIdx + 2];
        int rightIdx = ast[setExprIdx + 3];

        // left must be ident(letName)
        if (ast[leftIdx] != T_IDENT || ast[leftIdx + 1] != letName) return Long.MIN_VALUE;

        // right: ident(loopVar) -> Gauss sum. int literal -> multiply.
        if (ast[rightIdx] == T_IDENT && ast[rightIdx + 1] == loopVar) {
            long sum = count * (count - 1) / 2;
            if (op == OP_ADD) return init + sum;
            if (op == OP_SUB) return init - sum;
        }
        if (ast[rightIdx] == T_INT) {
            long c = ast[rightIdx + 1];
            if (op == OP_ADD) return init + count * c;
            if (op == OP_SUB) return init - count * c;
        }
        return Long.MIN_VALUE;
    }

    // Direct formula (no AST, no pattern match).
    static long gaussDirect(long n) {
        return n * (n - 1) / 2;
    }

    // Native loop.
    static long nativeLoop1000() {
        long s = 0;
        for (int i = 0; i < 1000; i++) s += i;
        return s;
    }

    static long nativeNested10x10() {
        long s = 0;
        for (int i = 0; i < 10; i++)
            for (int j = 0; j < 10; j++)
                s++;
        return s;
    }

    // Benchmark helper.
    static double bench(String name, int iters, java.util.function.LongSupplier fn) {
        // Warmup.
        for (int i = 0; i < 10000; i++) fn.getAsLong();

        long t0 = System.nanoTime();
        for (int i = 0; i < iters; i++) fn.getAsLong();
        long t1 = System.nanoTime();

        double ns = (double)(t1 - t0) / iters;
        System.out.printf("  %-45s %8.1f ns/op%n", name, ns);
        return ns;
    }

    public static void main(String[] args) {
        // Build the AST as a flat int array.
        int[] ast = {
            // 0: T_INT 0 (init value)
            T_INT, 0,
            // 2: T_LET name=0(s) expr=0
            T_LET, 0, 0,
            // 5: T_INT 1000 (range arg)
            T_INT, 1000,
            // 7: T_IDENT 0 (s)
            T_IDENT, 0,
            // 9: T_IDENT 1 (i)
            T_IDENT, 1,
            // 11: T_BINOP ADD left=7 right=9
            T_BINOP, OP_ADD, 7, 9,
            // 15: T_SET name=0(s) expr=11
            T_SET, 0, 11,
            // 18: T_FOR var=1(i) range=5 body=15 bodyLen=1
            T_FOR, 1, 5, 15, 1,
            // 23: program: 2 stmts at 2 and 18
            2, 2, 18,
        };

        // Verify.
        long result = evalFast(ast, 23);
        System.out.println("Shape Engine Java Benchmark");
        System.out.println("===========================\n");
        System.out.println("Correctness:");
        System.out.println("  evalFast = " + result + " (expect 499500)");
        System.out.println("  gauss    = " + gaussDirect(1000) + " (expect 499500)");
        System.out.println("  native   = " + nativeLoop1000() + " (expect 499500)");
        System.out.println();

        System.out.println("--- Java Native (JIT warmed) ---");
        double natLoop = bench("loop 1000 (sum)", 10_000_000, Bench::nativeLoop1000);
        double natNested = bench("nested 10x10", 100_000_000, Bench::nativeNested10x10);

        System.out.println("\n--- Java Shape Engine ---");
        double shpGauss = bench("gauss(1000) direct", 100_000_000, () -> gaussDirect(1000));
        double shpEval = bench("evalFast (flat int[] AST)", 100_000_000, () -> evalFast(ast, 23));

        System.out.println("\n--- Speedup ---");
        System.out.printf("  loop 1000 (formula):    %6.1fx faster than Java native%n", natLoop / shpGauss);
        System.out.printf("  loop 1000 (full eval):  %6.1fx faster than Java native%n", natLoop / shpEval);
    }
}
