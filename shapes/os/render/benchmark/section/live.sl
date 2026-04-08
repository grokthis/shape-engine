shape os.render.benchmark.section.live : os.render.benchmark {
  type: section
  layer: 4
  order: 10
  title: "Live Shell"
  "A running shape engine in your browser. The benchmark command is loaded. Press Enter to run."
}

shape os.render.benchmark.section.live.shell : os.render.benchmark.section.live {
  type: shell
  layer: 4
  runtime: wasm
  src: shape-engine.wasm
  prompt: "shape> "
  preload: "container benchmark dilation"
  "An embedded shape engine running in WebAssembly. The command is typed. Hit Enter. Watch the dilation table print in real time from inside the engine that the page describes."
}
