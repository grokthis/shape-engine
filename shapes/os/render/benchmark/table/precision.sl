shape os.render.benchmark.table.precision : os.render.benchmark.section.precision {
  type: table
  layer: 4
  columns: "Operation, Latency, Notes"
  """
Integer add, 58 ns, 4x native int overhead
Integer mul, 59 ns, Exact arbitrary width
Exact division (100/5), 49 ns, = 20 no truncation
Rational division (1/3), 274 ns, Stays exact not 0.333...
pow(2 1000), 251 ns, 302-digit number
2^500 * 3^300, 111 ns, Arbitrary width multiply
7 * (1/7), = 1 exactly, float64 fails this test
  """
}
