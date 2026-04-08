shape os.render.benchmark.table.interpreter : os.render.benchmark.section.interpreter {
  type: table
  layer: 4
  columns: "Operation, Latency, Allocs"
  """
1 + 2, 169 ns, 1
100 * 7, 171 ns, 1
100 / 7 (exact rational), 170 ns, 1
(1+2)*3-4/2, 345 ns, 1
if x > 10 { }, 369 ns, 2
for i in range(1000), 10.7 ns, 0
String contains, 238 ns, 2
String split, 478 ns, 7
Map set+get, 1.57 us, 19
pow(2 20), 220 ns, 2
  """
}
