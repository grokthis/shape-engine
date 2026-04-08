shape os.render.benchmark.section.cpu : os.render.benchmark {
  type: section
  layer: 4
  order: 6
  title: "Shape CPU (3.7 MHz Processor)"
  "A complete RISC processor built from shapes. Every instruction is a shape graph traversal. 3.7 MIPS sustained. All arithmetic exact rational."
}

shape os.render.benchmark.section.cpu.callout : os.render.benchmark.section.cpu {
  type: callout
  layer: 4
  "3.7 MHz is 1350x slower per tick than 5 GHz. But the shape CPU reads structure. At 3-SAT n=100, the 5 GHz Turing machine won't finish before heat death. The shape CPU finishes in 270 us."
}
