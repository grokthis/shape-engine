shape os.shell.cmd.info {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("info: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    print(pad_right("ID:", 14) + id)
    print(pad_right("Tick:", 14) + tick(id))
    print(pad_right("Layer:", 14) + layer(id))
    print(pad_right("Depth:", 14) + depth(id))
    print("")
    let d = dims(id)
    if d != "" {
      print("Dimensions:")
      for line in split(d, "\n") {
        print("  " + line)
      }
    }
    let c = content(id)
    if c != "" {
      print("Content:")
      for line in split(c, "\n") {
        print("  " + line)
      }
    }
    print("")
    let hdr = content("os.config.headers")
    let dp = deps(id)
    if len(dp) > 0 {
      print("Deps:")
      let w = max_len(dp) + 2
      if hdr != "off" {
        print("  " + pad_right("ID", w) + "TYPE")
        print("  " + repeat("-", w + 10))
      }
      for dep in dp {
        let t = dim(dep, "type")
        print("  " + pad_right(dep, w) + if_val(t != "", t, ""))
      }
    }
    let dt = dependents(id)
    if len(dt) > 0 {
      print("Dependents:")
      let w = max_len(dt) + 2
      if hdr != "off" {
        print("  " + pad_right("ID", w) + "TYPE")
        print("  " + repeat("-", w + 10))
      }
      for dep in dt {
        let t = dim(dep, "type")
        print("  " + pad_right(dep, w) + if_val(t != "", t, ""))
      }
    }
  }
}
"""
}
