shape os.handler.page {
  type: handler
  layer: 4
  """
let app = app_name
let title = page_title
if title == "" {
  set title = dim("os.app." + app, "name")
}
if title == "" {
  set title = "Shape OS"
}

let theme_ref = content("os.config.desktop.theme")
let theme_css = ""
if theme_ref != "" {
  set theme_css = content(theme_ref)
}
let page_css = content("os.render." + app + ".style")
let page_body = content("os.render." + app + ".body")
let page_js = content("os.render." + app + ".script")

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
if page_css != "" {
  print(page_css)
}
print("</style>")
print("</head>")
print("<body>")
if page_body != "" {
  print(page_body)
}
print("<script>")
if page_js != "" {
  print(page_js)
}
print("</script>")
print("</body>")
print("</html>")
"""
}
