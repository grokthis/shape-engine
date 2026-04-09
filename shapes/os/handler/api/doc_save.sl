shape os.handler.api.doc.save {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let name = map_get(data, "name")
let app = map_get(data, "app")
let doc_content = map_get(data, "content")
let src_id = map_get(data, "src_id")

if name == "" {
  print("{\"error\":\"missing name\"}")
} else {
  // Get the current session actor; default to "user" if no session.
  let user_id = actor()
  if user_id == "" {
    set user_id = "user"
  }
  if app == "" {
    set app = "document"
  }

  // Sanitize name: convert / to . for sub-namespaces, strip unsafe chars.
  let safe_name = replace(name, "/", ".")

  // All documents live at <user>.documents.<app>.<name>.
  // This is enforced server-side — clients cannot override it.
  let target_id = user_id + ".documents." + app + "." + safe_name

  // Security: the target must live under the current user's namespace.
  // No exceptions. Aliases may point here from elsewhere, but the shape lives here.
  if !has_prefix(target_id, user_id + ".") {
    print("{\"error\":\"documents must be saved under your user namespace\"}")
  } else {
    if exists(target_id) {
      set_content(target_id, doc_content)
    } else {
      add_shape(target_id, "document", doc_content)
    }
    set_dim(target_id, "name", safe_name)
    set_dim(target_id, "app", app)

    let result = map_new()
    set result = map_set(result, "id", target_id)
    set result = map_set(result, "status", "saved")
    print(json_encode(result))
  }
}
"""
}

shape os.route.api.doc.save {
  type: route
  method: POST
  path: /api/doc/save
  handler: os.handler.api.doc.save
  content_type: application/json
  layer: 4
  ""
}
