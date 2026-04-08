shape os.handler.page.desktop {
  type: handler
  layer: 5
  """
let title = "Shape OS"
if exists("os.config.window.title") {
  let t = content("os.config.window.title")
  if t != "" {
    set title = t
  }
}

let theme_ref = content("os.config.desktop.theme")
let theme_css = ""
if theme_ref != "" {
  set theme_css = content(theme_ref)
}

let wm_ref = content("os.config.desktop.wm")
if wm_ref == "" {
  set wm_ref = "os.wm.tiling"
}
let wm_css = content(wm_ref + ".style")
let wm_js = content(wm_ref + ".script")

let active_ws = "1"
if exists("os.session.desktop.workspace") {
  let ws_val = content("os.session.desktop.workspace")
  if ws_val != "" {
    set active_ws = ws_val
  }
}

print("<!DOCTYPE html>")
print("<html lang=\"en\">")
print("<head>")
print("<meta charset=\"utf-8\">")
print("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">")
print("<title>" + title + "</title>")
print("<style>")
if theme_css != "" {
  print(theme_css)
}
if wm_css != "" {
  print(wm_css)
}
print("</style>")
print("</head>")
print("<body>")

// Status bar
let sc = shape_count()
let tk = global_tick()
print("<div id=\"statusbar\">")
print("<div id=\"statusbar-left\">")

// Workspace indicators
for ws_name in ["1", "2", "3"] {
  let ws_id = "os.desktop.workspace." + ws_name
  if exists(ws_id) {
    let cls = "ws-indicator"
    if ws_name == active_ws {
      set cls = cls + " active"
    }
    print("<span class=\"" + cls + "\" data-ws=\"" + ws_name + "\">" + ws_name + "</span>")
  }
}

print("</div>")
print("<div id=\"statusbar-center\">shape://</div>")
print("<div id=\"statusbar-right\"><span>" + sc + " shapes</span><span>tick " + tk + "</span></div>")
print("</div>")

// Workspaces with windows
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

    // Get windows from workspace deps
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

        // Resolve app URL
        let app_url = content("os.config.app." + app_name + ".route")
        if app_url == "" {
          if app_name == "shell" {
            set app_url = "/terminal"
          } else if app_name == "browser" {
            set app_url = "/"
          } else {
            set app_url = "/desktop/app/" + app_name
          }
        }

        let win_style = ""
        let wl = dim(dep_id, "left")
        if wl != "" {
          set win_style = "left:" + wl + ";top:" + dim(dep_id, "top") + ";width:" + dim(dep_id, "width") + ";height:" + dim(dep_id, "height") + ";"
        }

        print("<div class=\"" + win_cls + "\" data-app=\"" + app_name + "\" data-id=\"" + dep_id + "\" style=\"" + win_style + "\">")
        print("<div class=\"window-titlebar\"><span class=\"window-title\">" + app_name + "</span>")
        print("<span class=\"window-controls\"><button class=\"win-btn close\" title=\"close\">&times;</button></span></div>")
        print("<div class=\"window-content\"><iframe src=\"" + app_url + "\" frameborder=\"0\"></iframe></div>")
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

// Launcher
print("<div id=\"launcher\" style=\"display:none\"><div class=\"launcher-backdrop\"></div><div class=\"launcher-content\">")
print("<input type=\"text\" id=\"launcher-input\" placeholder=\"Search apps...\" autofocus>")
print("<div class=\"launcher-results\">")

// List all apps
let all_shapes = shapes_under("os.app.")
for app_sh in all_shapes {
  let app_type = dim(app_sh, "type")
  if app_type == "app" {
    let app_display = dim(app_sh, "name")
    let app_key = app_sh
    if starts_with(app_key, "os.app.") {
      set app_key = substring(app_key, 7, len(app_key))
    }
    print("<div class=\"launcher-item\" data-app=\"" + app_key + "\">" + app_display + "</div>")
  }
}

print("</div></div></div>")

print("<script>")
if wm_js != "" {
  print(wm_js)
}
print("</script>")
print("</body>")
print("</html>")
"""
}
