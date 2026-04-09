shape os.shell.cmd.git {
  type: exec
  layer: 4
  """
// git <command> [args...]
// Git-compatible interface to shape-vcs.
// Translates git syntax to shape operations.

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
  print("usage: git <command> [args...]")
  print("")
  print("commands:")
  print("  git init              Initialize (no-op: shapes are always versioned)")
  print("  git add <shape>       Stage shape (no-op: all mutations are tracked)")
  print("  git commit -m <msg>   Create commit")
  print("  git log               Show commit history")
  print("  git diff              Show changes since last commit")
  print("  git status            Show working tree status")
  print("  git branch [name]     List or inspect branches")
  print("  git merge <branch>    Merge branch into current")
  print("  git push              Promote to local (os.*)")
  print("  git pull              Copy from local to user namespace")
  print("  git checkout <branch> Switch namespace (set actor)")
} else {
  if arg0 == "init" {
    print("Initialized shape repository.")
    print("(Shapes are always versioned. Every mutation is a traced moment.)")

  } else {
    if arg0 == "add" {
      if arg1 == "" {
        print("usage: git add <shape>")
      } else {
        if arg1 == "." {
          print("All shapes are always tracked. Nothing to add.")
        } else {
          if exists(arg1) {
            print("Shape " + arg1 + " is already tracked (tick " + tick(arg1) + ")")
          } else {
            print("Shape not found: " + arg1)
          }
        }
      }

    } else {
      if arg0 == "commit" {
        // Parse -m flag.
        let msg = ""
        if arg1 == "-m" {
          let parts = split(args, " ")
          if len(parts) > 1 {
            set msg = ""
            for i in range(1, len(parts)) {
              if i > 1 {
                set msg = msg + " "
              }
              set msg = msg + parts[i]
            }
          }
        } else {
          set msg = args
        }
        if msg == "" {
          print("usage: git commit -m <message>")
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

            // Commit message as comment.
            let comment_id = "os.vcs.comment." + t
            add_shape(comment_id, msg)
            set_dim(comment_id, "type", "comment")
            set_dim(comment_id, "target", commit_id)
            set_dim(comment_id, "author", who)
            set_dim(comment_id, "comment_tick", to_string(t))
            set_dim(comment_id, "layer", "3")

            print("[" + ns + " " + substring(sig, 0, 7) + "] " + msg)
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
              if count > 20 {
                set current = ""
              } else {
                let sig = dim(current, "signature")
                let short = substring(sig, 0, 7)
                let a = dim(current, "author")
                let msg = content(current)

                print("commit " + sig)
                print("Author: " + a)
                print("")
                print("    " + msg)
                print("")

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
              print("No commits. All shapes are new.")
            } else {
              let last_tick = to_int(dim(head, "commit_tick"))
              let last_sig = dim(head, "signature")
              let current_sig = signature(ns)

              if last_sig == current_sig {
                print("No changes since last commit.")
              } else {
                let all = shapes_under(ns)
                let changed = 0
                for s in all {
                  if tick(s) > last_tick {
                    print("  M " + s)
                    set changed = changed + 1
                  }
                }
                if changed == 0 {
                  print("Signature changed but no shapes modified (structural shift).")
                } else {
                  print("")
                  print(to_string(changed) + " shapes modified")
                }
              }
            }

          } else {
            if arg0 == "status" {
              let who = actor()
              if who == "" {
                print("Not logged in.")
              } else {
                let ns = actor_ns()
                print("On branch " + ns)
                print("")

                let head = find_head(ns)
                if head == "" {
                  print("No commits yet.")
                  print("")
                  let all = shapes_under(ns)
                  if len(all) > 0 {
                    print("Untracked shapes (" + len(all) + "):")
                    for s in all {
                      print("  " + s)
                    }
                  }
                } else {
                  let last_tick = to_int(dim(head, "commit_tick"))
                  let last_sig = dim(head, "signature")
                  let current_sig = signature(ns)

                  if last_sig == current_sig {
                    print("nothing to commit, working tree clean")
                  } else {
                    let all = shapes_under(ns)
                    let changed = 0
                    for s in all {
                      if tick(s) > last_tick {
                        set changed = changed + 1
                      }
                    }
                    print("Changes not committed:")
                    print("  " + changed + " shapes modified")
                    print("")
                    print("use \"git commit -m <msg>\" to commit")
                  }
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
                  let who = actor()
                  let current_ns = ""
                  if who != "" {
                    set current_ns = actor_ns()
                  }
                  for b in branches {
                    if b == current_ns {
                      print("* " + b)
                    } else {
                      print("  " + b)
                    }
                  }
                  if len(branches) == 0 {
                    if current_ns != "" {
                      print("* " + current_ns + " (no commits)")
                    }
                  }
                } else {
                  print("Branch info: " + arg1)
                  print("  shapes: " + len(shapes_under(arg1)))
                }

              } else {
                if arg0 == "merge" {
                  if arg1 == "" {
                    print("usage: git merge <branch>")
                  } else {
                    let who = actor()
                    if who == "" {
                      print("error: not logged in")
                    } else {
                      print("Merging " + arg1 + "...")
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
                            set merged = merged + 1
                          }
                        }
                      }
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
                      print("Pushed.")
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
                      if arg0 == "checkout" {
                        if arg1 == "" {
                          print("usage: git checkout <branch>")
                        } else {
                          if has_prefix(arg1, "user.") {
                            let name = substring(arg1, 5)
                            set_actor(name)
                            print("Switched to branch " + arg1)
                          } else {
                            print("Can only checkout user branches (user.<name>)")
                          }
                        }

                      } else {
                        print("git: unknown command '" + arg0 + "'")
                        print("Try: init, add, commit, log, diff, status, branch, merge, push, pull, checkout")
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
