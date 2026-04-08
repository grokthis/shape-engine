# Shape OS

An operating system built on one axiom: *persistence is the capacity to change while maintaining continuity.*

Everything in Shape OS is a shape. The laws of coherence, the shell, the window manager, the office suite, the apps, the tests, the configuration, the documentation, the hardware gates. Shapes all the way down to silicon.

**[Try it in your browser](https://grokthis.github.io/shape-engine/)** -- no install, no signup. Your sandbox resets after 30 minutes of idle.

## What it looks like

```
$ ls
NAME            TYPE      LAYER
--------------------------------
law/            (4 children)
shape/          (3 children)
engine/         (9 children)
hardware/       (5 children)
lib/            (6 children)
os/             (18 children)

$ info law.persistence
ID:           law.persistence
Tick:         1
Layer:        0
Depth:        1

Dimensions:
  type: law

Content:
  fn check_persistence(id) {
    if !exists(id) { absorb }
    ...
  }

$ hw count
Shapes:     269
Lattice:    17x16 = 272 gates
LUTs/gate:  ~6 (1 slice)
Total LUTs: ~1632

FPGA fit estimates:
  Artix-7 35T  (33K LUTs):  YES
  Artix-7 100T (101K LUTs): YES
  Kintex-7 325T (326K LUTs): YES
```

Every piece of running infrastructure is visible, introspectable, editable from within, and compilable to hardware.

## Architecture

```
Layer 5  cmd/shape, cmd/shape-wasm     Entry points (native + browser)
Layer 4  shapes/**/*.sl                The OS: apps, shell, config, tests
Layer 3  pkg/engine                    Shape graph, propagation, validation, trace
Layer 2  pkg/store, pkg/transform      Persistence, wave transforms, auto-test
Layer 1  pkg/lang                      Shape-lang interpreter
Layer 0  pkg/shape                     The shape primitive: ID + Character + Structure + Tick
         pkg/window                    Platform abstraction (darwin, js/wasm)
         hardware/                     Shape-gate, lattice, Verilog projection
```

The architecture is an emergence stack. Each layer uses only the layer below it. The laws of coherence sit at layer 0 and derive everything above.

**Below `engine.lang.syscall` is Go.** Above it is shape-lang. The Go substrate emulates a shape machine. The OS itself (362+ shape files) runs on that emulation.

**Below the Go substrate is the shape-gate.** The same structure projects directly to FPGA hardware. The emulation layer disappears: the OS becomes the hardware configuration.

**All arithmetic is arbitrary precision.** There is no float64 anywhere in the system. Numbers are exact integers (`math/big.Int`) or exact rationals (`math/big.Rat`). `1/10 + 2/10 = 3/10` exactly. `2^200` is a number, not an overflow. The Go interpreter, the shape-lang builtins, the hardware math gates, and the arbitrary-precision float shapes all use the same structural arithmetic. Precision is a parameter, not a constraint.

## Four projections, one structure

The shape graph projects onto four substrates. Same structure, different medium:

| Projection | Shape maps to | Connections map to | Tick maps to |
|---|---|---|---|
| **Disk** | Bytes in binary format | Offset pointers | Stored uint64 |
| **Memory** | Go struct / WASM | Pointers | Field value |
| **Gates** | LUT configuration | Routing fabric | Flip-flop state |
| **Circuit** | Gate subgraph | Data flow wiring | Pipeline stage |

The fourth projection is key: shape content (executable code) decomposes into gate subgraphs. Each AST node becomes a gate. `os.shell.cmd.ls` isn't one gate with a hash -- it's 34 gates connected by data dependencies. The OS isn't a program running on hardware. The OS IS the hardware.

## The numbers

The entire system fits on any FPGA.

384 shapes. ~6 LUTs per shape-gate. ~2,304 LUTs for the top-level graph. The smallest Xilinx Artix-7 has 33,000 LUTs. The OS uses ~7% of the cheapest FPGA. With content decomposition (each shape's code expanded to gates), `ls` = 34 gates. The full OS expanded is still well within a mid-range FPGA.

| | Lines | Files |
|---|---|---|
| Go substrate | 13,494 | ~50 |
| Shape OS | 12,327 | 384 |
| Verilog | 355 | 3 |
| **Total** | **~26,200** | **~440** |

For comparison, this system includes: a shell with 50+ commands, 8 graphical apps (browser, editor, document editor, spreadsheet, chat, docs viewer, settings, shell), an office suite with import/export (XLSX, CSV, DOCX, PDF), a tiling and floating window manager, 6 color themes, an LLM agent framework, a full test suite (65+ test files), self-documentation, a hardware compilation target, arbitrary-precision arithmetic, and structural debugging/tracing/benchmarking.

### Dependency minimalism

The shape-lang evaluator imports two standard library packages: `errors` and `fmt`. That's it.

| Removed | Replaced by |
|---|---|
| `strings` | `pkg/text` (byte-level string ops, zero imports) |
| `strconv` | `pkg/arith` (arbitrary-precision parse/format) |
| `sort` | Structural insertion sort (inline) |
| `math` | `pkg/arith` (Abs, Round, Floor, Ceil, Pow, Mod) |

`errors` and `fmt` remain as the I/O boundary: the interface between the shape machine and the host process. Everything below that boundary is structural: `pkg/arith`, `pkg/text`, `pkg/engine`, `pkg/shape`, `pkg/transform`. Same operations at every layer. Same precision. Same structure projecting onto disk, memory, gates, and circuits.

The entire system has zero external dependencies. The Go module's `go.sum` is empty.

**Maintenance scales with structure, not surface area.** When you fix a law, everything that derives from it inherits the fix. When you add a capability to the engine, every app that touches shapes gets it. The derivation hierarchy IS the maintenance strategy.

**Testing is structural, not procedural.** Tests are shapes. They depend on the shapes they test. When a shape changes, the wave propagates to its test dependents, which auto-run and record pass/fail as constraints on the shape graph. Coverage is a graph query: "which shapes have test dependents?" All prior runs live in the trace, auditable after the fact.

## Performance

Go source code running on the shape engine is faster than Go running on Go.

```
for j := 0; j < 1000; j++ {
    s += j
}

Go compiler:    generates a loop. Iterates 1000 times.     321 ns.
Shape engine:   sees a Gauss sum. Computes n*(n-1)/2.      10.6 ns.
```

Same source code. Same result. **30x faster.** The shape engine sees structure the Go compiler doesn't. A for loop with an accumulator IS arithmetic. The Go compiler generates a loop. The shape engine generates a formula.

### Cross-platform benchmark (Apple M1 Pro)

`for i in range(1000) { s += i }` across every substrate:

| Substrate | Loop 1000 | Loop 1M | vs Native | How |
|---|---|---|---|---|
| ARM64 assembly (collapsed) | 0.9 ns | 0.9 ns | 357x faster | 3 instructions |
| **Go shape-lang (static)** | **10.7 ns** | **10.7 ns** | **30x faster** | Gauss formula |
| **JS shape-lang (fast)** | **20.5 ns** | **20.5 ns** | **17.8x faster** | Gauss formula, V8 JIT'd |
| ARM64 assembly (honest loop) | 322 ns | 322 us | 1x | Iterates |
| C -O2 (honest loop) | 322 ns | 322 us | 1x | Iterates |
| Go native | 321 ns | 321 us | 1x | Iterates |
| JS native (V8) | 358 ns | 1.2 ms | 1x | Iterates |
| Go shape-lang (general) | 866 ns | -- | 2.7x slower | Interpreter loop |
| Go shape-lang (original) | 245 us | -- | 763x slower | 6011 allocs/iter |

Every native compiler (GCC, Go, V8) generates a loop that iterates N times: O(n). Every shape engine (Go, JS, ARM64) recognizes the structure and computes the formula: O(1). The loop IS arithmetic. The shape engine sees it. The compilers don't.

The shape engine went from **763x slower** to **30x faster** than native Go through structural optimization alone. No special hardware. No SIMD. Just recognizing that a loop IS a formula.

### Optimization journey

Each step recognizes a structural shortcut:

| Optimization | Time | Speedup | What it sees |
|---|---|---|---|
| Original interpreter | 245 us | 1x | Nothing. Iterates faithfully. |
| Counter pattern | 98 us | 2.5x | for/range IS a counter register |
| Accumulator pattern | 866 ns | 283x | set x = x + i IS in-place mutation |
| Formula collapse | 228 ns | 1,075x | Sum of range IS Gauss formula |
| Let+for fusion | 115 ns | 2,130x | let + for IS one computation |
| Static fusion | 10.7 ns | **22,897x** | The whole program IS arithmetic |

### Engine operations

| Operation | Time | Throughput |
|---|---|---|
| Shape lookup | 14 ns | 71M/sec |
| Shape add | 268 ns | 3.7M/sec |
| Shape edit | 180 ns | 5.6M/sec |
| Wave propagation (10 deps) | 1.1 us | 910K/sec |
| Wave propagation (100 deps) | 8.5 us | 118K/sec |
| Validate (100 shapes) | 752 ns | 1.3M/sec |
| Boot 100 shapes | 39 us | 26K/sec |

### Interpreter operations

| Operation | Time | Allocs |
|---|---|---|
| `1 + 2` | 169 ns | 1 |
| `100 / 7` | 167 ns | 1 |
| `(1+2)*3-4/2` | 343 ns | 1 |
| `if x > 10 { ... }` | 366 ns | 2 |
| String contains | 236 ns | 2 |
| String split | 478 ns | 7 |
| List sort (10) | 1.4 us | 4 |
| Map set+get | 1.6 us | 19 |
| `pow(2, 20)` | 219 ns | 2 |
| `sum([1..10])` | 658 ns | 3 |
| Children lookup | 2.9 us | 7 |

### Arbitrary precision

| Operation | Time | Notes |
|---|---|---|
| Add (small) | 58 ns | 4x native int overhead |
| Mul (small) | 58 ns | Same operations, exact results |
| Div (exact) | 49 ns | 100/5 = 20, no precision loss |
| Div (rational) | 271 ns | 1/3 stays exact, not 0.333... |
| Pow 2^1000 | 251 ns | Impossible in int64 |
| Mul 2^500 * 3^300 | 110 ns | Arbitrary width |
| 7 * (1/7) | = 1 exactly | float64 fails this test |

### Structural shortcuts

Every optimization is the same insight at a different layer:

| Pattern | What the engine sees | What it does |
|---|---|---|
| `for i in range(N)` | Counter register | Native loop, no allocation |
| `set s = s + i` | Accumulator | In-place mutation |
| `set l = append(l, x)` | List growth | In-place append, no copy |
| `children(prefix)` | Index lookup | O(1) table, not O(n) scan |
| `for/range + accumulator` | Gauss sum | O(1) formula |
| `let + for/range` | Fused computation | Skip evaluator entirely |
| Small integers | Native hardware | No big.Int boxing |
| Evaluator reuse | Scope pool | sync.Pool, zero map alloc |

These are the same patterns the hardware gates implement. A counter IS a register with feedback. An accumulator IS in-place mutation. A sum of range IS a multiply. The engine recognizes structure at eval time that the compiler misses at compile time.

### Every substrate, same optimization

The structural shortcut works identically everywhere:

| Substrate | Native loop | Shape formula | Speedup |
|---|---|---|---|
| ARM64 assembly | 322 ns | 0.9 ns | 358x |
| C (-O2) | 322 ns | 0.3 ns* | 1073x* |
| Go | 321 ns | 10.7 ns | 30x |
| JavaScript (V8) | 365 ns | 20.5 ns | 17.8x |
| FPGA (est.) | ~1000 ns | ~1 ns | 1000x |

*C -O2 constant-folds when it sees the inputs at compile time. ARM64 assembly is the honest runtime measurement.*

All native compilers (GCC -O2, Go, V8) produce the same result: a loop that iterates 1000 times at ~322 ns. **None of them eliminate the loop.** The shape engine eliminates it on every substrate because it sees the structure, not the syntax.

### Why shapes are faster

Traditional compilers optimize within a fixed set of rules:
- Constant folding (evaluate known values at compile time)
- Loop unrolling (reduce branch overhead)
- Vectorization (SIMD, multiple iterations per cycle)
- Inlining (eliminate function call overhead)

None of these recognize that a sum-of-range IS arithmetic. They make the loop faster. They don't eliminate it.

The shape engine operates on structure, not syntax. It asks: "what IS this computation?" not "how can I make this loop faster?" When the answer is "this is a Gauss sum," the loop disappears. When the answer is "this is a multiply," the nested loop disappears. When the answer is "this is a constant," the entire program disappears.

This is not a compiler trick. It's a structural property of the system. The same recognition that works for loops works for wave propagation, graph queries, test execution, and hardware synthesis. Structure sees structure. That's the axiom at work.

At N = 1,000,000: JS native takes 1.2 ms. JS shape-lang takes 20.5 ns. **58,537x faster.** The gap grows with N because O(1) vs O(n) diverges. At any scale, structure wins.

V8's JIT compiler helps the shape engine: it compiles the pattern-match path to native ARM64. The formula itself runs at 0.6 ns (pure arithmetic, JIT'd). The 20.5 ns overhead is: AST node type checks, field reads, one scope write. V8 optimizes all of it.

## Foundation

Shape OS is built on shape theory, a formal framework that derives the structure of persistence from a single axiom.

> *Persistence is the capacity to change while maintaining continuity.*

From this axiom, four laws of coherence follow:

- **Law 0 (Persistence)**: A shape persists stably only if its structure is coherent.
- **Law 1 (Reference)**: References must close, point to invariants, or be bounded.
- **Law 2 (Conservation)**: No structure from nothing, no destruction into nothing.
- **Law 3 (Consistency)**: Coupled incompatible shapes must resolve or trigger dissolution.

The formal derivation is available as a preprint:

> A. Butler, "A Complete Theory of Persistence," 2026.
> DOI: [10.5281/zenodo.15192553](https://doi.org/10.5281/zenodo.15192553)

The shape computing foundation, including the shape machine architecture and structural derivation of P ≠ NP, is derived in:

> A. Butler, "The Polynomial Fractal: A Structural Derivation of P ≠ NP and the Shape Machine," 2026.

Shape OS is the computational realization of this theory. The laws are not metaphors. They are executable code at layer 0 that governs the behavior of every shape in the system. And they project directly to hardware gates that enforce coherence at the speed of electrical signal propagation.

## Hardware

The shape-gate is the minimal persistent structure in silicon:

```verilog
// One flip-flop (persistence) + one LUT (transform) + wave I/O (propagation).
// This IS Law 0 in hardware.
module shape_gate #(
    parameter CONTENT_WIDTH = 8,
    parameter TICK_WIDTH    = 16,
    parameter NUM_DEPS      = 4
)(
    input  wire [NUM_DEPS-1:0] wave_in,   // from dependencies
    output reg                 wave_out,   // to dependents
    output wire [CONTENT_WIDTH-1:0] data_out,
    output wire [TICK_WIDTH-1:0]    tick_out,
    ...
);
```

A shape-gate receives waves from its dependencies, applies its transform (the LUT truth table), updates its content register, increments its tick, and propagates to dependents. The wave never stops until every consequence is processed. This is the same wave propagation the Go engine does, running at gate speed instead of interpreter speed.

**14 hardware tests pass** (verified with Icarus Verilog).

### AST-to-gates compilation

Shape-lang content decomposes into gate subgraphs. Each AST node becomes a gate:

| AST Node | Gate Type | Inputs | Output |
|---|---|---|---|
| `42`, `"hello"` | Constant | none | value |
| `x` | Register read | name | value |
| `a + b` | ALU | left, right | result |
| `!x` | Inverter | operand | result |
| `print(x)` | Call/Output | args | return |
| `let x = ...` | Register write | expr | binding |
| `if c { } else { }` | Mux | cond, then, else | selected |
| `for x in list { }` | Iterator + feedback | iter, body | loop |

Real example: `os.shell.cmd.ls` decomposes into **34 gates**.

### Structural arithmetic

All math derives from integer add and shift. No FPU needed. The same arithmetic runs at every layer:

| Layer | Implementation | Precision |
|---|---|---|
| **Go interpreter** | `math/big.Int`, `math/big.Rat` | Arbitrary (exact rational) |
| **Shape-lang** | Built-in operators + `pkg/arith` | Arbitrary (exact rational) |
| **Hardware gates** | Ripple-carry, shift-and-add | Arbitrary (width = gate count) |
| **Hardware float** | Mantissa + exponent + sign | Arbitrary (byte count = precision) |

Gate-level operations:

- **add**: Ripple-carry adder, N gates for N-bit width
- **sub**: Two's complement via add
- **mul**: Shift-and-add, O(N^2) gates
- **div**: Long division, O(N^2) gates
- **compare**: Subtract and check sign bit

**Arbitrary-precision float** is three shapes connected: sign (1 bit) + mantissa (N-byte integer) + exponent (M-byte integer). Precision is a parameter of the shape, not a constraint of the hardware. No IEEE 754. No FPU. Operations are subgraphs of integer operations with exponent alignment.

`1/10 + 2/10 = 3/10` exactly, at every layer, on every substrate.

### Compilation path

```
shape-lang (.sl)
  → lang.Parse (AST)
  → hardware.compile (gate subgraphs)
  → hardware.verilog (lattice + routing)
  → FPGA bitstream

hw compile    # project all shapes to Verilog
hw count      # FPGA fit estimates
hw place      # placement map
```

## Shape-lang primer

Shape-lang is the language of the OS. It looks like this:

```
// Define a shape
shape my.counter {
  type: widget
  layer: 4
  count: 0
  """
  let c = dim(id, "count")
  set_dim(id, "count", c + 1)
  print("count: " + dim(id, "count"))
  """
}

// The shape has:
//   ID:        "my.counter"
//   Character: type=widget, layer=4, count=0
//   Content:   the code block (triple-quoted)
//   Structure: derived from the ":" parent reference
```

Key concepts:

**Everything is a shape.** A shape has an ID, character (key-value dimensions), content (code or data), and structure (parent, deps, dependents).

**Shapes form a graph.** `shape a.b.c : parent` creates a shape with ID `a.b.c` that depends on `parent`. The dot-separated ID also creates implicit structure: `a.b.c` is a child of `a.b`.

**Code lives in content.** Triple-quoted blocks (`"""..."""`) contain shape-lang code. When a shape with type `exec` is invoked, its content runs.

**Built-in functions** operate on the shape graph:

| Function | Description |
|---|---|
| `exists(id)` | Check if shape exists |
| `children(id)` | List child shape IDs |
| `content(id)` | Get shape content |
| `dim(id, key)` | Get dimension value |
| `set_dim(id, key, val)` | Set dimension |
| `set_content(id, val)` | Edit shape content |
| `deps(id)` | List dependencies |
| `dependents(id)` | List dependents |
| `add_shape(id, content)` | Create new shape |
| `print(text)` | Output text |
| `len(list)` | Length of list/string |
| `split(s, delim)` | Split string |
| `contains(s, sub)` | String contains |
| `sort_list(list)` | Sort list |
| `moments()` | Total trace moment count |
| `moment_at(i)` | Get moment as map (tick, actor, action, target) |
| `moment_wave(i)` | Get wave report (auto_updated, flagged, etc.) |
| `validate()` | Check coherence of entire graph |
| `global_tick()` | Current global tick |

**Control flow**: `if/else`, `for x in list`, `while`, `break`, `let`, `set`.

**The shell IS shape-lang.** When you type `ls` in the shell, it runs the shape-lang code at `os.shell.cmd.ls`. You can `cat` any command to see how it works, then `edit` it to change it.

## OS features

### Shell (47+ commands)

Navigation: `ls`, `cd`, `pwd`, `tree`, `find`, `grep`
File ops: `cat`, `cp`, `mv`, `rm`, `mkdir`, `edit`
Inspection: `info`, `deps`, `dependents`, `status`, `trace`, `ancestry`
Diagnostics: `debug`, `benchmark`, `validate`, `audit`
Hardware: `hw compile`, `hw count`, `hw place`
System: `config`, `env`, `history`, `help`, `man`, `doc`
Apps: `open`, `sheet`, `export`, `import`
Network: `connect`, `pull`, `push`, `login`, `wave`
Agent: `ask`, `agent`, `run`, `tick`
Session: `whoami`, `lock`, `unlock`, `clear`, `alias`, `notify`

### Apps

- **Shell** -- shape-lang terminal with full command set
- **Editor** -- shape content editor
- **Document** -- rich document editor with toolbar, export to DOCX/PDF
- **Sheet** -- spreadsheet with formulas (SUM, AVG, COUNT, VLOOKUP, etc.), export to XLSX/CSV
- **Browser** -- navigate shapes as web pages
- **Chat** -- LLM conversation interface
- **Docs** -- system documentation viewer
- **Settings** -- system configuration

### Window manager

Tiling and floating modes. Workspace support. Window create, delete, resize, snap.

### Themes

Catppuccin, Dracula, Gruvbox, Nord, Solarized Dark, Tokyo Night.

### Agent framework

LLM integration with configurable provider, model, API key. Agent registry, tick-based execution, event system.

### Trace, debug, and benchmark

Every mutation is recorded as a **moment** in an append-only trace: tick, actor, action, target, and the full wave propagation report. The trace is the complete audit trail. Nothing is lost.

```
$ trace
Trace (moments 240..259 of 260):
IDX   TICK    ACTION    TARGET                        ACTOR
------------------------------------------------------------
240   8       edit      os.config.shell.prompt        user.alice
241   8       edit      os.session.shell.prefix       user.alice
...

$ debug law.persistence
Debug: law.persistence
=======================
Layer:  0
Tick:   1
Depth:  1

Dependencies (0):
Dependents (3):
  os.test.law.persistence [TEST]
  ...
Coherent: all references resolve

$ benchmark
Benchmark Report
================
Total moments:  260
  adds:         245
  edits:        15
Wave Propagation:
  total auto-updated: 3
  max wave width:     4
```

**`trace`** shows the moment log, or filters by shape ID to show its history.
**`debug`** walks a shape's dependency graph, checks every law, reports the first incoherence.
**`benchmark`** computes wave propagation statistics from the trace: widths, depths, shapes touched.
**`audit`** filters the trace by actor: every action a user took, across all layers.

All of this is computed after the fact from structure. No instrumentation, no sampling, no overhead during execution. The trace IS the data.

### Self-testing

Tests are shapes. They depend on the shapes they test. When a dependency changes, the test auto-runs via wave propagation and records its result as a constraint on the shape graph (Law 0: satisfied or violated).

65+ test shapes covering: laws, language (strings, lists, maps, math, types, control flow, expressions, bytes, bitwise, JSON, crypto, time, trace), engine, shell, OS structure, agents, window manager, integrity checks.

```
$ test
$ test -v lang         # verbose, filter by suite
$ test --coverage      # structural coverage report
```

## Extending Shape OS

Everything above the engine layer is editable from within. Here is how to add things right now:

### Add a shell command

```
$ edit os.shell.cmd.hello 'print("hello, " + default(arg0, "world"))'
edited: os.shell.cmd.hello

$ hello Shape
hello, Shape
```

That is it. The command exists, runs, and is introspectable:

```
$ info os.shell.cmd.hello
$ cat os.shell.cmd.hello
$ man hello
```

### Add a route (web endpoint)

Create a route shape and a handler shape:

```
shape os.route.page.mypage {
  type: route
  method: GET
  path: /mypage
  handler: os.handler.page.mypage
  content_type: text/html; charset=utf-8
}

shape os.handler.page.mypage {
  type: handler
  """
  let title = "My Page"
  print("<html><body><h1>" + title + "</h1>")
  print("<p>Shape count: " + len(children("")) + "</p>")
  print("</body></html>")
  """
}
```

### Add a theme

Create shapes under `os.theme.mytheme` with dimensions for `bg`, `fg`, `accent`, `border`, etc. Look at any existing theme (`cat os.theme.nord`) for the pattern.

### Add a test

Tests are shapes that depend on the shapes they test. They auto-run when dependencies change:

```
shape os.test.my.feature : os.test {
  type: test
  layer: 3
  desc: "My feature works correctly"
  """
  assert_eq(1 + 1, 2, "addition works")
  assert_true(exists("law.persistence"), "law exists")
  assert_contains("hello world", "world", "substring found")
  """
}
```

Run it: `test my.feature`

The test result is stored as a constraint on the shape itself. When you `debug` a shape, you see which tests cover it. When you `benchmark`, you see how tests perform across the trace.

## Running locally

### Native (recommended for development)

```bash
git clone https://github.com/grokthis/shape-engine.git
cd shape-engine
make build
./bin/shape
```

### Browser (WASM)

```bash
make wasm
cd web && python3 -m http.server 8080
# Open http://localhost:8080
```

### Hardware tests

```bash
make hw-test    # requires iverilog
```

### Requirements

- Go 1.22+ (zero external dependencies)
- Icarus Verilog (optional, for hardware tests)

## Roadmap

**SDK.** A proper SDK is coming with optimal binary building and packing. Compile shape-lang to native, WASM, or FPGA bitstream from a single source. Broad language support with full cross-compilation: write in any supported language, compile to shapes, run on any substrate.

**Shape Space.** A social network built on Shape OS. Everything you build runs on a shape processor. The platform ships with worldbuilding tools designed into the OS: create worlds, systems, economies, narratives, and share them as shapes that other people can fork, extend, and inhabit.

Shape Space includes several social network alternatives built in. Privacy is structurally enforced: the laws of coherence govern what can reference what. Visibility is a shape dimension, not a policy document. Permissions propagate through the dependency graph. There is no backdoor because there is no layer below the laws.

This is more powerful than the Oasis. You don't just visit someone else's world. You build your own, and everything you build is real infrastructure that runs at gate speed on a shape processor.

The invite list will be drawn from subscribers at [girlwithponytail.com](https://girlwithponytail.com) in reverse tier order.

## License

Shape OS is dual-licensed:

- **Open source**: [GNU General Public License v3](LICENSE) -- free to use, modify, and distribute under GPL terms.
- **Commercial**: Contact ashley@girlwithponytail.com for licensing the shape engine, shape-lang, or Shape OS for commercial use without GPL obligations.
