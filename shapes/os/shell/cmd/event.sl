shape os.shell.cmd.event : os.shell {
  type: exec
  layer: 4
  """
let sub = default(arg0, "list")

if sub == "list" {
  let agents = children("os.agent.registry")
  let count = 0
  for a in agents {
    if has_prefix(a, "event-") {
      let full = "os.agent.registry." + a
      let fn_val = dim(full, "fn")
      let status = if_val(fn_val == "agent.exec", "on", "off")
      print("  " + a + " [" + status + "]")
      set count = count + 1
    }
  }
  if count == 0 {
    print("No event hooks. Use 'event on <shape> <handler>' to create one.")
  }
} else if sub == "on" {
  if arg1 == "" {
    print("Usage: event on <shape> <handler-code>")
  } else {
    let target = arg1
    let handler = default(arg2, "source")
    let name = "event-" + replace(target, ".", "-")
    let agent_id = "os.agent.registry." + name
    add_shape(agent_id, "agent", "", 3)
    set_dim(agent_id, "fn", "agent.exec")
    add_dep(agent_id, "os.agent.registry")
    add_dep(agent_id, target)
    set_content(agent_id, handler)
    print("Event hook: " + name)
    print("  Watching: " + target)
  }
} else if sub == "off" {
  if arg1 == "" {
    print("Usage: event off <name>")
  } else {
    let agent_id = if_val(has_prefix(arg1, "os.agent"), arg1, "os.agent.registry." + arg1)
    set_dim(agent_id, "fn", "")
    print("Disabled: " + arg1)
  }
} else {
  print("Usage: event [on|off|list]")
}
"""
}
