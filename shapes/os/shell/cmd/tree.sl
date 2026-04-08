shape os.shell.cmd.tree {
  type: exec
  layer: 4
  """
fn tree_walk(pfx, depth, col) {
  let segs = sort_list(children(pfx))
  for seg in segs {
    let full = if_val(pfx == "", seg, pfx + "." + seg)
    let indent = repeat("  ", depth)
    let t = dim(full, "type")
    let marker = if_val(exists(full), "◇ ", "▸ ")
    let name = indent + marker + seg
    if t != "" {
      print(pad_right(name, col) + t)
    } else {
      print(name + "/")
    }
    tree_walk(full, depth + 1, col)
  }
  absorb
}
let target = default(arg0, prefix)
if arg0 != "" {
  set target = resolve(prefix, arg0)
}
tree_walk(target, 0, 32)
"""
}
