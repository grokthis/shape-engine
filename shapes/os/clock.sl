shape os.clock : os {
  type: exec
  layer: 4
  """
// clock
//
// Print the current wall-clock time from the host.
// This always reads the host's real-time clock, regardless
// of how many container layers deep you are.
//
// Also prints the shape engine's tick counter and the
// effective clock rate (ticks per wall-second).

let wall = clock()
let tick = global_tick()

print("Wall:   " + format_datetime(wall))
print("Tick:   " + tick)
print("Rate:   " + format_rate(tick, wall) + " ticks/sec")
  """
}
