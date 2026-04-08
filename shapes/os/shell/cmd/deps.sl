shape os.shell.cmd.deps {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("deps: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  let dp = deps(id)
  if len(dp) == 0 {
    print("(no dependencies)")
  } else {
    let w = max_len(dp) + 2
    let hdr = content("os.config.headers")
    if hdr != "off" {
      print("  " + pad_right("", 5) + pad_right("DEP", w) + "TYPE")
      print("  " + repeat("-", w + 16))
    }
    for dep in dp {
      let t = dim(dep, "type")
      print("  -> " + pad_right(dep, w) + if_val(t != "", t, ""))
    }
  }
}
"""
}
