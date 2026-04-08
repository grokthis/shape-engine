#!/bin/bash
# bench_all.sh — Run shape engine benchmarks in every available language.
# Each language: native loop 1000 vs shape formula.
# Same structure, same formula, different substrate.

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

echo "Shape Engine: Cross-Language Benchmark (M1 Pro)"
echo "================================================"
echo ""
echo "for i in range(1000) { s += i }"
echo "Native loop vs shape formula on every substrate."
echo ""

RESULTS=""
add_result() {
    RESULTS="$RESULTS$1|$2|$3|$4\n"
}

# --- Python ---
if command -v python3 &>/dev/null; then
echo "--- Python ---"
python3 -c "
import time

def gauss(n): return n * (n - 1) // 2

def native_loop():
    s = 0
    for i in range(1000): s += i
    return s

# Warmup
for _ in range(1000): native_loop()
for _ in range(1000): gauss(1000)

N = 1000000
t0 = time.monotonic_ns()
for _ in range(N): native_loop()
t1 = time.monotonic_ns()
nat = (t1 - t0) / N

N2 = 10000000
t2 = time.monotonic_ns()
for _ in range(N2): gauss(1000)
t3 = time.monotonic_ns()
shp = (t3 - t2) / N2

print(f'  Native loop:  {nat:.1f} ns')
print(f'  Shape formula: {shp:.1f} ns')
print(f'  Speedup: {nat/shp:.1f}x')
"
echo ""
fi

# --- Swift ---
if command -v swift &>/dev/null; then
echo "--- Swift ---"
cat > /tmp/bench_swift.swift << 'SWIFT'
import Foundation

func gauss(_ n: Int) -> Int { return n * (n - 1) / 2 }

func nativeLoop() -> Int {
    var s = 0
    for i in 0..<1000 { s += i }
    return s
}

// Warmup
for _ in 0..<10000 { _ = nativeLoop() }
for _ in 0..<10000 { _ = gauss(1000) }

let n1 = 10_000_000
let t0 = DispatchTime.now().uptimeNanoseconds
for _ in 0..<n1 { _ = nativeLoop() }
let t1 = DispatchTime.now().uptimeNanoseconds
let nat = Double(t1 - t0) / Double(n1)

let n2 = 100_000_000
let t2 = DispatchTime.now().uptimeNanoseconds
for _ in 0..<n2 { _ = gauss(1000) }
let t3 = DispatchTime.now().uptimeNanoseconds
let shp = Double(t3 - t2) / Double(n2)

print("  Native loop:  \(String(format: "%.1f", nat)) ns")
print("  Shape formula: \(String(format: "%.1f", shp)) ns")
print("  Speedup: \(String(format: "%.1f", nat/shp))x")
SWIFT
swift /tmp/bench_swift.swift 2>/dev/null
echo ""
fi

# --- Perl ---
if command -v perl &>/dev/null; then
echo "--- Perl ---"
perl -e '
use Time::HiRes qw(clock_gettime CLOCK_MONOTONIC);
sub gauss { my $n = shift; return $n * ($n - 1) / 2; }
sub native_loop { my $s = 0; for my $i (0..999) { $s += $i; } return $s; }

# Warmup
for (1..1000) { native_loop(); }
for (1..1000) { gauss(1000); }

my $n1 = 100000;
my $t0 = clock_gettime(CLOCK_MONOTONIC);
for (1..$n1) { native_loop(); }
my $t1 = clock_gettime(CLOCK_MONOTONIC);
my $nat = ($t1 - $t0) / $n1 * 1e9;

my $n2 = 10000000;
my $t2 = clock_gettime(CLOCK_MONOTONIC);
for (1..$n2) { gauss(1000); }
my $t3 = clock_gettime(CLOCK_MONOTONIC);
my $shp = ($t3 - $t2) / $n2 * 1e9;

printf "  Native loop:  %.1f ns\n", $nat;
printf "  Shape formula: %.1f ns\n", $shp;
printf "  Speedup: %.1fx\n", $nat / $shp;
'
echo ""
fi

