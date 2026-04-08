shape os.shell.cmd.debug {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("debug: trace dependency graph and find incoherence")
  print("usage: debug <shape-id>")
  print("")
  print("Walks the dependency graph from the given shape,")
  print("checks each law, reports the first violation found.")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    print("Debug: " + id)
    print(repeat("=", len("Debug: " + id)))
    print("")

    // Shape info
    print("Layer:  " + layer(id))
    print("Tick:   " + tick(id))
    print("Depth:  " + depth(id))
    print("")

    // Check dependencies (Law 1: stable reference)
    let dp = deps(id)
    let dangling = 0
    if len(dp) > 0 {
      print("Dependencies (" + len(dp) + "):")
      for dep in dp {
        if exists(dep) {
          print("  OK  " + dep + " (tick " + tick(dep) + ")")
        } else {
          print("  BAD " + dep + " [DANGLING - Law 1 violated]")
          set dangling = dangling + 1
        }
      }
      print("")
    }

    // Check dependents (what breaks if this breaks)
    let dt = dependents(id)
    if len(dt) > 0 {
      print("Dependents (" + len(dt) + "):")
      for dep in dt {
        let t = dim(dep, "type")
        let info = dep
        if t == "test" {
          set info = info + " [TEST]"
        }
        print("  " + info)
      }
      print("")
    }

    // Check content (Law 2: conservation)
    let c = content(id)
    if c == "" {
      let ch = children(id)
      if len(ch) == 0 {
        print("Warning: shape has no content and no children (Law 2: no structure)")
      }
    }

    // Check tick freshness
    let gt = global_tick()
    let st = tick(id)
    if gt > 0 {
      let age = gt - st
      if age > 100 {
        print("Note: shape is " + age + " ticks stale (last touched at tick " + st + ", now " + gt + ")")
      }
    }

    // Summary
    if dangling > 0 {
      print("INCOHERENT: " + dangling + " dangling reference(s) (Law 1)")
    } else {
      print("Coherent: all references resolve")
    }
  }
}
"""
}
