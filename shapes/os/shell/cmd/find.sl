shape os.shell.cmd.find {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("find: missing pattern")
} else {
  let all = shapes_under("")
  for id in sort_list(all) {
    if contains(id, arg0) {
      print(id)
    }
  }
}
"""
}
