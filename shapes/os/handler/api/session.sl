shape os.handler.api.session.lock {
  type: handler
  layer: 4
  """
// Lock: clear the actor. OS shapes remain readable, user shapes hidden.
let prev = actor()
set_actor("")
let result = map_new()
set result = map_set(result, "status", "locked")
set result = map_set(result, "user", prev)
print(json_encode(result))
"""
}

shape os.route.api.session.lock {
  type: route
  layer: 4
  method: POST
  path: /api/session/lock
  handler: os.handler.api.session.lock
  content_type: application/json
}

shape os.handler.api.session.unlock {
  type: handler
  layer: 4
  """
// Unlock: restore the actor. Body contains {"user": "ash"}.
let data = json_decode(body)
let user_id = map_get(data, "user")
if user_id == "" {
  print("{\"error\":\"missing user\"}")
} else {
  set_actor(user_id)
  let result = map_new()
  set result = map_set(result, "status", "unlocked")
  set result = map_set(result, "user", user_id)
  print(json_encode(result))
}
"""
}

shape os.route.api.session.unlock {
  type: route
  layer: 4
  method: POST
  path: /api/session/unlock
  handler: os.handler.api.session.unlock
  content_type: application/json
}
