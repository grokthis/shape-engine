shape os.shell.cmd.trace {
  type: exec
  layer: 4
  """
if arg0 == "" {
  // No arg: show recent trace moments
  let mc = moments()
  if mc == 0 {
    print("No trace moments recorded.")
  } else {
    let start = mc - 20
    if start < 0 {
      set start = 0
    }
    print("Trace (moments " + start + ".." + (mc - 1) + " of " + mc + "):")
    print(pad_right("IDX", 6) + pad_right("TICK", 8) + pad_right("ACTION", 10) + pad_right("TARGET", 30) + "ACTOR")
    print(repeat("-", 60))
    for i in range(start, mc) {
      let line = pad_right(to_string(i), 6)
      set line = line + pad_right(to_string(moment_tick(i)), 8)
      set line = line + pad_right(moment_action(i), 10)
      set line = line + pad_right(moment_target(i), 30)
      let a = moment_actor(i)
      if a != "" {
        set line = line + a
      }
      print(line)
    }
  }
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    // Show shape info + all moments that touched this shape
    print(id + ": layer " + layer(id) + ", tick " + tick(id))
    print("")
    let mc = moments()
    let found = 0
    for i in range(mc) {
      if moment_target(i) == id {
        let line = pad_right(to_string(i), 6)
        set line = line + pad_right(moment_action(i), 10)
        set line = line + "tick " + moment_tick(i)
        let a = moment_actor(i)
        if a != "" {
          set line = line + " by " + a
        }
        print("  " + line)
        set found = found + 1
      }
    }
    if found == 0 {
      print("  (no trace moments for this shape)")
    }
  }
}
"""
}
