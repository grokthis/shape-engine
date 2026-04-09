shape os.shell.cmd.log {
  type: exec
  layer: 4
  """
// log [branch]
// Shows commit history with comments. Walks parent chain from HEAD.

let branch = arg0
if branch == "" {
  let who = actor()
  if who != "" {
    set branch = actor_ns()
  } else {
    set branch = "os"
  }
}

// Find HEAD: most recent commit on this branch.
let head = ""
let commits = shapes_under("os.vcs.commit")
for c in commits {
  if dim(c, "branch") == branch {
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
  print("No commits on branch " + branch)
} else {
  let current = head
  let count = 0
  while current != "" {
    if count > 50 {
      set current = ""
    } else {
      let sig = dim(current, "signature")
      let short = substring(sig, 0, 8)
      let a = dim(current, "author")
      let t = dim(current, "commit_tick")
      let msg = content(current)

      print(short + " (tick " + t + ") " + a)
      print("  " + msg)

      // Show additional comments (skip the commit message comment).
      let all_comments = shapes_under("os.vcs.comment")
      let extra = 0
      for cm in all_comments {
        if dim(cm, "target") == current {
          if dim(cm, "comment_tick") != t {
            let cm_author = dim(cm, "author")
            let cm_text = content(cm)
            print("    " + cm_author + ": " + cm_text)
            set extra = extra + 1
          }
        }
      }

      print("")
      set current = dim(current, "parent")
      set count = count + 1
    }
  }
}
"""
}
