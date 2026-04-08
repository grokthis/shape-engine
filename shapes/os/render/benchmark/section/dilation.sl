shape os.render.benchmark.section.dilation : os.render.benchmark {
  type: section
  layer: 4
  order: 7
  title: "Time Dilation Experiment"
  """
10 levels of nested shape engine containers. At each level, run the Gauss sum (structurally recognized, O(1)) and a shape edit (unrecognized, O(n)). Measure wall time at each level. Overhead per layer: 265x (measured).
  """
}

shape os.render.benchmark.section.dilation.callout : os.render.benchmark.section.dilation {
  type: callout
  layer: 4
  """
The Gauss column is 10.7 ns at every level. The edit column is 265^n ns. At level 10, one edit takes 39.5 million years. One Gauss sum takes 10.7 nanoseconds. Same machine. Same clock. Different number of moments.
  """
}
