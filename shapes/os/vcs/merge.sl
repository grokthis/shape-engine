shape os.shell.cmd.merge {
  type: exec
  layer: 4
  """
// merge <source_branch>
// Merges shapes from source into current namespace.
// Conflicts (same suffix, different content) are Law 3 violations.

let source = arg0
if source == "" {
  print("usage: merge <source_branch>")
} else {
  let who = actor()
  if who == "" {
    print("error: not logged in")
  } else {
    let target = actor_ns()

    if source == target {
      print("error: cannot merge branch into itself")
    } else {
      let source_shapes = shapes_under(source)
      let merged = 0
      let conflicts = 0
      let skipped = 0
      let source_prefix = source + "."

      for s in source_shapes {
        let sid = to_string(s)
        let suffix = ""
        if has_prefix(sid, source_prefix) {
          set suffix = substring(sid, len(source_prefix))
        }

        if suffix != "" {
          let target_id = target + "." + suffix
          if exists(target_id) {
            let sc = content(s)
            let tc = content(target_id)
            if sc != tc {
              print("  CONFLICT " + suffix)
              set conflicts = conflicts + 1
            } else {
              set skipped = skipped + 1
            }
          } else {
            add_shape(target_id, content(s))
            let src_type = dim(s, "type")
            if src_type != "" {
              set_dim(target_id, "type", src_type)
            }
            print("  + " + suffix)
            set merged = merged + 1
          }
        }
      }

      print("")
      print(to_string(merged) + " merged, " + to_string(conflicts) + " conflicts, " + to_string(skipped) + " unchanged")
      if conflicts > 0 {
        print("Resolve conflicts manually, then commit.")
      }
    }
  }
}
"""
}
