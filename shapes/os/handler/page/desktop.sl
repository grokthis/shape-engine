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
  set theme_css = render(theme_ref)
}

let wm_ref = content("os.config.desktop.wm")
if wm_ref == "" {
  set wm_ref = "os.wm.tiling"
}
let wm_css = render(wm_ref + ".style")
let wm_js = render(wm_ref + ".script")

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

        // Resolve render prefix: app may specify a different render name.
        let render_name = dim("os.app." + app_name, "render")
        if render_name == "" {
          set render_name = app_name
        }
        // Render app content structurally from its render shapes.
        let app_style = render("os.render." + render_name + ".style")
        let app_body = render("os.render." + render_name + ".body")
        let app_script = render("os.render." + render_name + ".script")
        print("<div class=\"window-content\">")
        if app_style != "" {
          print("<style>" + app_style + "</style>")
        }
        if app_body != "" {
          print(app_body)
        }
        if app_script != "" {
          print("<script>" + app_script + "</script>")
        }
        print("</div>")

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

// Pinned apps (always shown at top)
let pins_str = content("os.config.launcher.pins")
if pins_str != "" {
  print("<div class=\"launcher-section\"><div class=\"launcher-section-title\">Pinned</div><div class=\"launcher-grid\">")
  let pins = split(pins_str, ",")
  for pin in pins {
    let app_id = "os.app." + trim(pin)
    if exists(app_id) {
      let pname = dim(app_id, "name")
      let picon = dim(app_id, "icon")
      if picon == "" { set picon = substring(pname, 0, 2) }
      print("<div class=\"launcher-item pinned\" data-app=\"" + trim(pin) + "\"><span class=\"launcher-icon\">" + picon + "</span><span class=\"launcher-name\">" + pname + "</span></div>")
    }
  }
  print("</div></div>")
}

// Favorites
let favs_str = content("os.config.launcher.favorites")
if favs_str != "" {
  print("<div class=\"launcher-section\"><div class=\"launcher-section-title\">Favorites</div><div class=\"launcher-grid\">")
  let favs = split(favs_str, ",")
  for fav in favs {
    let app_id = "os.app." + trim(fav)
    if exists(app_id) {
      let fname = dim(app_id, "name")
      let ficon = dim(app_id, "icon")
      if ficon == "" { set ficon = substring(fname, 0, 2) }
      print("<div class=\"launcher-item\" data-app=\"" + trim(fav) + "\"><span class=\"launcher-icon\">" + ficon + "</span><span class=\"launcher-name\">" + fname + "</span></div>")
    }
  }
  print("</div></div>")
}

// Recents
let recents_str = content("os.config.launcher.recents")
if recents_str != "" {
  print("<div class=\"launcher-section\"><div class=\"launcher-section-title\">Recent</div><div class=\"launcher-grid\">")
  let recents = split(recents_str, ",")
  for rec in recents {
    let app_id = "os.app." + trim(rec)
    if exists(app_id) {
      let rname = dim(app_id, "name")
      let ricon = dim(app_id, "icon")
      if ricon == "" { set ricon = substring(rname, 0, 2) }
      print("<div class=\"launcher-item\" data-app=\"" + trim(rec) + "\"><span class=\"launcher-icon\">" + ricon + "</span><span class=\"launcher-name\">" + rname + "</span></div>")
    }
  }
  print("</div></div>")
}

// All apps by category
print("<div class=\"launcher-section\"><div class=\"launcher-section-title\">All Apps</div><div class=\"launcher-grid\">")
let all_shapes = shapes_under("os.app.")
for app_sh in sort_list(all_shapes) {
  let app_type = dim(app_sh, "type")
  if app_type == "app" {
    let app_display = dim(app_sh, "name")
    let app_icon = dim(app_sh, "icon")
    let app_cat = dim(app_sh, "category")
    if app_icon == "" { set app_icon = substring(app_display, 0, 2) }
    let app_key = app_sh
    if starts_with(app_key, "os.app.") {
      set app_key = substring(app_key, 7, len(app_key))
    }
    print("<div class=\"launcher-item\" data-app=\"" + app_key + "\" data-category=\"" + app_cat + "\"><span class=\"launcher-icon\">" + app_icon + "</span><span class=\"launcher-name\">" + app_display + "</span></div>")
  }
}
print("</div></div>")

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
