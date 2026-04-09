shape os.handler.api.login {
  type: handler
  layer: 4
  """
// Login handler. Password is a shape — its history IS the credential.
// New users: create userspace on first login.
// Body: {"user": "name", "password": "..."}

let data = json_decode(body)
let user_id = map_get(data, "user")
let password = map_get(data, "password")

if user_id == "" {
  print("{\"error\":\"missing username\"}")
} else {
  let auth_id = "os.auth.user." + user_id
  if exists(auth_id) {
    // Existing user: verify password shape.
    let stored = content(auth_id)
    if password != stored {
      print("{\"error\":\"wrong password\"}")
    } else {
      // Login: set actor, record session.
      set_actor(user_id)
      let ns = actor_ns()
      let t = global_tick()

      // Record login moment.
      let session_id = "os.session.login." + user_id
      if !exists(session_id) {
        add_shape(session_id, to_string(t))
        set_dim(session_id, "type", "session")
        set_dim(session_id, "layer", "2")
      } else {
        set_content(session_id, to_string(t))
      }

      let result = map_new()
      set result = map_set(result, "status", "ok")
      set result = map_set(result, "user", user_id)
      set result = map_set(result, "namespace", ns)
      print(json_encode(result))
    }
  } else {
    // New user: create userspace.
    // Password becomes the auth shape's content.
    // Its trace history IS the credential — every change is recorded.
    add_shape(auth_id, password)
    set_dim(auth_id, "type", "auth")
    set_dim(auth_id, "name", user_id)
    set_dim(auth_id, "layer", "3")

    // Set actor to new user.
    set_actor(user_id)
    let ns = actor_ns()

    // Record first login.
    let session_id = "os.session.login." + user_id
    add_shape(session_id, to_string(global_tick()))
    set_dim(session_id, "type", "session")
    set_dim(session_id, "layer", "2")

    let result = map_new()
    set result = map_set(result, "status", "created")
    set result = map_set(result, "user", user_id)
    set result = map_set(result, "namespace", ns)
    print(json_encode(result))
  }
}
"""
}

shape os.route.api.login {
  type: route
  layer: 4
  method: POST
  path: /api/login
  handler: os.handler.api.login
  content_type: application/json
}
