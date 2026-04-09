shape os.shell.cmd.version {
  type: exec
  layer: 4
  """
// version [command] [args...]
// Shape version control CLI.
//
//   version                  Current state
//   version commit <msg>     Record a commit
//   version log              Commit history
//   version diff             Changes since last commit
//   version branch [name]    List/inspect branches
//   version merge <branch>   Merge another branch
//   version push             Promote to local tier
//   version pull             Pull from local tier
//   version tag <name>       Tag current commit
//   version signature        Structural signature
//   version verify           Verify branch integrity
//   version comment <id> <text>  Comment on any shape

// Helper: find HEAD commit for a branch.
// Returns "" if no commits.
fn find_head(ns) {
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
  auto head
}

if arg0 == "" {
  // Default: show current state.
  let who = actor()
  if who == "" {
    print("shape-vcs (not logged in)")
  } else {
    let ns = actor_ns()
    let head = find_head(ns)
    let sig = signature(ns)
    let shape_count = len(shapes_under(ns))

    // Count commits.
    let commit_count = 0
    let commits = shapes_under("os.vcs.commit")
    for c in commits {
      if dim(c, "branch") == ns {
        set commit_count = commit_count + 1
      }
    }

    print("shape-vcs on " + ns)
    print("")
    print("  signature: " + substring(sig, 0, 16) + "...")
    print("  shapes:    " + shape_count)
    print("  commits:   " + commit_count)
    print("  tick:      " + global_tick())
    print("  actor:     " + who)

    if head != "" {
      let head_sig = dim(head, "signature")
      print("")
      print("  HEAD: " + substring(head_sig, 0, 8) + " " + content(head))
      if sig != head_sig {
        let last_tick = to_int(dim(head, "commit_tick"))
        let all = shapes_under(ns)
        let changed = 0
        for s in all {
          if tick(s) > last_tick {
            set changed = changed + 1
          }
        }
        print("  " + changed + " uncommitted changes")
      }
    }
  }

} else {
  if arg0 == "commit" {
    let parts = split(args, " ")
    let msg = ""
    for i in range(0, len(parts)) {
      if i > 0 {
        set msg = msg + " "
      }
      set msg = msg + parts[i]
    }
    if msg == "" {
      print("usage: version commit <message>")
    } else {
      let who = actor()
      if who == "" {
        print("error: not logged in")
      } else {
        let ns = actor_ns()
        let parent = find_head(ns)
        let sig = signature(ns)
        let t = global_tick()
        let commit_id = "os.vcs.commit." + t

        add_shape(commit_id, msg)
        set_dim(commit_id, "type", "commit")
        set_dim(commit_id, "branch", ns)
        set_dim(commit_id, "author", who)
        set_dim(commit_id, "parent", parent)
        set_dim(commit_id, "signature", sig)
        set_dim(commit_id, "commit_tick", to_string(t))
        set_dim(commit_id, "layer", "3")

        // Commit message is also a comment.
        let comment_id = "os.vcs.comment." + t
        add_shape(comment_id, msg)
        set_dim(comment_id, "type", "comment")
        set_dim(comment_id, "target", commit_id)
        set_dim(comment_id, "author", who)
        set_dim(comment_id, "comment_tick", to_string(t))
        set_dim(comment_id, "layer", "3")

        print("[" + substring(sig, 0, 8) + "] " + msg)
        print("  " + len(shapes_under(ns)) + " shapes on " + ns)
      }
    }

  } else {
    if arg0 == "log" {
      let branch = arg1
      if branch == "" {
        let who = actor()
        if who != "" {
          set branch = actor_ns()
        } else {
          set branch = "os"
        }
      }
      let head = find_head(branch)
      if head == "" {
        print("No commits on " + branch)
      } else {
        let current = head
        let count = 0
        while current != "" {
          if count > 50 {
            set current = ""
          } else {
            let sig = dim(current, "signature")
            let a = dim(current, "author")
            let t = dim(current, "commit_tick")
            let msg = content(current)

            print(substring(sig, 0, 8) + " " + msg + " (" + a + ", tick " + t + ")")

            // Show additional comments.
            let all_comments = shapes_under("os.vcs.comment")
            for cm in all_comments {
              if dim(cm, "target") == current {
                if dim(cm, "comment_tick") != t {
                  print("    " + dim(cm, "author") + ": " + content(cm))
                }
              }
            }

            set current = dim(current, "parent")
            set count = count + 1
          }
        }
      }

    } else {
      if arg0 == "diff" {
        let ns = "os"
        let who = actor()
        if who != "" {
          set ns = actor_ns()
        }
        let head = find_head(ns)
        if head == "" {
          print("No commits. " + len(shapes_under(ns)) + " untracked shapes.")
        } else {
          let last_tick = to_int(dim(head, "commit_tick"))
          let head_sig = dim(head, "signature")
          let current_sig = signature(ns)
          if head_sig == current_sig {
            print("Clean. No changes since " + substring(head_sig, 0, 8))
          } else {
            let all = shapes_under(ns)
            let changed = 0
            for s in all {
              if tick(s) > last_tick {
                print("  M " + s + " (tick " + tick(s) + ")")
                set changed = changed + 1
              }
            }
            print("")
            print(to_string(changed) + " shapes modified since " + substring(head_sig, 0, 8))
          }
        }

      } else {
        if arg0 == "branch" {
          if arg1 == "" {
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
              if current_ns != "" {
                print("* " + current_ns + " (no commits)")
              }
            } else {
              for b in branches {
                if b == current_ns {
                  print("* " + b)
                } else {
                  print("  " + b)
                }
              }
            }
          } else {
            print("Branch: " + arg1)
            print("  shapes: " + len(shapes_under(arg1)))
          }

        } else {
          if arg0 == "merge" {
            if arg1 == "" {
              print("usage: version merge <branch>")
            } else {
              let who = actor()
              if who == "" {
                print("error: not logged in")
              } else {
                let target = actor_ns()
                let source_shapes = shapes_under(arg1)
                let merged = 0
                let conflicts = 0
                let source_prefix = arg1 + "."

                for s in source_shapes {
                  let sid = to_string(s)
                  let suffix = ""
                  if has_prefix(sid, source_prefix) {
                    set suffix = substring(sid, len(source_prefix))
                  }
                  if suffix != "" {
                    let target_id = target + "." + suffix
                    if exists(target_id) {
                      if content(s) != content(target_id) {
                        print("  CONFLICT " + suffix)
                        set conflicts = conflicts + 1
                      }
                    } else {
                      add_shape(target_id, content(s))
                      print("  + " + suffix)
                      set merged = merged + 1
                    }
                  }
                }
                print("")
                print(to_string(merged) + " merged, " + to_string(conflicts) + " conflicts")
              }
            }

          } else {
            if arg0 == "push" {
              let who = actor()
              if who == "" {
                print("error: not logged in")
              } else {
                let ns = actor_ns()
                print("Promoting " + ns + " -> os.*")
                let result = promote(ns, "local")
                print("Done.")
              }

            } else {
              if arg0 == "pull" {
                let who = actor()
                if who == "" {
                  print("error: not logged in")
                } else {
                  let ns = actor_ns()
                  let os_shapes = shapes_under("os")
                  let pulled = 0
                  for s in os_shapes {
                    let sid = to_string(s)
                    if has_prefix(sid, "os.") {
                      let suffix = substring(sid, 3)
                      let user_id = ns + "." + suffix
                      if !exists(user_id) {
                        add_shape(user_id, content(s))
                        set pulled = pulled + 1
                      }
                    }
                  }
                  print("Pulled " + pulled + " shapes from os.* to " + ns)
                }

              } else {
                if arg0 == "tag" {
                  if arg1 == "" {
                    let tags = shapes_under("os.vcs.tag")
                    if len(tags) == 0 {
                      print("No tags.")
                    } else {
                      for t in tags {
                        print("  " + dim(t, "name") + " -> " + dim(t, "commit"))
                      }
                    }
                  } else {
                    let who = actor()
                    if who == "" {
                      print("error: not logged in")
                    } else {
                      let ns = actor_ns()
                      let head = find_head(ns)
                      if head == "" {
                        print("No commits to tag.")
                      } else {
                        let tag_id = "os.vcs.tag." + arg1
                        add_shape(tag_id, arg1)
                        set_dim(tag_id, "type", "tag")
                        set_dim(tag_id, "name", arg1)
                        set_dim(tag_id, "commit", head)
                        set_dim(tag_id, "signature", dim(head, "signature"))
                        set_dim(tag_id, "layer", "3")
                        print("Tagged " + substring(dim(head, "signature"), 0, 8) + " as " + arg1)
                      }
                    }
                  }

                } else {
                  if arg0 == "signature" {
                    let ns = "os"
                    let who = actor()
                    if who != "" {
                      set ns = actor_ns()
                    }
                    if arg1 != "" {
                      set ns = arg1
                    }
                    print(signature(ns))

                  } else {
                    if arg0 == "verify" {
                      let ns = "os"
                      let who = actor()
                      if who != "" {
                        set ns = actor_ns()
                      }
                      let head = find_head(ns)
                      if head == "" {
                        print("No commits to verify.")
                      } else {
                        let recorded = dim(head, "signature")
                        let current = signature(ns)
                        print("HEAD: " + substring(recorded, 0, 16) + "...")
                        print("Live: " + substring(current, 0, 16) + "...")
                        if recorded == current {
                          print("Verified. Branch is clean.")
                        } else {
                          print("Diverged. Uncommitted changes.")
                        }
                      }

                    } else {
                      if arg0 == "comment" {
                        if arg1 == "" {
                          print("usage: version comment <shape_id> <text>")
                        } else {
                          let target = arg1
                          if !exists(target) {
                            print("shape not found: " + target)
                          } else {
                            let parts = split(args, " ")
                            if len(parts) < 2 {
                              // Show comments.
                              let all = shapes_under("os.vcs.comment")
                              let found = 0
                              for cm in all {
                                if dim(cm, "target") == target {
                                  print(dim(cm, "author") + ": " + content(cm))
                                  set found = found + 1
                                }
                              }
                              if found == 0 {
                                print("No comments on " + target)
                              }
                            } else {
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
                                let cid = "os.vcs.comment." + t
                                add_shape(cid, text)
                                set_dim(cid, "type", "comment")
                                set_dim(cid, "target", target)
                                set_dim(cid, "author", who)
                                set_dim(cid, "comment_tick", to_string(t))
                                set_dim(cid, "layer", "3")
                                print("Comment added on " + target)
                              }
                            }
                          }
                        }

                      } else {
                        print("version: unknown '" + arg0 + "'")
                        print("Try: commit log diff branch merge push pull tag signature verify comment")
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
"""
}
