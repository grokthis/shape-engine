shape os.shell.cmd.view {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("view: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let d = depth(id)
    let chain = ancestry(id)
    let t = dim(id, "type")
    let l = layer(id)
    let tk = tick(id)
    let dp = deps(id)
    let dt = dependents(id)
    let ch = children(id)
    let c = content(id)

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("  " + id)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("")

    let meta = ""
    if t != "" {
      set meta = meta + "[" + t + "]  "
    }
    set meta = meta + "layer " + l + "  depth " + d + "  tick " + tk
    print("  " + meta)
    print("")

    print("  Derivation:")
    let breadcrumb = ""
    let i = len(chain)
    for ancestor in chain {
      set i = i - 1
      let name = if_val(ancestor == "", "⊙", ancestor)
      set breadcrumb = breadcrumb + name + " → "
    }
    set breadcrumb = breadcrumb + id
    print("    " + breadcrumb)
    print("")

    if c != "" {
      print("  Content:")
      print("  ┌──────────────────────────────────────────────────────")
      for line in split(c, "\n") {
        print("  │ " + line)
      }
      print("  └──────────────────────────────────────────────────────")
      print("")
    }

    let dm = dims(id)
    if dm != "" {
      print("  Dimensions:")
      for line in split(dm, "\n") {
        if line != "" {
          print("    " + line)
        }
      }
      print("")
    }

    if len(dp) > 0 {
      print("  Dependencies (" + len(dp) + "):")
      for dep in dp {
        let dt2 = dim(dep, "type")
        print("    → " + dep + if_val(dt2 != "", "  " + dt2, ""))
      }
      print("")
    }

    if len(dt) > 0 {
      print("  Dependents (" + len(dt) + "):")
      for dep in dt {
        let dt2 = dim(dep, "type")
        print("    ← " + dep + if_val(dt2 != "", "  " + dt2, ""))
      }
      print("")
    }

    if len(ch) > 0 {
      print("  Children (" + len(ch) + "):")
      for seg in sort_list(ch) {
        let full = id + "." + seg
        let ct = dim(full, "type")
        print("    ◇ " + seg + if_val(ct != "", "  " + ct, ""))
      }
      print("")
    }

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  }
}
"""
}
