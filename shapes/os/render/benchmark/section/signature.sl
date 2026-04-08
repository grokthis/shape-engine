shape os.render.benchmark.section.signature : os.render.benchmark {
  type: section
  layer: 4
  order: 1
  title: "The Signature Benchmark"
  """
Sum of 0 to N-1. Every native compiler produces a loop. The shape engine produces the Gauss formula: n*(n-1)/2.
  """
}

shape os.render.benchmark.section.signature.callout : os.render.benchmark.section.signature {
  type: callout
  layer: 4
  "The shape engine result is 10.7 ns regardless of N. The gap is unbounded because O(1) vs O(n) diverges."
}
