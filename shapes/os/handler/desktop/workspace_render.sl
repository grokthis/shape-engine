shape os.handler.desktop.workspace.render {
  type: handler
  layer: 4
  """
let active_ws = "1"
if exists("os.session.desktop.workspace") {
  let ws_val = content("os.session.desktop.workspace")
  if ws_val != "" {
    set active_ws = ws_val
  }
}

print("<div id=\"workspace\">")

for ws_name in ["1", "2", "3"] {
  let ws_id = "os.desktop.workspace." + ws_name
  if !exists(ws_id) {
    // skip
  } else {
    let layout = dim(ws_id, "layout")
    if layout == "" {
      set layout = "hsplit"
    }
    let ws_cls = "workspace"
    if ws_name == active_ws {
      set ws_cls = ws_cls + " active"
    }
    print("<div class=\"" + ws_cls + "\" data-ws=\"" + ws_name + "\">")

    let ws_deps = deps(ws_id)
    let has_windows = 0
    let first_window = 1
    for dep_id in ws_deps {
      if dim(dep_id, "type") == "window" {
        if has_windows == 0 {
          print("<div class=\"split " + layout + "\">")
          set has_windows = 1
        }
        let app_name = dim(dep_id, "app")
        let focused = dim(dep_id, "focused")
        let win_cls = "window"
        if focused == "true" {
          set win_cls = win_cls + " focused"
        } else if first_window == 1 {
          set win_cls = win_cls + " focused"
        }
        set first_window = 0

        let win_style = ""
        let wl = dim(dep_id, "left")
        if wl != "" {
          set win_style = "left:" + wl + ";top:" + dim(dep_id, "top") + ";width:" + dim(dep_id, "width") + ";height:" + dim(dep_id, "height") + ";"
        }

        print("<div class=\"" + win_cls + "\" data-app=\"" + app_name + "\" data-id=\"" + dep_id + "\" style=\"" + win_style + "\">")
        print("<div class=\"window-titlebar\"><span class=\"window-title\">" + app_name + "</span>")
        print("<span class=\"window-controls\"><button class=\"win-btn close\" title=\"close\">&times;</button></span></div>")

        let render_name = dim("os.app." + app_name, "render")
        if render_name == "" {
          set render_name = app_name
        }
        print("<div class=\"window-content\" data-shape=\"os.render." + render_name + "\"></div>")

        print("</div>")
      }
    }
    if has_windows == 1 {
      print("</div>")
    }

    print("</div>")
  }
}

print("</div>")
"""
}
