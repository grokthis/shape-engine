shape os.shell.cmd.dependents {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("dependents: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  let dt = dependents(id)
  if len(dt) == 0 {
    print("(no dependents)")
  } else {
    let w = max_len(dt) + 2
    let hdr = content("os.config.headers")
    if hdr != "off" {
      print("  " + pad_right("", 5) + pad_right("DEPENDENT", w) + "TYPE")
      print("  " + repeat("-", w + 16))
    }
    for dep in dt {
      let t = dim(dep, "type")
      print("  <- " + pad_right(dep, w) + if_val(t != "", t, ""))
    }
  }
}
"""
}
