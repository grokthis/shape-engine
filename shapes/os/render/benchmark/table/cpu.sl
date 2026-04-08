shape os.render.benchmark.table.cpu : os.render.benchmark.section.cpu {
  type: table
  layer: 4
  columns: "Operation, Latency, Throughput"
  """
Register read, 14 ns, 70M/sec
Register write, 247 ns, 4.0M/sec
Memory read (1KB), 77 ns, 12.9M/sec
Memory write (1KB), 135 ns, 7.4M/sec
ALU add (full cycle), 174 ns, 5.8M/sec
ALU multiply (full cycle), 169 ns, 5.9M/sec
Single instruction (F/D/E/M/WB), 508 ns, 2.0 MIPS
5-instruction program, 1.52 us, 3.3 MIPS
100-iteration loop, 52.7 us, 1.9 MIPS
1000 instructions sustained, 272 us, 3.7 MIPS
  """
}
