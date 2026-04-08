shape os.shell.cmd.hw {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("hw: hardware projection tools")
  print("")
  print("  hw compile    Project all shapes to Verilog")
  print("  hw count      Show gate count estimate")
  print("  hw place      Show placement map")
} else if arg0 == "compile" {
  // Run the hardware compiler shape
  let c = content("hardware.compile")
  if c == "" {
    print("hardware.compile shape not found")
  } else {
    // The compile shape prints Verilog to stdout.
    // Redirect: hw compile > output.v
    let prog = c
  }
} else if arg0 == "count" {
  let all = shapes_under("")
  let n = len(all)
  let cols = ceil(pow(n, 0.5))
  let rows = ceil(n / cols)
  print("Shapes:     " + n)
  print("Lattice:    " + rows + "x" + cols + " = " + rows * cols + " gates")
  print("LUTs/gate:  ~6 (1 slice)")
  print("Total LUTs: ~" + rows * cols * 6)
  print("")
  print("FPGA fit estimates:")
  print("  Artix-7 35T  (33K LUTs):  " + if_val(rows * cols * 6 < 33000, "YES", "NO"))
  print("  Artix-7 100T (101K LUTs): " + if_val(rows * cols * 6 < 101000, "YES", "NO"))
  print("  Kintex-7 325T (326K LUTs): " + if_val(rows * cols * 6 < 326000, "YES", "NO"))
} else if arg0 == "place" {
  let all = sort_list(shapes_under(""))
  let n = len(all)
  let cols = ceil(pow(n, 0.5))
  let idx = 0
  for id in all {
    let row = idx / cols
    let col = mod(idx, cols)
    print(pad_right("[" + row + "," + col + "]", 10) + id)
    set idx = idx + 1
  }
}
"""
}