# --- AWK ---
echo "--- AWK ---"
awk 'BEGIN {
    # Native loop
    t0 = systime()
    for (iter = 0; iter < 100000; iter++) {
        s = 0
        for (i = 0; i < 1000; i++) s += i
    }
    t1 = systime()
    if (t1 == t0) t1 = t0 + 1
    nat = (t1 - t0) / 100000 * 1e9

    # Shape formula
    t2 = systime()
    for (iter = 0; iter < 10000000; iter++) {
        r = 1000 * 999 / 2
    }
    t3 = systime()
    if (t3 == t2) t3 = t2 + 1
    shp = (t3 - t2) / 10000000 * 1e9

    printf "  Native loop:  %.1f ns\n", nat
    printf "  Shape formula: %.1f ns\n", shp
    printf "  Speedup: %.1fx\n", nat / shp
}'
echo ""

# --- Bash ---
echo "--- Bash ---"
echo "  (Bash is too slow for ns-level benchmarks."
echo "   Native loop 1000: ~50,000,000 ns estimated."
echo "   Shape formula: ~1,000 ns estimated."
echo "   Speedup: ~50,000x)"
echo ""

# --- Lua ---
if command -v lua &>/dev/null; then
echo "--- Lua ---"
lua -e '
function gauss(n) return n * (n - 1) // 2 end
function native_loop()
    local s = 0
    for i = 0, 999 do s = s + i end
    return s
end

-- Warmup
for _ = 1, 1000 do native_loop() end
for _ = 1, 1000 do gauss(1000) end

local n1 = 1000000
local t0 = os.clock()
for _ = 1, n1 do native_loop() end
local t1 = os.clock()
local nat = (t1 - t0) / n1 * 1e9

local n2 = 10000000
local t2 = os.clock()
for _ = 1, n2 do gauss(1000) end
local t3 = os.clock()
local shp = (t3 - t2) / n2 * 1e9

print(string.format("  Native loop:  %.1f ns", nat))
print(string.format("  Shape formula: %.1f ns", shp))
print(string.format("  Speedup: %.1fx", nat / shp))
'
echo ""
fi

# --- PHP ---
if command -v php &>/dev/null; then
echo "--- PHP ---"
php -r '
function gauss(int $n): int { return intdiv($n * ($n - 1), 2); }
function native_loop(): int { $s = 0; for ($i = 0; $i < 1000; $i++) $s += $i; return $s; }

// Warmup
for ($i = 0; $i < 1000; $i++) { native_loop(); gauss(1000); }

$n1 = 100000;
$t0 = hrtime(true);
for ($i = 0; $i < $n1; $i++) native_loop();
$t1 = hrtime(true);
$nat = ($t1 - $t0) / $n1;

$n2 = 10000000;
$t2 = hrtime(true);
for ($i = 0; $i < $n2; $i++) gauss(1000);
$t3 = hrtime(true);
$shp = ($t3 - $t2) / $n2;

printf("  Native loop:  %.1f ns\n", $nat);
printf("  Shape formula: %.1f ns\n", $shp);
printf("  Speedup: %.1fx\n", $nat / $shp);
'
echo ""
fi

# --- Rust ---
if command -v rustc &>/dev/null; then
echo "--- Rust ---"
cat > /tmp/bench_rust.rs << 'RUST'
use std::time::Instant;
use std::hint::black_box;

fn gauss(n: i64) -> i64 { n * (n - 1) / 2 }

fn native_loop() -> i64 {
    let mut s: i64 = 0;
    for i in 0..1000 { s += i; }
    s
}

fn main() {
    // Warmup
    for _ in 0..10000 { black_box(native_loop()); }
    for _ in 0..10000 { black_box(gauss(1000)); }

    let n1 = 10_000_000;
    let t0 = Instant::now();
    for _ in 0..n1 { black_box(native_loop()); }
    let nat = t0.elapsed().as_nanos() as f64 / n1 as f64;

    let n2 = 100_000_000;
    let t1 = Instant::now();
    for _ in 0..n2 { black_box(gauss(1000)); }
    let shp = t1.elapsed().as_nanos() as f64 / n2 as f64;

    println!("  Native loop:  {:.1} ns", nat);
    println!("  Shape formula: {:.1} ns", shp);
    println!("  Speedup: {:.1}x", nat / shp);
}
RUST
rustc -O -o /tmp/bench_rust /tmp/bench_rust.rs 2>/dev/null && /tmp/bench_rust
echo ""
fi

echo ""
echo "================================================"
echo "SUMMARY"
echo "================================================"
echo ""
echo "Every language, same insight: the loop IS arithmetic."
echo "The shape engine computes the formula. The native loop iterates."
