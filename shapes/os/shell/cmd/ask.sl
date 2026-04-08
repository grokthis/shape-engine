shape os.shell.cmd.ask : os.shell {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("Usage: ask <question>")
  print("       ask status          Show current/last task")
  print("       ask steps <id>      Show steps for a task")
  print("")
  print("The LLM agent constructs shapes to fulfill your request.")
  print("Each step emits shape-lang that gets evaluated against the engine.")
} else if arg0 == "status" {
  // Show current or last task.
  let tasks = shapes_under("os.agent.llm.task")
  if len(tasks) == 0 {
    print("No tasks yet.")
  } else {
    // Find most recent task.
    let last = ""
    for t in tasks {
      if dim(t, "type") == "agent-task" {
        set last = t
      }
    }
    if last != "" {
      let status = dim(last, "status")
      let goal = dim(last, "goal")
      let step = dim(last, "step")
      print("Task: " + last)
      print("  Goal:   " + goal)
      print("  Status: " + status)
      print("  Steps:  " + step)
    }
  }
} else if arg0 == "steps" {
  if arg1 == "" {
    print("Usage: ask steps <task-id>")
  } else {
    let steps = shapes_under(arg1 + ".step")
    if len(steps) == 0 {
      print("No steps found for " + arg1)
    } else {
      for s in steps {
        let n = dim(s, "step")
        print("--- Step " + n + " ---")
        print(content(s))
        print("")
      }
    }
  }
} else {
  // Create task and run agent loop.
  if llm_ready() != "true" {
    print("LLM not configured. Set ANTHROPIC_API_KEY environment variable.")
  } else {
    let goal = arg0
    // Append remaining args to goal.
    if arg1 != "" {
      set goal = goal + " " + arg1
    }
    if arg2 != "" {
      set goal = goal + " " + arg2
    }
    if arg3 != "" {
      set goal = goal + " " + arg3
    }
    if arg4 != "" {
      set goal = goal + " " + arg4
    }

    // Create task shape.
    let tick = global_tick()
    let task_id = "os.agent.llm.task." + to_string(tick)
    add_shape(task_id, "agent-task", "", 4)
    set_dim(task_id, "goal", goal)
    set_dim(task_id, "status", "running")
    set_dim(task_id, "step", "0")

    // Build initial context.
    let shape_count = to_string(shape_count())
    let ctx = "Task ID: " + task_id + "\n"
    set ctx = ctx + "Goal: " + goal + "\n"
    set ctx = ctx + "Engine: " + shape_count + " shapes, tick " + to_string(global_tick()) + "\n"
    set ctx = ctx + "Begin. This is step 1."
    set_content(task_id, ctx)

    print("Agent task: " + task_id)
    print("Goal: " + goal)
    print("")

    // Read max steps from config.
    let max_steps = 10
    let max_cfg = content("os.agent.llm.config")
    if max_cfg != "" {
      let ms = dim("os.agent.llm.config", "max_steps")
      if ms != "" {
        set max_steps = to_int(ms)
      }
    }

    // Agent loop: call LLM, evaluate, check status, repeat.
    let step = 0
    let running = true
    for i in range(max_steps) {
      if running == true {
        set step = step + 1
        print("--- Step " + to_string(step) + " ---")

        // Run one step.
        let result = llm_step(task_id)
        print(result)

        // Check if task is complete.
        let status = dim(task_id, "status")
        if status == "complete" {
          set running = false
          print("")
          print("Task complete.")
        } else if status == "blocked" {
          set running = false
          print("")
          print("Task blocked. Use 'ask status' to see details.")
        }
      }
    }

    if running == true {
      set_dim(task_id, "status", "max-steps")
      print("")
      print("Reached max steps (" + to_string(max_steps) + "). Use 'ask status' to see state.")
    }
  }
}
"""
}
