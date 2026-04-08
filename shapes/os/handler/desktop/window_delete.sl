shape os.handler.desktop.window.delete {
  type: handler
  layer: 4
  """
let id = path_id
if id == "" {
  print("{\"error\":\"missing window id\"}")
} else if !exists(id) {
  print("{\"error\":\"not found\"}")
} else {
  remove(id)
  print("")
}
"""
}
