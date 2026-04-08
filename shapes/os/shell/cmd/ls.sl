shape os.shell.cmd.ls {
  type: exec
  layer: 4
  """
let target = default(arg0, prefix)
if arg0 != "" {
  set target = resolve(prefix, arg0)
}
let segs = sort_list(children(target))
let w = max_len(segs) + 2
if w < 16 {
  set w = 16
}
let hdr = content("os.config.headers")
if hdr != "off" {
  print(pad_right("NAME", w) + pad_right("TYPE", 10) + "LAYER")
  print(repeat("-", w + 16))
}
for seg in segs {
  let full = if_val(target == "", seg, target + "." + seg)
  let t = dim(full, "type")
  let sub = children(full)
  if t != "" {
    let line = pad_right(seg, w) + pad_right(t, 10)
    let l = layer(full)
    if l > 0 {
      set line = line + l
    }
    print(line)
  } else if len(sub) > 0 {
    print(pad_right(seg + "/", w) + "(" + len(sub) + " children)")
  } else {
    print(seg)
  }
}
"""
}
