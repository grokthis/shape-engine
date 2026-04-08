shape os.shell.cmd.test {
  type: exec
  layer: 4
  """
// Parse flags.
let verbose = false
let list_mode = false
let history_mode = false
let coverage_mode = false
let moments_mode = false
let branch_mode = false
let suite = ""
let moments_count = 20

// Parse args.
if arg0 == "-v" {
  set verbose = true
  set suite = default(arg1, "")
} else {
  if arg0 == "--list" {
    set list_mode = true
  } else {
    if arg0 == "--history" {
      set history_mode = true
    } else {
      if arg0 == "--coverage" {
        set coverage_mode = true
      } else {
        if arg0 == "--moments" {
          set moments_mode = true
          if arg1 != "" {
            set moments_count = to_int(arg1)
          }
        } else {
          if arg0 == "--branch" {
            set branch_mode = true
          } else {
            set suite = default(arg0, "")
          }
        }
      }
    }
  }
}

// --- List Mode ---
if list_mode {
  print("Structural Test Suite")
  print("=====================")
  let suites = children("os.test")
  for s in suites {
    if s != "result" && s != "history" {
      let tests = children("os.test." + s)
      let count = len(tests)
      print("")
      print("os.test." + s + " (" + count + " tests)")
      for t in tests {
        let full = "os.test." + s + "." + t
        let desc = dim(full, "desc")
        print("  " + pad_right(t, 24) + " " + desc)
      }
    }
  }
} else {
  if history_mode {
    // Show test execution history from os.test.history.
    if exists("os.test.history") {
      let hist = content("os.test.history")
      if hist != "" {
        print(hist)
      } else {
        print("No test history yet. Run 'test' to create the first entry.")
      }
    } else {
      print("No test history yet. Run 'test' to create the first entry.")
    }
  } else {
    if coverage_mode {
      // Structural coverage: count test shapes vs shape categories.
      print("Structural Coverage Report")
      print("==========================")
      print("")
      let total_shapes = shape_count()
      let test_shapes = len(shapes_under("os.test"))
      let suites = children("os.test")
      let suite_count = 0
      let test_count = 0
      for s in suites {
        if s != "result" && s != "history" {
          set suite_count = suite_count + 1
          let tests = children("os.test." + s)
          set test_count = test_count + len(tests)
        }
      }
      print("Total shapes:     " + total_shapes)
      print("Test suites:      " + suite_count)
      print("Test shapes:      " + test_count)
      print("")

      // Per-suite coverage.
      print("Suite Coverage:")
      for s in suites {
        if s != "result" && s != "history" {
          let tests = children("os.test." + s)
          let ct = len(tests)
          // Run them to get pass count.
          let r = test_shapes_under("os.test." + s, false)
          let p = index(r, 0)
          let f = index(r, 1)
          let status = if_val(f == 0, "PASS", "FAIL")
          print("  " + pad_right("os.test." + s, 28) + " " + p + "/" + ct + " " + status)
        }
      }

      // Layer coverage.
      print("")
      print("Layer Coverage:")
      let layers = range(0, 6)
      for l in layers {
        let count = 0
        for sh in shapes_under("") {
          if layer(sh) == l {
            set count = count + 1
          }
        }
        if count > 0 {
          print("  Layer " + l + ": " + count + " shapes")
        }
      }

      // Moment coverage.
      print("")
      print("Trace Coverage:")
      for l in layers {
        let mc = moments(l)
        if mc > 0 {
          print("  Layer " + l + ": " + mc + " moments")
        }
      }
    } else {
      if moments_mode {
        // Show recent moments across all layers.
        print("Recent Moments (last " + moments_count + ")")
        print(repeat("=", 60))
        let layers = range(0, 6)
        let total = 0
        for l in layers {
          let mc = moments(l)
          if mc > 0 {
            print("")
            print("Layer " + l + " (" + mc + " moments)")
            // Show last N moments.
            let start = mc - moments_count
            if start < 0 {
              set start = 0
            }
            let i = start
            for idx in range(start, mc) {
              let info = moment_at(l, idx)
              let ts = moment_ts(l, idx)
              let action = moment_action(l, idx)
              let target = moment_target(l, idx)
              print("  M" + pad_right(idx, 4) + " " + pad_right(action, 12) + " " + pad_right(target, 30) + " " + ts)
            }
            set total = total + mc
          }
        }
        print("")
        print("Total moments: " + total)
        print("Global tick:   " + global_tick())
      } else {
        if branch_mode {
          // Show trace branch state for all layers.
          print("Trace Branch State")
          print("==================")
          let layers = range(0, 6)
          for l in layers {
            let mc = moments(l)
            if mc > 0 {
              let active = trace_active_branch(l)
              let branches = trace_branches(l)
              let branch_str = if_val(active == "", "main", active)
              print("")
              print("Layer " + l + ": " + mc + " moments, active branch: " + branch_str)
              if len(branches) > 0 {
                print("  Branches: " + join(branches, ", "))
              }
            }
          }
        } else {
          // --- Run Tests ---
          let prefix = if_val(suite == "", "os.test", "os.test." + suite)

          if suite != "" {
            print("test " + suite)
            print(repeat("-", 40))
          } else {
            print("Shape OS Structural Test Suite")
            print(repeat("=", 40))
          }

          let suites_to_run = children(prefix)
          let total_pass = 0
          let total_fail = 0

          if suite != "" {
            // Run a single suite.
            let r = test_shapes_under(prefix, verbose)
            let p = index(r, 0)
            let f = index(r, 1)
            set total_pass = p
            set total_fail = f
          } else {
            // Run all suites.
            for s in suites_to_run {
              if s != "result" && s != "history" {
                let suite_prefix = prefix + "." + s
                let tests = children(suite_prefix)
                let ct = len(tests)
                if ct > 0 {
                  if verbose {
                    print("")
                    print(s + " (" + ct + " tests)")
                    print(repeat("-", 30))
                  }
                  let r = test_shapes_under(suite_prefix, verbose)
                  let p = index(r, 0)
                  let f = index(r, 1)
                  set total_pass = total_pass + p
                  set total_fail = total_fail + f
                  if !verbose {
                    let status = if_val(f == 0, "PASS", "FAIL")
                    print("  " + pad_right(s, 20) + " " + p + "/" + ct + " " + status)
                  }
                }
              }
            }
          }

          print("")
          let total = total_pass + total_fail
          if total_fail == 0 {
            print("PASS  " + total_pass + "/" + total + " tests passed")
          } else {
            print("FAIL  " + total_pass + " passed, " + total_fail + " failed")
          }

          // Store result.
          let tick_now = global_tick()
          let result_content = total_pass + "/" + total + " at tick " + tick_now
          if total_fail > 0 {
            set result_content = "FAIL " + result_content
          } else {
            set result_content = "PASS " + result_content
          }
          add_shape("os.test.result.last", "result", result_content)

          // Append to history.
          let hist = ""
          if exists("os.test.history") {
            set hist = content("os.test.history")
          }
          let entry = result_content
          if hist != "" {
            set hist = hist + "\n" + entry
          } else {
            set hist = entry
          }
          add_shape("os.test.history", "history", hist)
        }
      }
    }
  }
}
"""
}
