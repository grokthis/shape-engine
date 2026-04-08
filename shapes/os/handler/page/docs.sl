shape os.handler.page.docs {
  type: handler
  layer: 5
  """
let theme_ref = content("os.config.desktop.theme")
let theme_css = ""
if theme_ref != "" {
  set theme_css = content(theme_ref)
}
let page_css = content("os.render.docs.style")
let page_js = content("os.render.docs.script")

print("<!DOCTYPE html>")
print("<html lang=\"en\">")
print("<head>")
print("<meta charset=\"utf-8\">")
print("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">")
print("<title>Shape OS Documentation</title>")
print("<style>")
if theme_css != "" {
  print(theme_css)
}
if page_css != "" {
  print(page_css)
}
print("</style>")
print("</head>")
print("<body>")

// Build sidebar from os.doc.* shapes
print("<div id=\"docs\"><div id=\"docs-sidebar\">")
print("<div class=\"sidebar-title\"><a href=\"/docs\">Documentation</a></div>")
print("<input type=\"text\" id=\"docs-search\" placeholder=\"Search...\">")

let doc_shapes = shapes_under("os.doc.")
let current_path = path_path
for d in doc_shapes {
  let doc_type = dim(d, "type")
  if doc_type == "doc" {
    let doc_name = dim(d, "name")
    if doc_name == "" {
      // Derive name from ID
      let parts = split(d, ".")
      set doc_name = at(parts, len(parts) - 1)
    }
    let topic = d
    if starts_with(topic, "os.doc.") {
      set topic = substring(topic, 7, len(topic))
    }
    let active = ""
    if topic == current_path {
      set active = " active"
    }
    print("<a class=\"sidebar-item" + active + "\" href=\"/docs/" + topic + "\">" + doc_name + "</a>")
  }
}

print("</div><div id=\"docs-main\">")

if current_path == "" {
  // Index page
  print("<h1>Shape OS Documentation</h1>")
  print("<p>Browse documentation topics in the sidebar.</p>")
} else {
  // Specific doc
  let doc_id = "os.doc." + replace(current_path, "/", ".")
  if exists(doc_id) {
    let doc_name = dim(doc_id, "name")
    if doc_name == "" {
      set doc_name = current_path
    }
    print("<h1>" + doc_name + "</h1>")
    let doc_content = content(doc_id)
    if doc_content != "" {
      print("<div class=\"doc-content\">")
      // Simple rendering: each line as a paragraph
      let lines = split(doc_content, "\n")
      for line in lines {
        if starts_with(line, "== ") {
          let heading = substring(line, 3, len(line))
          if ends_with(heading, " ==") {
            set heading = substring(heading, 0, len(heading) - 3)
          }
          print("<h2>" + trim(heading) + "</h2>")
        } else if line == "" {
          print("<br>")
        } else {
          print("<p>" + line + "</p>")
        }
      }
      print("</div>")
    }
  } else {
    print("<p>No documentation for: " + current_path + "</p>")
  }
}

print("</div></div>")

print("<script>")
if page_js != "" {
  print(page_js)
}
print("</script>")
print("</body>")
print("</html>")
"""
}
