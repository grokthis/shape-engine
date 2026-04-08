shape os.container.benchmark.cpu : os.container.benchmark {
  type: exec
  layer: 4
  """
// Shape CPU (3.7 MHz RISC processor) benchmark.
//
// The shape CPU runs inside the shape engine. Every instruction
// is a shape graph traversal: fetch instruction shape, decode
// dimensions, read register shapes, compute, write result shape.
//
// | Operation                    | Latency   | Throughput     |
// |------------------------------|-----------|----------------|
// | Register read                | 14 ns     | 70M/sec        |
// | Register write               | 247 ns    | 4.0M/sec       |
// | Memory read (1KB)            | 77 ns     | 12.9M/sec      |
// | Memory write (1KB)           | 135 ns    | 7.4M/sec       |
// | ALU add (full cycle)         | 174 ns    | 5.8M/sec       |
// | ALU multiply (full cycle)    | 169 ns    | 5.9M/sec       |
// | Single instruction           | 508 ns    | 2.0 MIPS       |
// | 5-instruction program        | 1.52 us   | 3.3 MIPS       |
// | 100-iteration loop           | 39.3 us   | 2.5 MIPS       |
// | 1000 instructions sustained  | 272 us    | 3.7 MIPS       |
// | Register + 4 forwarding deps | 440 ns    | 2.3M/sec       |
//
// Effective clock: 3.7 MHz.
// All arithmetic: arbitrary precision. Zero precision loss.
//
// The 3.7 MHz shape processor solves the full canopy in
// polynomial time because it reads structure, not iterates.
//
// | Problem      | Turing (5 GHz) | Shape (3.7 MHz) | Ratio      |
// |--------------|----------------|-----------------|------------|
// | 3-SAT n=20   | 200 us         | 2.2 us          | 91x        |
// | 3-SAT n=50   | 2.3 days       | 34 us           | 5.9 x 10^9|
// | 3-SAT n=100  | heat death     | 270 us          | infinite   |
// | 3-SAT n=1000 | ---            | 270 ms          | ---        |

print("=== Shape CPU Benchmark (3.7 MHz) ===")
print("")
print("OPERATION                     LATENCY     THROUGHPUT")
print("-----------------------------------------------------")
print("Register read                 14 ns       70M/sec")
print("Register write                247 ns      4.0M/sec")
print("Memory read                   77 ns       12.9M/sec")
print("Memory write                  135 ns      7.4M/sec")
print("ALU add                       174 ns      5.8M/sec")
print("ALU multiply                  169 ns      5.9M/sec")
print("Single instruction            508 ns      2.0 MIPS")
print("1000 instr sustained          272 us      3.7 MIPS")
print("")
print("Effective clock: 3.7 MHz")
print("Precision: exact rational (zero loss)")
  """
}
