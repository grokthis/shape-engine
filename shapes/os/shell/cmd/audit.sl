shape os.shell.cmd.audit {
  type: exec
  layer: 4
  """
// Show detailed audit trail for a user or the current actor.
let target = default(arg0, actor())
if target == "" {
  print("audit: need user ID or login first")
} else {
  print("Audit Trail: " + target)
  print(repeat("=", 50))
  let layers = range(0, 6)
  for l in layers {
    let mc = moments(l)
    let found = false
    for i in range(0, mc) {
      let a = moment_actor(l, i)
      if a == target {
        if !found {
          print("")
          print("Layer " + l)
          set found = true
        }
        let action = moment_action(l, i)
        let tgt = moment_target(l, i)
        let ts = moment_ts(l, i)
        print("  M" + pad_right(i, 4) + " " + pad_right(action, 12) + " " + pad_right(tgt, 30) + " " + ts)
      }
    }
  }
}
"""
}
