shape os.shell.cmd.sheet {
  type: exec
  layer: 4
  """
// sheet new <name> | sheet set <cell> <value> | sheet get <cell> | sheet list
let cmd = default(arg1, "list")
if cmd == "new" {
  let name = default(arg2, "untitled")
  let id = "user.sheet." + name
  add_shape(id, "sheet", 4)
  set_dim(id, "title", name)
  set_dim(id, "rows", "100")
  set_dim(id, "cols", "26")
  print("Created sheet: " + id)
  navigate("/office/sheet/" + id)
}
if cmd == "set" {
  let cell = default(arg2, "A1")
  let val = default(arg3, "")
  let prefix = default(env_prefix, "user.sheet.default")
  let id = prefix + "." + cell
  add_shape(id, "cell", 4)
  set_content(id, val)
  set_dim(id, "col", substr(cell, 0, 1))
  set_dim(id, "row", substr(cell, 1, 0))
  set_dim(id, "format", "general")
  print(cell + " = " + val)
}
if cmd == "get" {
  let cell = default(arg2, "A1")
  let prefix = default(env_prefix, "user.sheet.default")
  let id = prefix + "." + cell
  print(content(id))
}
if cmd == "list" {
  let sheets = query user.sheet.*
  for s in sheets {
    if dim(s, "type") == "sheet" {
      print(s + " - " + dim(s, "title"))
    }
  }
}
"""
}
