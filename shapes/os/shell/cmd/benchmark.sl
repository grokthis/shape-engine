shape os.shell.cmd.benchmark {
  type: exec
  layer: 4
  """
let mc = moments()
if mc == 0 {
  print("No trace moments recorded yet.")
} else {
  print("Benchmark Report")
  print("================")
  print("")

  // Count by action type
  let adds = moments("add")
  let edits = moments("edit")
  let removes = moments("remove")
  let blocks = moments("block")

  print("Total moments:  " + mc)
  print("  adds:         " + adds)
  print("  edits:        " + edits)
  print("  removes:      " + removes)
  print("  blocks:       " + blocks)
  print("")

  // Analyze wave propagation for edits
  if edits > 0 {
    print("Wave Propagation:")
    let total_auto = 0
    let total_flagged = 0
    let max_wave = 0

    for i in range(mc) {
      if moment_action(i) == "edit" {
        let wave = moment_wave(i)
        let auto = len(map_get(wave, "auto_updated"))
        let flagged = len(map_get(wave, "newer_available"))
        let wave_size = auto + flagged
        set total_auto = total_auto + auto
        set total_flagged = total_flagged + flagged
        if wave_size > max_wave {
          set max_wave = wave_size
        }
      }
    }

    print("  total auto-updated: " + total_auto)
    print("  total flagged:      " + total_flagged)
    print("  max wave width:     " + max_wave)
    if edits > 0 {
      print("  avg wave width:     " + round((total_auto + total_flagged) / edits, 1))
    }
    print("")
  }

  // Shape statistics
  print("Shape Graph:")
  print("  total shapes:   " + shape_count())
  print("  global tick:    " + global_tick())
  if mc > 0 {
    print("  ticks/moment:   " + round(global_tick() / mc, 2))
  }
}
"""
}
