shape os.render.benchmark.section.physics : os.render.benchmark {
  type: section
  layer: 4
  order: 8
  title: "The Physics"
  "The mixing angle framework makes time dilation precise."
}

shape os.render.benchmark.section.physics.turing : os.render.benchmark.section.physics {
  type: column
  layer: 4
  order: 0
  title: "theta = 0: Turing machine"
  "All structure is destination (iteration space). The computation traverses every point. O(n). No recognition. Maximum ticks."
}

shape os.render.benchmark.section.physics.shape : os.render.benchmark.section.physics {
  type: column
  layer: 4
  order: 1
  title: "theta -> pi/2: Shape machine"
  "All structure is source (the formula). No destination to traverse. O(1). Full recognition. One tick."
}

shape os.render.benchmark.section.physics.tradeoff : os.render.benchmark.section.physics {
  type: paragraph
  layer: 4
  order: 2
  "Source-destination tradeoff (Theorem 9.11): at fixed persistence magnitude, more source specification (recognition) means less destination traversal (iteration). The Pythagorean conservation law holds: p^2 = c_theta^2 + s_theta^2."
}

shape os.render.benchmark.section.physics.photon : os.render.benchmark.section.physics {
  type: callout
  layer: 4
  order: 3
  "The photon and the Gauss formula are the same structural phenomenon: maximum recognition, minimum traversal, zero wasted ticks."
}
