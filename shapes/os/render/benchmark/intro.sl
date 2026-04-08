shape os.render.benchmark.intro : os.render.benchmark {
  type: section
  layer: 4
  order: 0
  """
A shape engine recognizes structure. When a loop IS a formula, the engine computes the formula instead of iterating. The loop takes O(n) ticks. The formula takes O(1) ticks. The result is identical. The number of moments is different.

This is compute time dilation: structural recognition compresses the moment sequence. The recognized computation does not experience the passage of emulated time. It takes one tick because it IS one tick.
  """
}

shape os.render.benchmark.intro.formula : os.render.benchmark.intro {
  type: formula
  layer: 4
  "p^2 = c_theta^2 + s_theta^2       sin^n(theta) = c/p       dilation = 265^depth"
}
