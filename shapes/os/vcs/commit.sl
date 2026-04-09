shape os.shell.cmd.commit {
  type: exec
  layer: 4
  """
// commit <message>
// Records a commit shape with signature, parent chain, and message.
// The commit message is also the first comment on the commit.

let msg = args
if msg == "" {
  print("usage: commit <message>")
} else {
  let who = actor()
  if who == "" {
    print("error: not logged in (no actor set)")
  } else {
    let ns = actor_ns()

    // Find parent: most recent commit on this branch.
    let parent = ""
    let commits = shapes_under("os.vcs.commit")
    for c in commits {
      let c_branch = dim(c, "branch")
      if c_branch == ns {
        if parent == "" {
          set parent = c
        } else {
          if tick(c) > tick(parent) {
            set parent = c
          }
        }
      }
    }

    // Compute signature of the working namespace.
    let sig = signature(ns)
    let t = global_tick()
    let commit_id = "os.vcs.commit." + t

    // Create the commit shape.
    add_shape(commit_id, msg)
    set_dim(commit_id, "type", "commit")
    set_dim(commit_id, "branch", ns)
    set_dim(commit_id, "author", who)
    set_dim(commit_id, "parent", parent)
    set_dim(commit_id, "signature", sig)
    set_dim(commit_id, "commit_tick", to_string(t))
    set_dim(commit_id, "layer", "3")

    // The commit message is also the first comment.
    let comment_id = "os.vcs.comment." + t
    add_shape(comment_id, msg)
    set_dim(comment_id, "type", "comment")
    set_dim(comment_id, "target", commit_id)
    set_dim(comment_id, "author", who)
    set_dim(comment_id, "comment_tick", to_string(t))
    set_dim(comment_id, "layer", "3")

    let short = substring(sig, 0, 8)
    print("[" + short + "] " + msg)
    if parent != "" {
      print("  parent: " + parent)
    }
    print("  branch: " + ns)
    print("  shapes: " + len(shapes_under(ns)))
  }
}
"""
}
