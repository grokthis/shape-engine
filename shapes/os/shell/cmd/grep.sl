shape os.shell.cmd.grep {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("grep: missing pattern")
} else {
  let target = default(arg1, prefix)
  let all = shapes_under(target)
  for id in sort_list(all) {
    let c = content(id)
    if contains(c, arg0) {
      print(id + ": " + c)
    }
  }
}
"""
}
