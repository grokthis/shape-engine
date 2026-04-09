shape os.shell.cmd.diff {
  type: exec
  layer: 4
  """
// diff [commit1] [commit2]
// Shows shapes changed between two commits.
// No args: changes since last commit on current branch.

let ns = "os"
let who = actor()
if who != "" {
  set ns = actor_ns()
}

let c1 = arg0
let c2 = arg1

if c1 == "" {
  // Find HEAD and its parent.
  let head = ""
  let commits = shapes_under("os.vcs.commit")
  for c in commits {
    if dim(c, "branch") == ns {
      if head == "" {
        set head = c
      } else {
        if tick(c) > tick(head) {
          set head = c
        }
      }
    }
  }
  if head == "" {
    print("No commits on branch " + ns)
    print("  " + len(shapes_under(ns)) + " untracked shapes")
  } else {
    // Diff HEAD against working tree.
    let last_tick = to_int(dim(head, "commit_tick"))
    let head_sig = dim(head, "signature")
    let current_sig = signature(ns)

    if head_sig == current_sig {
      print("No changes since " + substring(head_sig, 0, 8))
    } else {
      let all = shapes_under(ns)
      let changed = 0
      for s in all {
        if tick(s) > last_tick {
          print("  M " + s)
          set changed = changed + 1
        }
      }
      print("")
      print(to_string(changed) + " shapes modified")
    }
  }
} else {
  if c2 == "" {
    // One arg: diff that commit against HEAD.
    let head = ""
    let commits = shapes_under("os.vcs.commit")
    for c in commits {
      if dim(c, "branch") == ns {
        if head == "" {
          set head = c
        } else {
          if tick(c) > tick(head) {
            set head = c
          }
        }
      }
    }
    set c2 = head
  }

  if !exists(c1) {
    print("commit not found: " + c1)
  } else {
    if !exists(c2) {
      print("commit not found: " + c2)
    } else {
      let t1 = to_int(dim(c1, "commit_tick"))
      let t2 = to_int(dim(c2, "commit_tick"))
      let sig1 = dim(c1, "signature")
      let sig2 = dim(c2, "signature")

      print("diff " + substring(sig1, 0, 8) + ".." + substring(sig2, 0, 8))
      print("  ticks " + t1 + ".." + t2)
      print("")

      if sig1 == sig2 {
        print("No changes.")
      } else {
        let b = dim(c2, "branch")
        let all = shapes_under(b)
        let modified = 0
        for s in all {
          let st = tick(s)
          if st > t1 {
            if st <= t2 {
              print("  M " + s)
              set modified = modified + 1
            }
          }
        }
        print("")
        print(to_string(modified) + " shapes changed")
      }
    }
  }
}
"""
}
