shape os.handler.desktop.workspace {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let ws = map_get(data, "workspace")
if ws == "" {
  print("{\"error\":\"missing workspace\"}")
} else {
  if exists("os.session.desktop.workspace") {
    set_content("os.session.desktop.workspace", ws)
  } else {
    add_shape("os.session.desktop.workspace", "session", ws)
  }
  print("")
}
"""
}
