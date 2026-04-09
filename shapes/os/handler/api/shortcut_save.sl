shape os.handler.api.shortcut.save {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let suffix = map_get(data, "suffix")
let new_key = map_get(data, "key")

if suffix == "" {
  print("{\"error\":\"missing suffix\"}")
} else {
  if new_key == "" {
    print("{\"error\":\"missing key\"}")
  } else {
    let user_id = actor()
    if user_id == "" {
      set user_id = "user"
    }

    let target_id = user_id + ".shortcuts." + suffix

    if !has_prefix(target_id, user_id + ".") {
      print("{\"error\":\"shortcuts must be saved under your user namespace\"}")
    } else {
      let sys_id = "os.shortcuts." + suffix
      if !exists(sys_id) {
        print("{\"error\":\"unknown shortcut\"}")
      } else {
        let sc_type = dim(sys_id, "type")
        let sc_action = dim(sys_id, "action")
        let sc_app = dim(sys_id, "app")
        let sc_category = dim(sys_id, "category")
        let sc_description = dim(sys_id, "description")

        if exists(target_id) {
          set_dim(target_id, "key", new_key)
        } else {
          add_shape(target_id, sc_type, "")
          set_dim(target_id, "type", sc_type)
          set_dim(target_id, "key", new_key)
          set_dim(target_id, "action", sc_action)
          set_dim(target_id, "app", sc_app)
          set_dim(target_id, "category", sc_category)
          set_dim(target_id, "description", sc_description)
        }

        let result = map_new()
        set result = map_set(result, "id", target_id)
        set result = map_set(result, "status", "saved")
        print(json_encode(result))
      }
    }
  }
}
"""
}

shape os.route.api.shortcut.save {
  type: route
  method: POST
  path: /api/shortcut/save
  handler: os.handler.api.shortcut.save
  content_type: application/json
  layer: 4
  ""
}

shape os.handler.api.shortcut.reset {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let suffix = map_get(data, "suffix")

if suffix == "" {
  print("{\"error\":\"missing suffix\"}")
} else {
  let user_id = actor()
  if user_id == "" {
    set user_id = "user"
  }

  let target_id = user_id + ".shortcuts." + suffix

  if exists(target_id) {
    remove(target_id)
  }

  let result = map_new()
  set result = map_set(result, "status", "reset")
  print(json_encode(result))
}
"""
}

shape os.route.api.shortcut.reset {
  type: route
  method: POST
  path: /api/shortcut/reset
  handler: os.handler.api.shortcut.reset
  content_type: application/json
  layer: 4
  ""
}
