shape os.vcs.comment : os.vcs {
  type: system
  layer: 3
  """
// Comments are shapes. A comment references a target shape.
// Commit messages are comments on commit shapes.
// Anyone can comment on anything they can read.
//
// Shape structure:
//   os.vcs.comment.<tick> {
//     type: comment
//     target: <shape_id>
//     author: <actor>
//     parent: <comment_id>   (for threading)
//     "The comment text."
//   }
  """
}

shape os.shell.cmd.comment {
  type: exec
  layer: 4
  """
// comment <target> <text>
// Add a comment on any shape (including commits).

if arg0 == "" {
  print("usage: comment <shape_id> <text>")
  print("       comment <shape_id>          (show comments)")
} else {
  let target = arg0
  if !exists(target) {
    print("shape not found: " + target)
  } else {
    // Check if there's text after the target.
    let parts = split(args, " ")
    if len(parts) < 2 {
      // No text: show comments on this target.
      let all = shapes_under("os.vcs.comment")
      let found = 0
      for c in all {
        if dim(c, "target") == target {
          let author = dim(c, "author")
          let t = dim(c, "comment_tick")
          let text = content(c)
          print(author + " (tick " + t + "):")
          print("  " + text)
          print("")
          set found = found + 1
        }
      }
      if found == 0 {
        print("No comments on " + target)
      }
    } else {
      // Add comment.
      let who = actor()
      if who == "" {
        print("error: not logged in")
      } else {
        let text = ""
        for i in range(1, len(parts)) {
          if i > 1 {
            set text = text + " "
          }
          set text = text + parts[i]
        }

        let t = global_tick()
        let comment_id = "os.vcs.comment." + t
        add_shape(comment_id, text)
        set_dim(comment_id, "type", "comment")
        set_dim(comment_id, "target", target)
        set_dim(comment_id, "author", who)
        set_dim(comment_id, "comment_tick", to_string(t))
        set_dim(comment_id, "layer", "3")

        print("Comment added on " + target)
      }
    }
  }
}
"""
}

shape os.shell.cmd.comments {
  type: exec
  layer: 4
  """
// comments [shape_id]
// Show all comments. With arg, show comments on that shape.

if arg0 == "" {
  // Show recent comments.
  let all = shapes_under("os.vcs.comment")
  if len(all) == 0 {
    print("No comments.")
  } else {
    for c in all {
      if dim(c, "type") == "comment" {
        let target = dim(c, "target")
        let author = dim(c, "author")
        let text = content(c)
        print(author + " on " + target + ": " + text)
      }
    }
  }
} else {
  let target = arg0
  let all = shapes_under("os.vcs.comment")
  let found = 0
  for c in all {
    if dim(c, "target") == target {
      let author = dim(c, "author")
      let t = dim(c, "comment_tick")
      let text = content(c)
      print(author + " (tick " + t + "):")
      print("  " + text)
      print("")
      set found = found + 1
    }
  }
  if found == 0 {
    print("No comments on " + target)
  }
}
"""
}
