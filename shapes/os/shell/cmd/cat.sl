shape os.shell.cmd.cat {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("cat: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let c = content(id)
    let d = dims(id)
    if d != "" {
      print(d)
    }
    if c != "" {
      if d != "" {
        print("---")
      }
      print(c)
    }
  }
}
"""
}
