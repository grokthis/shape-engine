shape os.container.benchmark : os.container, os.time {
  type: system
  layer: 4
  """
// container benchmark <suite> [flags]
//
// Run well-known industry benchmarks inside containers.
// Each benchmark runs in its own container with a defined stack.
// Results are compared against published reference values.
//
// Suites:
//   container benchmark all           Run everything
//   container benchmark compute       CPU/memory benchmarks
//   container benchmark io            Disk/network benchmarks
//   container benchmark language      Language shootout
//   container benchmark system        Full system benchmarks
//   container benchmark dilation      Time dilation experiment
//
// Every benchmark is timed at the host level (wall clock)
// AND at the container level (ticks). The ratio IS the time
// dilation factor for that container's computation stack.
  """
}
