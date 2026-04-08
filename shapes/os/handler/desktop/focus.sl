shape os.handler.desktop.focus {
  type: handler
  layer: 4
  """
let data = json_decode(body)
let target = map_get(data, "id")
if target == "" {
  print("{\"error\":\"missing id\"}")
} else {
  // Clear focus on all windows, set on target
  let all = shapes_under("os.desktop.window.")
  for w in all {
    if dim(w, "type") == "window" {
      if dim(w, "focused") == "true" {
        if w != target {
          set_dim(w, "focused", "")
        }
      }
    }
  }
  if exists(target) {
    set_dim(target, "focused", "true")
  }
  print("")
}
"""
}
