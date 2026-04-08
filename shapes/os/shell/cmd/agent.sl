shape os.shell.cmd.agent : os.shell {
  type: exec
  layer: 4
  """
let sub = default(arg0, "list")

if sub == "list" {
  let agents = children("os.agent.registry")
  if len(agents) == 0 {
    print("No active agents.")
  } else {
    print("Agents (" + to_string(len(agents)) + "):")
    for a in agents {
      let full = "os.agent.registry." + a
      let fn_val = dim(full, "fn")
      let status = if_val(fn_val == "agent.exec", "active", "paused")
      print("  " + a + " [" + status + "] " + content(full))
    }
  }
} else if sub == "create" {
  if arg1 == "" {
    print("Usage: agent create <name> <dep1,dep2,...>")
  } else {
    let name = arg1
    let dep_str = default(arg2, "")
    let agent_id = "os.agent.registry." + name
    add_shape(agent_id, "agent", "", 3)
    set_dim(agent_id, "fn", "agent.exec")
    add_dep(agent_id, "os.agent.registry")
    if dep_str != "" {
      let dep_list = split(dep_str, ",")
      for d in dep_list {
        add_dep(agent_id, trim(d))
      }
    }
    set_content(agent_id, "// Agent: " + name + "\nsource")
    print("Created agent: " + agent_id)
    if dep_str != "" {
      print("  Watching: " + dep_str)
    }
  }
} else if sub == "info" {
  if arg1 == "" {
    print("Usage: agent info <id>")
  } else {
    let agent_id = if_val(has_prefix(arg1, "os.agent"), arg1, "os.agent.registry." + arg1)
    if exists(agent_id) {
      let fn_val = dim(agent_id, "fn")
      let status = if_val(fn_val == "agent.exec", "active", "paused")
      print("Agent: " + agent_id)
      print("  Status: " + status)
      print("  State: " + content(agent_id))
    } else {
      print("Agent not found: " + agent_id)
    }
  }
} else if sub == "pause" {
  if arg1 == "" {
    print("Usage: agent pause <id>")
  } else {
    let agent_id = if_val(has_prefix(arg1, "os.agent"), arg1, "os.agent.registry." + arg1)
    set_dim(agent_id, "fn", "")
    print("Paused: " + agent_id)
  }
} else if sub == "resume" {
  if arg1 == "" {
    print("Usage: agent resume <id>")
  } else {
    let agent_id = if_val(has_prefix(arg1, "os.agent"), arg1, "os.agent.registry." + arg1)
    set_dim(agent_id, "fn", "agent.exec")
    print("Resumed: " + agent_id)
  }
} else if sub == "log" {
  if arg1 == "" {
    print("Usage: agent log <id>")
  } else {
    let agent_id = if_val(has_prefix(arg1, "os.agent"), arg1, "os.agent.registry." + arg1)
    if exists(agent_id) {
      print(content(agent_id))
    } else {
      print("Agent not found: " + agent_id)
    }
  }
} else if sub == "remove" {
  if arg1 == "" {
    print("Usage: agent remove <id>")
  } else {
    let agent_id = if_val(has_prefix(arg1, "os.agent"), arg1, "os.agent.registry." + arg1)
    set_dim(agent_id, "fn", "")
    set_content(agent_id, "")
    print("Removed: " + agent_id)
  }
} else {
  print("Usage: agent [list|create|info|pause|resume|log|remove]")
}
"""
}
