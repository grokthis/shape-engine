shape os.shell.cmd.doc {
  type: exec
  layer: 4
  """
// doc new <name> | doc append <name> paragraph <text> | doc list
let cmd = default(arg1, "list")
if cmd == "new" {
  let name = default(arg2, "untitled")
  let id = "user.doc." + name
  add_shape(id, "document", 4)
  set_dim(id, "title", name)
  set_dim(id, "page_size", "letter")
  print("Created document: " + id)
  navigate("/office/doc/" + id)
}
if cmd == "append" {
  let name = default(arg2, "untitled")
  let btype = default(arg3, "paragraph")
  let text = default(arg4, "")
  let id = "user.doc." + name
  let count = shape_count(id + ".b.*")
  let order = pad_left(to_string(count + 1), 3, "0")
  let bid = id + ".b." + order
  add_shape(bid, "block", 4)
  set_dim(bid, "block_type", btype)
  set_dim(bid, "order", order)
  let rid = bid + ".r.001"
  add_shape(rid, "run", 4)
  set_content(rid, text)
  print("Added " + btype + " to " + name)
}
if cmd == "list" {
  let docs = query user.doc.*
  for d in docs {
    if dim(d, "type") == "document" {
      print(d + " - " + dim(d, "title"))
    }
  }
}
"""
}
