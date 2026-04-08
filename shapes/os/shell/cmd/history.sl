shape os.shell.cmd.history {
  type: exec
  layer: 4
  """
let h = content("os.session.shell.history")
if h == "" {
  print("(no history)")
} else {
  let lines = split(h, "\n")
  let i = 0
  let total = len(lines)
  let w = len(to_string(total))
  if w < 3 {
    set w = 3
  }
  let hdr = content("os.config.headers")
  if hdr != "off" {
    print(pad_left("#", w) + "  COMMAND")
    print(repeat("-", w + 30))
  }
  for line in lines {
    if line != "" {
      set i = i + 1
      print(pad_left(to_string(i), w) + "  " + line)
    }
  }
}
"""
}
