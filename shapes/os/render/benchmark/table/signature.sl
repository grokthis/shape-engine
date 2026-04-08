shape os.render.benchmark.table.signature : os.render.benchmark.section.signature {
  type: table
  layer: 4
  columns: "N, Native loop (Go), Shape engine, Speedup"
  """
1000, 321 ns, 10.7 ns, 30x
1000000, 321 us, 10.7 ns, 30000x
1000000000, 321 ms, 10.7 ns, 30000000x
1e18, ~10 years, 10.7 ns, ~1e16x
  """
}
