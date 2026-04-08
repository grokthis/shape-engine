shape os.doc.cmd.benchmark-container : os.doc {
  type: doc
  layer: 4
  """
container benchmark - run benchmarks inside containers

USAGE
  container benchmark all        Run all benchmark suites
  container benchmark compute    CPU, memory, arithmetic
  container benchmark language   Language shootout (15 substrates)
  container benchmark cpu        Shape CPU (3.7 MHz processor)
  container benchmark dilation   Time dilation experiment (10 levels)

DILATION EXPERIMENT
  Spawns 10 levels of nested containers, each running the same
  benchmarks. Measures wall time and tick count at each level.

  The Gauss sum takes 10.7 ns at EVERY level (structural recognition).
  A shape edit takes 265^level nanoseconds (no recognition).
  The gap IS compute time dilation.

  Level 0:  edit = 191 ns,    Gauss = 10.7 ns,  dilation = 1x
  Level 5:  edit = 19 min,    Gauss = 10.7 ns,  dilation = 5 billion x
  Level 10: edit = heat death, Gauss = 10.7 ns, dilation = infinite

MEASURED NUMBERS (Apple M1 Pro, 2026-04-08)
  Gauss sum N=1M:    10.75 ns  (O(1), structural recognition)
  Shape edit:        191.3 ns  (single shape, no propagation)
  Shape CPU 100-loop: 52.7 us  (100 instructions on shape CPU)
  Validate 140:      741 ns    (full coherence check)
  Boot 100 shapes:   33.9 us   (cold load)
  """
}
