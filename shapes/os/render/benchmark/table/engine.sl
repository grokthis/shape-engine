shape os.render.benchmark.table.engine : os.render.benchmark.section.engine {
  type: table
  layer: 4
  columns: "Operation, Latency, Throughput, Allocs"
  """
Shape lookup, 14.1 ns, 71M/sec, 0
Shape add, 270 ns, 3.7M/sec, 2
Shape edit, 191 ns, 5.2M/sec, 1
Edit + propagate (10 deps), 1.17 us, 855K/sec, 9
Edit + propagate (100 deps), 8.24 us, 121K/sec, 18
Edit cascade (depth 5), 432 ns, 2.3M/sec, 4
Validate (140 shapes), 741 ns, 1.3M/sec, 1
Boot 100 shapes, 33.9 us, 3.0K boots/sec, 337
  """
}
