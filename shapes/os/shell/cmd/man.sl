shape os.shell.cmd.man {
  type: exec
  layer: 4
  """
// man — manual pages from os.doc.* shapes
let topic = default(arg0, "")

if topic == "" {
  // List all doc topics.
  print("Shape OS Manual Pages")
  print("=====================")
  print("")
  let docs = children("os.doc")
  for cat in docs {
    let items = children("os.doc." + cat)
    let label = cat
    if cat == "cmd" { set label = "Commands" }
    if cat == "lang" { set label = "Shape-Lang" }
    if cat == "law" { set label = "Laws" }
    if cat == "concept" { set label = "Concepts" }
    if cat == "engine" { set label = "Engine" }
    if cat == "app" { set label = "Applications" }
    print(label + ":")
    for item in items {
      let id = "os.doc." + cat + "." + item
      let s = dim(id, "summary")
      print("  " + item + "  " + s)
    }
    print("")
  }
  print("Usage: man <topic>")
} else {
  // Look up the doc shape.
  let id = ""
  if exists("os.doc." + topic) { set id = "os.doc." + topic }
  if id == "" && exists("os.doc.cmd." + topic) { set id = "os.doc.cmd." + topic }
  if id == "" && exists("os.doc.lang." + topic) { set id = "os.doc.lang." + topic }
  if id == "" && exists("os.doc.concept." + topic) { set id = "os.doc.concept." + topic }
  if id == "" && exists("os.doc.law." + topic) { set id = "os.doc.law." + topic }
  if id == "" && exists("os.doc.engine." + topic) { set id = "os.doc.engine." + topic }
  if id == "" && exists("os.doc.app." + topic) { set id = "os.doc.app." + topic }

  if id == "" {
    print("No manual entry for: " + topic)
  } else {
    let name = topic
    let syn = dim(id, "synopsis")
    let summary = dim(id, "summary")
    let see = dim(id, "see_also")
    let body = content(id)

    print("NAME")
    print("    " + name + " - " + summary)
    print("")
    if syn != "" {
      print("SYNOPSIS")
      print("    " + syn)
      print("")
    }
    if body != "" {
      print(body)
    }
    if see != "" {
      print("")
      print("SEE ALSO")
      print("    " + see)
    }
  }
}
"""
}
