shape os.render.benchmark.table.shootout : os.render.benchmark.section.shootout {
  type: table
  layer: 4
  columns: "Substrate, Native loop, Shape engine, Speedup"
  """
C (-O2), 322 ns, 0.3 ns, 1073x
ARM64 asm, 322 ns, 0.9 ns, 358x
Java (HotSpot), 315 ns, 1.1 ns, 286x
JavaScript (V8), 358 ns, 0.5 ns, 705x
Go, 321 ns, 10.7 ns, 30x
Ruby (CRuby), 22484 ns, 54 ns, 416x
Python (CPython), 19146 ns, 74 ns, 257x
Perl, 17471 ns, 74 ns, 237x
Lua, 4725 ns, 23 ns, 208x
PHP, 7225 ns, 40 ns, 183x
Tcl, 31948 ns, 278 ns, 115x
Bash, 4636241 ns, 4866 ns, 952x
  """
}
