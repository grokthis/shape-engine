shape os.handler.desktop.window.create {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let ws = map_get(data, "workspace")
let app = map_get(data, "app")
if ws == "" {
  set ws = "1"
}
if app == "" {
  set app = "shell"
}

// Count existing windows to generate ID
let all = shapes_under("os.desktop.window.")
let n = len(all) + 1
let win_id = "os.desktop.window." + n

// Create window shape
add_shape(win_id, "window", "")
set_dim(win_id, "app", app)

// For document app: create a session document shape for this window.
// Each document window gets its own blank document, auto-persisted.
if app == "document" {
  let doc_id = "os.session.doc." + n
  add_shape(doc_id, "document", "[]")
  set_dim(doc_id, "name", "Untitled")
  set_dim(win_id, "doc_id", doc_id)
}

// Add to workspace deps
let ws_id = "os.desktop.workspace." + ws
if exists(ws_id) {
  add_dep(ws_id, win_id)
}

let result = map_new()
set result = map_set(result, "id", win_id)
print(json_encode(result))
"""
}
shape os.route.desktop.window.create {
  type: route
  method: POST
  path: /desktop/window
  handler: os.handler.desktop.window.create
  content_type: application/json
  layer: 4
  ""
}
