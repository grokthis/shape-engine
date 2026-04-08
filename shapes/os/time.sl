shape os.time : os {
  type: exec
  layer: 4
  """
// time <command> [args...]
//
// Run a command and report wall-clock time, CPU cycles, and
// shape ticks consumed.
//
// Output:
//   <command output>
//
//   real    0.034s      Wall clock (host time)
//   ticks   1247        Shape engine ticks consumed
//   cycles  4619        CPU cycles (if in a container stack)
//   ratio   1.00        Time dilation (ticks/real vs base rate)
//
// The wall clock comes from the host process via syscall 9
// (clock_gettime). This punches through all container layers
// to the base. The shape tick counter is local to whatever
// layer you're on.
//
// Time dilation = (ticks consumed) / (ticks expected at base rate).
// ratio > 1: this layer is experiencing dilated time (slower).
// ratio < 1: structural recognition collapsed computation.
// ratio = 1: running at base rate (no overhead, no collapse).

let t0_wall = clock()
let t0_tick = global_tick()

// Run the command
// (dispatch to os.shell.cmd.<command>)

let t1_wall = clock()
let t1_tick = global_tick()

let elapsed_wall = t1_wall - t0_wall
let elapsed_ticks = t1_tick - t0_tick

print("")
print("real    " + format_time(elapsed_wall))
print("ticks   " + elapsed_ticks)
print("ratio   " + format_ratio(elapsed_ticks, elapsed_wall))
  """
}
