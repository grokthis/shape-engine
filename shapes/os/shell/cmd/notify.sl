shape os.shell.cmd.notify : os.shell {
  type: exec
  layer: 4
  """
if arg0 == "" {
  let items = children("os.notify.queue")
  if len(items) == 0 {
    print("No notifications.")
  } else {
    print("Notifications (" + to_string(len(items)) + "):")
    for n in items {
      let full = "os.notify.queue." + n
      let c = content(full)
      if c != "" {
        print("  " + c)
      }
    }
  }
} else if arg0 == "clear" {
  let items = children("os.notify.queue")
  for n in items {
    set_content("os.notify.queue." + n, "")
  }
  print("Notifications cleared.")
} else {
  let msg = arg0
  let t = global_tick()
  let id = "os.notify.queue." + to_string(t)
  add_shape(id, "notification", msg, 4)
  add_dep(id, "os.notify.queue")
  print("Sent: " + msg)
}
"""
}
