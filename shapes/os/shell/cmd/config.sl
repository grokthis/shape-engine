shape os.shell.cmd.config {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("Configuration (os.config.*)")
  print("")
  let segs = sort_list(children("os.config"))
  let w = max_len(segs) + 2
  if w < 12 {
    set w = 12
  }
  print(pad_right("OPTION", w) + "VALUE")
  print(repeat("-", w + 12))
  for seg in segs {
    let full = "os.config." + seg
    let val = content(full)
    print(pad_right(seg, w) + val)
  }
  print("")
  print("Usage: config <option> [value]")
} else if arg1 == "" {
  let full = "os.config." + arg0
  if !exists(full) {
    print("unknown config: " + arg0)
  } else {
    print(arg0 + " = " + content(full))
  }
} else {
  let full = "os.config." + arg0
  if !exists(full) {
    add_shape(full, "config", arg1, 4)
  } else {
    set_content(full, arg1)
  }
  print(arg0 + " = " + arg1)
}
"""
}
