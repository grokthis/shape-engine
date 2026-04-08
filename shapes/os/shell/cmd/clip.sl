shape os.shell.cmd.clip : os.shell {
  type: exec
  layer: 4
  """
if arg0 == "" {
  let val = content("os.clipboard")
  if val == "" {
    print("Clipboard empty.")
  } else {
    print(val)
  }
} else {
  if exists(arg0) {
    let val = content(arg0)
    set_content("os.clipboard", val)
    print("Copied: " + arg0)
  } else {
    set_content("os.clipboard", arg0)
    print("Clipboard: " + arg0)
  }
}
"""
}
