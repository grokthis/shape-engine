shape os.shell.cmd.branch {
  type: exec
  layer: 4
  """
// branch [name]
// No args: list branches. With arg: show branch info.

if arg0 == "" {
  let commits = shapes_under("os.vcs.commit")
  let branches = []

  for c in commits {
    let b = dim(c, "branch")
    if b != "" {
      if !contains(join(branches, "|"), b) {
        set branches = append(branches, b)
      }
    }
  }

  let current_ns = ""
  let who = actor()
  if who != "" {
    set current_ns = actor_ns()
  }

  if len(branches) == 0 {
    print("No branches (no commits yet).")
    if current_ns != "" {
      print("  * " + current_ns + " (" + len(shapes_under(current_ns)) + " shapes)")
    }
    print("    os (" + len(shapes_under("os")) + " shapes)")
  } else {
    for b in branches {
      let marker = "  "
      if b == current_ns {
        set marker = "* "
      }
      // Find HEAD for this branch.
      let head = ""
      for c in commits {
        if dim(c, "branch") == b {
          if head == "" {
            set head = c
          } else {
            if tick(c) > tick(head) {
              set head = c
            }
          }
        }
      }
      let sig = dim(head, "signature")
      let short = substring(sig, 0, 8)
      print(marker + b + " " + short + " " + content(head))
    }
  }
} else {
  let branch = arg0
  let head = ""
  let count = 0
  let commits = shapes_under("os.vcs.commit")
  for c in commits {
    if dim(c, "branch") == branch {
      set count = count + 1
      if head == "" {
        set head = c
      } else {
        if tick(c) > tick(head) {
          set head = c
        }
      }
    }
  }

  print("Branch: " + branch)
  print("  shapes:  " + len(shapes_under(branch)))
  print("  commits: " + count)
  if head != "" {
    print("  HEAD:    " + substring(dim(head, "signature"), 0, 8))
    print("  message: " + content(head))
  }
}
"""
}
