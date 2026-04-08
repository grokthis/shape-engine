public class BenchScale {
    static long gaussDirect(long n) { return n * (n - 1) / 2; }
    static long nativeLoop(int n) { long s = 0; for (int i = 0; i < n; i++) s += i; return s; }

    static double bench(String name, int iters, java.util.function.LongSupplier fn) {
        for (int i = 0; i < 10000; i++) fn.getAsLong();
        long t0 = System.nanoTime();
        for (int i = 0; i < iters; i++) fn.getAsLong();
        long t1 = System.nanoTime();
        double ns = (double)(t1 - t0) / iters;
        System.out.printf("  %-40s %10.1f ns/op%n", name, ns);
        return ns;
    }

    public static void main(String[] args) {
        System.out.println("Java: Shape vs Native at scale\n");
        for (int n : new int[]{1000, 10000, 100000, 1000000}) {
            final int nn = n;
            double nat = bench("native loop " + n, n > 100000 ? 1000 : 100000, () -> nativeLoop(nn));
            double shp = bench("gauss " + n, 10000000, () -> gaussDirect(nn));
            System.out.printf("  -> %.1fx faster%n%n", nat / shp);
        }
    }
}
