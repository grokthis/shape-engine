shape os.shell.cmd.edit {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("edit: need <shape-id> <content>")
} else if arg1 == "" {
  print("edit: need content after shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    set_content(id, arg1)
    print("edited: " + id)
  }
}
"""
}
