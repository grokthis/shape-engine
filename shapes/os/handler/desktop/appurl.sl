shape os.handler.desktop.appurl {
  type: handler
  layer: 4
  """
let name = path_name
let url = content("os.config.app." + name + ".route")
if url == "" {
  if name == "shell" {
    set url = "/terminal"
  } else if name == "browser" {
    set url = "/"
  } else {
    set url = "/desktop/app/" + name
  }
}
print("{\"url\":\"" + url + "\"}")
"""
}
