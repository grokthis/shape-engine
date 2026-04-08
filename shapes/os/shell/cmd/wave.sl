shape os.shell.cmd.wave {
  type: exec
  layer: 4
  """
fn wave_walk(id, depth, visited) {
  let dt = dependents(id)
  for dep in dt {
    if !(dep in visited) {
      let indent = repeat("  ", depth)
      let fn_name = dim(dep, "fn")
      let label = if_val(fn_name != "", " [" + fn_name + "]", "")
      print(indent + "-> " + dep + label)
      set visited = append(visited, dep)
      wave_walk(dep, depth + 1, visited)
    }
  }
  absorb
}

if arg0 == "" {
  print("wave: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  print("Wave from " + id + ":")
  let visited = [id]
  wave_walk(id, 1, visited)
}
"""
}
