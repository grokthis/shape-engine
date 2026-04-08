shape os.render.benchmark.section.shootout : os.render.benchmark {
  type: section
  layer: 4
  order: 5
  title: "Language Shootout"
  "Same computation (sum 0..999999) across 15 substrates. The shape engine erases the language performance hierarchy."
}

shape os.render.benchmark.section.shootout.callout : os.render.benchmark.section.shootout {
  type: callout
  layer: 4
  "Ruby shape (54 ns) beats Go native (321 ns). Bash shape (4.8 us) beats Python native (19 us). The formula is the same 3 arithmetic operations everywhere."
}
