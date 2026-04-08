// Shape OS — persistence instantiated.
//
// The namespace IS the derivation. Laws at root, everything derives upward.
// Navigate from / to see the entire system. Every piece of running
// infrastructure is visible, introspectable, and (above the engine layer)
// editable from within.
//
// Below engine.lang.syscall is Go — the shape machine emulation layer.
// Above it is shape-lang. Edit any shape to change the OS.

// ==========================================================================
// Layer 0 — Laws of Coherence
// ==========================================================================
// The root of everything. The laws describe the structure of persistence.
// Their content IS shape-lang encoding their behavior. On a real shape
// machine, these would execute directly. Here, the Go engine emulates them.

shape law {
  type: axiom
  layer: 0
  "The laws of coherence. Everything derives from here."
}

shape law.persistence : law {
  type: law
  layer: 0
  """
// Law 0: A shape persists stably only if its structure is coherent.
// Incoherent shapes dissolve. This is the axiom.
//
// The engine implements this as: validate() checks all shapes,
// edit() propagates waves to maintain coherence after mutation,
// the store persists only what the engine holds.
//
// On a shape machine, this law IS the persistence mechanism.
// In emulation, engine.validate + engine.store implement it.
fn check_persistence(id) {
  if !exists(id) {
    absorb
  }
  let dp = deps(id)
  for dep in dp {
    if !exists(dep) {
      flag
    }
  }
  auto "persists"
}
"""
}

shape law.reference : law {
  type: law
  layer: 0
  """
// Law 1: References must close, point to invariants, or be bounded.
// Dangling references are incoherent. The engine tracks all deps
// and validates reference closure.
//
// engine.propagate implements this: when a shape changes, the wave
// follows references to maintain closure. Dependents must respond.
fn check_reference(id) {
  let dp = deps(id)
  for dep in dp {
    if !exists(dep) {
      flag
    }
  }
  auto "references close"
}
"""
}

shape law.conservation : law {
  type: law
  layer: 0
  """
// Law 2: No structure from nothing, no destruction into nothing.
// You cannot remove a shape that others depend on.
// You cannot create a shape without the system recording it.
// Every mutation advances the tick. Every change is traced.
//
// engine.trace implements conservation of history.
// rm checks dependents before allowing removal.
fn check_conservation(id) {
  if !exists(id) {
    flag
  }
  auto "conserved"
}
"""
}

shape law.consistency : law {
  type: law
  layer: 0
  """
// Law 3: Coupled incompatible shapes must resolve or trigger dissolution.
// Contradictions in contact cannot persist. The engine resolves this
// through block (withdraw permission) and propagation (force resolution).
//
// engine.block implements this: when an author is blocked, existing
// shapes persist (Law 2) but get flagged with content warnings.
// The wave propagates the inconsistency until it resolves.
fn check_consistency(id) {
  let dt = dependents(id)
  for dep in dt {
    let w = dim(dep, "warning")
    if w != "" {
      flag
    }
  }
  auto "consistent"
}
"""
}

// ==========================================================================
// Layer 0 — Shape Primitive
// ==========================================================================
// What the laws operate on. The irreducible unit of persistence.

shape shape {
  type: axiom
  layer: 0
  "The irreducible primitive. ID + Character + Structure + Tick. Everything is a shape."
}

shape shape.character : shape {
  type: type
  layer: 0
  "What changes: dimensions (coordinates in shape space) + content. The mutable part."
}

shape shape.structure : shape {
  type: type
  layer: 0
  "The geometry governing transformation. Deps, emergence layer, permissions. The invariant skeleton."
}

shape shape.tick : shape {
  type: type
  layer: 0
  "Global tick at last modification. Structural position in time, not a timestamp."
}

// ==========================================================================
// Layer 1 — Trace
// ==========================================================================
// Conservation of history. Every mutation recorded.

shape engine.trace : shape {
  type: type
  layer: 1
  "Records the history of changes. Every edit leaves a trace. Branches, locks, audit trail."
}

// ==========================================================================
// Layer 2 — Store + Transform
// ==========================================================================
// Persistence to disk and transformation machinery.

shape engine.store : shape, engine.trace {
  type: type
  layer: 2
  "Persists the entire graph as a single binary file. One file = all state. Atomic writes."
}

shape engine.transform : shape {
  type: type
  layer: 2
  "Maps transform function names to implementations. AutoUpdate / FlagForReview / NoChange."
}

// ==========================================================================
// Layer 3 — Engine
// ==========================================================================
// The laws running. Composition of shape + laws + trace + store.

shape engine : shape, law, engine.trace, engine.store, engine.transform {
  type: system
  layer: 3
  "The composition layer. The laws of coherence, running. Holds the global tick and dependency index."
}

shape engine.edit : engine {
  type: func
  layer: 3
  "Modifies a shape's character, advances tick, records trace, propagates wave. One atomic operation."
}

shape engine.propagate : engine {
  type: func
  layer: 3
  "Recursively propagates the wave through dependents. AutoUpdate/FlagForReview/NoChange/Locked. Never deadlocks."
}

shape engine.validate : engine, law {
  type: func
  layer: 3
  "Checks all four laws across the entire graph. Returns coherent or lists violations."
}

shape engine.block : engine, law.consistency {
  type: func
  layer: 3
  "Withdraws permission for an author. Existing shapes persist (Law 2) but get flagged (Law 3)."
}

shape engine.report : engine.edit, engine.propagate {
  type: type
  layer: 3
  "Result of an edit: the wave. Tick, AutoUpdated, FlaggedForReview, Locked, Withdrawn."
}

// ==========================================================================
// Layer 3 — Language (laws encoded as executable behavior)
// ==========================================================================
// shape-lang: the laws made into a programming language.
// The evaluator IS the laws running on programs.

shape engine.lang : engine, law {
  type: system
  layer: 3
  "shape-lang. The laws of coherence encoded as a programming language. Programs ARE shapes."
}

shape engine.lang.parse : engine.lang {
  type: func
  layer: 3
  "Lexer + parser. Source text → AST. Tokens: ident, string, int, operators. Shape declarations, fn definitions, edit/let/set/if/for/auto/flag/absorb."
}

shape engine.lang.eval : engine.lang {
  type: func
  layer: 3
  "Evaluator. AST → shape mutations + output. Programs decompose into the graph. Execution IS wave propagation."
}

shape engine.lang.syscall : engine.lang {
  type: system
  layer: 3
  """
// The kernel interface. Everything below this is Go (the shape machine).
// Everything above can be rewritten in shape-lang.
//
// Shape I/O:    content, dim, dims, deps, dependents, layer, from,
//               produces, ancestry, depth, tick, exists, children,
//               shapes_under, shape_count
// Mutation:     add_shape, remove, set_content, set_dim
// Strings:      contains, split, join, has_prefix, has_suffix, replace,
//               trim, repeat, substr, upper, lower, pad_right
// Lists:        len, sort_list, append, head, tail, index, range
// Control:      default, if_val
// Types:        type, to_int, to_string
// Paths:        resolve, parent
// Output:       print, write
// Engine:       validate, status
"""
}

// ==========================================================================
// Layer 4 — Operating System
// ==========================================================================
// Everything above the engine. Written in shape-lang. Editable from within.

shape os {
  type: system
  layer: 4
  "Shape OS. Everything above the engine is shape-lang. Edit any shape to change the OS."
}

shape os.shell : os {
  type: system
  layer: 4
  "The shell subsystem. REPL, commands, piping, session."
}

shape os.shell.cmd : os.shell {
  type: system
  layer: 4
  "Shell commands. Each child is an executable shape. Type the name to run it."
}

// --- Navigation ---

shape os.shell.cmd.pwd {
  type: exec
  layer: 4
  """
print(prefix)
"""
}

shape os.shell.cmd.cd {
  type: exec
  layer: 4
  """
let target = default(arg0, "~")
let resolved = resolve(prefix, target)
set_content("os.session.shell.prefix", resolved)
"""
}

shape os.shell.cmd.ls {
  type: exec
  layer: 4
  """
let target = default(arg0, prefix)
if arg0 != "" {
  set target = resolve(prefix, arg0)
}
let segs = sort_list(children(target))
let w = max_len(segs) + 2
if w < 16 {
  set w = 16
}
let hdr = content("os.config.headers")
if hdr != "off" {
  print(pad_right("NAME", w) + pad_right("TYPE", 10) + "LAYER")
  print(repeat("-", w + 16))
}
for seg in segs {
  let full = if_val(target == "", seg, target + "." + seg)
  let t = dim(full, "type")
  let sub = children(full)
  if t != "" {
    let line = pad_right(seg, w) + pad_right(t, 10)
    let l = layer(full)
    if l > 0 {
      set line = line + l
    }
    print(line)
  } else if len(sub) > 0 {
    print(pad_right(seg + "/", w) + "(" + len(sub) + " children)")
  } else {
    print(seg)
  }
}
"""
}

shape os.shell.cmd.tree {
  type: exec
  layer: 4
  """
fn tree_walk(pfx, depth, col) {
  let segs = sort_list(children(pfx))
  for seg in segs {
    let full = if_val(pfx == "", seg, pfx + "." + seg)
    let indent = repeat("  ", depth)
    let t = dim(full, "type")
    let marker = if_val(exists(full), "◇ ", "▸ ")
    let name = indent + marker + seg
    if t != "" {
      print(pad_right(name, col) + t)
    } else {
      print(name + "/")
    }
    tree_walk(full, depth + 1, col)
  }
  absorb
}
let target = default(arg0, prefix)
if arg0 != "" {
  set target = resolve(prefix, arg0)
}
tree_walk(target, 0, 32)
"""
}

shape os.shell.cmd.find {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("find: missing pattern")
} else {
  let all = shapes_under("")
  for id in sort_list(all) {
    if contains(id, arg0) {
      print(id)
    }
  }
}
"""
}

shape os.shell.cmd.grep {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("grep: missing pattern")
} else {
  let target = default(arg1, prefix)
  let all = shapes_under(target)
  for id in sort_list(all) {
    let c = content(id)
    if contains(c, arg0) {
      print(id + ": " + c)
    }
  }
}
"""
}

// --- Shape Operations ---

shape os.shell.cmd.cat {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("cat: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let c = content(id)
    let d = dims(id)
    if d != "" {
      print(d)
    }
    if c != "" {
      if d != "" {
        print("---")
      }
      print(c)
    }
  }
}
"""
}

shape os.shell.cmd.info {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("info: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    print(pad_right("ID:", 14) + id)
    print(pad_right("Tick:", 14) + tick(id))
    print(pad_right("Layer:", 14) + layer(id))
    print(pad_right("Depth:", 14) + depth(id))
    print("")
    let d = dims(id)
    if d != "" {
      print("Dimensions:")
      for line in split(d, "\n") {
        print("  " + line)
      }
    }
    let c = content(id)
    if c != "" {
      print("Content:")
      for line in split(c, "\n") {
        print("  " + line)
      }
    }
    print("")
    let hdr = content("os.config.headers")
    let dp = deps(id)
    if len(dp) > 0 {
      print("Deps:")
      let w = max_len(dp) + 2
      if hdr != "off" {
        print("  " + pad_right("ID", w) + "TYPE")
        print("  " + repeat("-", w + 10))
      }
      for dep in dp {
        let t = dim(dep, "type")
        print("  " + pad_right(dep, w) + if_val(t != "", t, ""))
      }
    }
    let dt = dependents(id)
    if len(dt) > 0 {
      print("Dependents:")
      let w = max_len(dt) + 2
      if hdr != "off" {
        print("  " + pad_right("ID", w) + "TYPE")
        print("  " + repeat("-", w + 10))
      }
      for dep in dt {
        let t = dim(dep, "type")
        print("  " + pad_right(dep, w) + if_val(t != "", t, ""))
      }
    }
  }
}
"""
}

shape os.shell.cmd.mkdir {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("mkdir: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  add_shape(id, "", "")
  print(id)
}
"""
}

shape os.shell.cmd.rm {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("rm: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let dt = dependents(id)
    if len(dt) > 0 {
      print("rm: " + id + " has " + len(dt) + " dependents (Law 2)")
    } else {
      remove(id)
      print("removed: " + id)
    }
  }
}
"""
}

shape os.shell.cmd.cp {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("cp: need <src> <dst>")
} else if arg1 == "" {
  print("cp: need <dst>")
} else {
  let src = resolve(prefix, arg0)
  let dst = resolve(prefix, arg1)
  if !exists(src) {
    print("shape not found: " + src)
  } else {
    let t = dim(src, "type")
    let c = content(src)
    let l = layer(src)
    add_shape(dst, t, c, l)
    print(src + " -> " + dst)
  }
}
"""
}

shape os.shell.cmd.mv {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("mv: need <src> <dst>")
} else if arg1 == "" {
  print("mv: need <dst>")
} else {
  let src = resolve(prefix, arg0)
  let dst = resolve(prefix, arg1)
  if !exists(src) {
    print("shape not found: " + src)
  } else {
    let dt = dependents(src)
    if len(dt) > 0 {
      print("mv: " + src + " has dependents, cannot move (Law 2)")
    } else {
      let t = dim(src, "type")
      let c = content(src)
      let l = layer(src)
      add_shape(dst, t, c, l)
      remove(src)
      print(src + " -> " + dst)
    }
  }
}
"""
}

shape os.shell.cmd.echo {
  type: exec
  layer: 4
  """
print(args)
"""
}

shape os.shell.cmd.edit {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("edit: need <shape-id> <content>")
} else if arg1 == "" {
  print("edit: need content after shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    set_content(id, arg1)
    print("edited: " + id)
  }
}
"""
}

// --- Graph Operations ---

shape os.shell.cmd.deps {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("deps: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  let dp = deps(id)
  if len(dp) == 0 {
    print("(no dependencies)")
  } else {
    let w = max_len(dp) + 2
    let hdr = content("os.config.headers")
    if hdr != "off" {
      print("  " + pad_right("", 5) + pad_right("DEP", w) + "TYPE")
      print("  " + repeat("-", w + 16))
    }
    for dep in dp {
      let t = dim(dep, "type")
      print("  -> " + pad_right(dep, w) + if_val(t != "", t, ""))
    }
  }
}
"""
}

shape os.shell.cmd.dependents {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("dependents: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  let dt = dependents(id)
  if len(dt) == 0 {
    print("(no dependents)")
  } else {
    let w = max_len(dt) + 2
    let hdr = content("os.config.headers")
    if hdr != "off" {
      print("  " + pad_right("", 5) + pad_right("DEPENDENT", w) + "TYPE")
      print("  " + repeat("-", w + 16))
    }
    for dep in dt {
      let t = dim(dep, "type")
      print("  <- " + pad_right(dep, w) + if_val(t != "", t, ""))
    }
  }
}
"""
}

shape os.shell.cmd.wave {
  type: exec
  layer: 4
  """
fn wave_walk(id, depth, visited) {
  let dt = dependents(id)
  for dep in dt {
    if !(dep in visited) {
      let indent = repeat("  ", depth)
      let fn_name = dim(dep, "fn")
      let label = if_val(fn_name != "", " [" + fn_name + "]", "")
      print(indent + "-> " + dep + label)
      set visited = append(visited, dep)
      wave_walk(dep, depth + 1, visited)
    }
  }
  absorb
}

if arg0 == "" {
  print("wave: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  print("Wave from " + id + ":")
  let visited = [id]
  wave_walk(id, 1, visited)
}
"""
}

shape os.shell.cmd.validate {
  type: exec
  layer: 4
  """
print(validate())
"""
}

shape os.shell.cmd.status {
  type: exec
  layer: 4
  """
print(status())
"""
}

shape os.shell.cmd.tick {
  type: exec
  layer: 4
  """
print(tick())
"""
}

shape os.shell.cmd.trace {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("trace: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    print(id + ": layer " + layer(id) + ", tick " + tick(id))
  }
}
"""
}

// --- Shell / Session ---

shape os.shell.cmd.env {
  type: exec
  layer: 4
  """
let d = dims("os.session.shell.env")
if d == "" {
  print("(no environment variables)")
} else {
  print(d)
}
"""
}

shape os.shell.cmd.export {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("export: need KEY=VALUE")
} else {
  let parts = split(arg0, "=")
  if len(parts) < 2 {
    print("export: need KEY=VALUE")
  } else {
    let key = index(parts, 0)
    let val = index(parts, 1)
    set_dim("os.session.shell.env", key, val)
    print(key + "=" + val)
  }
}
"""
}

shape os.shell.cmd.history {
  type: exec
  layer: 4
  """
let h = content("os.session.shell.history")
if h == "" {
  print("(no history)")
} else {
  let lines = split(h, "\n")
  let i = 0
  let total = len(lines)
  let w = len(to_string(total))
  if w < 3 {
    set w = 3
  }
  let hdr = content("os.config.headers")
  if hdr != "off" {
    print(pad_left("#", w) + "  COMMAND")
    print(repeat("-", w + 30))
  }
  for line in lines {
    if line != "" {
      set i = i + 1
      print(pad_left(to_string(i), w) + "  " + line)
    }
  }
}
"""
}

shape os.shell.cmd.alias {
  type: exec
  layer: 4
  """
if arg0 == "" {
  let d = dims("os.session.shell.aliases")
  if d == "" {
    print("(no aliases)")
  } else {
    print(d)
  }
} else {
  let parts = split(arg0, "=")
  if len(parts) < 2 {
    print("alias: need NAME=COMMAND")
  } else {
    let name = index(parts, 0)
    let cmd = index(parts, 1)
    set_dim("os.session.shell.aliases", name, cmd)
    print(name + " -> " + cmd)
  }
}
"""
}

shape os.shell.cmd.clear {
  type: exec
  layer: 4
  """
write("\033[2J\033[H")
"""
}

shape os.shell.cmd.run {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("run: need shape-lang source or shape-id")
} else {
  if exists(resolve(prefix, arg0)) {
    let src = content(resolve(prefix, arg0))
    print("(executing " + resolve(prefix, arg0) + ")")
  }
}
"""
}

// --- Remote (stubs) ---

shape os.shell.cmd.connect {
  type: exec
  layer: 4
  """
print("connect: not yet implemented (needs HTTP client)")
"""
}

shape os.shell.cmd.pull {
  type: exec
  layer: 4
  """
print("pull: not yet implemented (needs remote connection)")
"""
}

shape os.shell.cmd.push {
  type: exec
  layer: 4
  """
print("push: not yet implemented (needs remote connection)")
"""
}

shape os.shell.cmd.lock {
  type: exec
  layer: 4
  """
print("lock: not yet connected to trace layer")
"""
}

shape os.shell.cmd.unlock {
  type: exec
  layer: 4
  """
print("unlock: not yet connected to trace layer")
"""
}

shape os.shell.cmd.branch {
  type: exec
  layer: 4
  """
print("branch: not yet connected to trace layer")
"""
}

// --- Ancestry / Viewer ---

shape os.shell.cmd.ancestry {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("ancestry: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let chain = ancestry(id)
    let d = depth(id)
    print(id + " (depth " + d + ")")
    print("")
    let path = id
    for ancestor in chain {
      let name = if_val(ancestor == "", "/", ancestor)
      let t = ""
      if exists(ancestor) {
        set t = " [" + dim(ancestor, "type") + "]"
      }
      print("  " + name + t)
    }
  }
}
"""
}

shape os.shell.cmd.open {
  type: exec
  layer: 4
  """
if arg0 == "" {
  navigate("/")
} else if arg0 == "desktop" {
  navigate("/desktop")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    // Try as a prefix tree
    navigate("/tree/" + id)
  } else {
    navigate("/s/" + id)
  }
}
"""
}

shape os.shell.cmd.view {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("view: missing shape-id")
} else {
  let id = resolve(prefix, arg0)
  if !exists(id) {
    print("shape not found: " + id)
  } else {
    let d = depth(id)
    let chain = ancestry(id)
    let t = dim(id, "type")
    let l = layer(id)
    let tk = tick(id)
    let dp = deps(id)
    let dt = dependents(id)
    let ch = children(id)
    let c = content(id)

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("  " + id)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("")

    let meta = ""
    if t != "" {
      set meta = meta + "[" + t + "]  "
    }
    set meta = meta + "layer " + l + "  depth " + d + "  tick " + tk
    print("  " + meta)
    print("")

    print("  Derivation:")
    let breadcrumb = ""
    let i = len(chain)
    for ancestor in chain {
      set i = i - 1
      let name = if_val(ancestor == "", "⊙", ancestor)
      set breadcrumb = breadcrumb + name + " → "
    }
    set breadcrumb = breadcrumb + id
    print("    " + breadcrumb)
    print("")

    if c != "" {
      print("  Content:")
      print("  ┌──────────────────────────────────────────────────────")
      for line in split(c, "\n") {
        print("  │ " + line)
      }
      print("  └──────────────────────────────────────────────────────")
      print("")
    }

    let dm = dims(id)
    if dm != "" {
      print("  Dimensions:")
      for line in split(dm, "\n") {
        if line != "" {
          print("    " + line)
        }
      }
      print("")
    }

    if len(dp) > 0 {
      print("  Dependencies (" + len(dp) + "):")
      for dep in dp {
        let dt2 = dim(dep, "type")
        print("    → " + dep + if_val(dt2 != "", "  " + dt2, ""))
      }
      print("")
    }

    if len(dt) > 0 {
      print("  Dependents (" + len(dt) + "):")
      for dep in dt {
        let dt2 = dim(dep, "type")
        print("    ← " + dep + if_val(dt2 != "", "  " + dt2, ""))
      }
      print("")
    }

    if len(ch) > 0 {
      print("  Children (" + len(ch) + "):")
      for seg in sort_list(ch) {
        let full = id + "." + seg
        let ct = dim(full, "type")
        print("    ◇ " + seg + if_val(ct != "", "  " + ct, ""))
      }
      print("")
    }

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  }
}
"""
}

// --- Config ---

shape os.shell.cmd.config {
  type: exec
  layer: 4
  """
if arg0 == "" {
  print("Configuration (os.config.*)")
  print("")
  let segs = sort_list(children("os.config"))
  let w = max_len(segs) + 2
  if w < 12 {
    set w = 12
  }
  print(pad_right("OPTION", w) + "VALUE")
  print(repeat("-", w + 12))
  for seg in segs {
    let full = "os.config." + seg
    let val = content(full)
    print(pad_right(seg, w) + val)
  }
  print("")
  print("Usage: config <option> [value]")
} else if arg1 == "" {
  let full = "os.config." + arg0
  if !exists(full) {
    print("unknown config: " + arg0)
  } else {
    print(arg0 + " = " + content(full))
  }
} else {
  let full = "os.config." + arg0
  if !exists(full) {
    add_shape(full, "config", arg1, 4)
  } else {
    set_content(full, arg1)
  }
  print(arg0 + " = " + arg1)
}
"""
}

// --- Help ---

shape os.shell.cmd.help {
  type: exec
  layer: 4
  """
print("Shape Shell — everything is a shape")
print("")
print("Navigation:")
print("  pwd                  Print current prefix")
print("  cd <prefix>          Change prefix (.. to go up, / for root)")
print("  ls [prefix]          List shapes at prefix")
print("  tree [prefix]        Recursive tree view")
print("  find <pattern>       Search shapes by ID")
print("")
print("Shape Operations:")
print("  cat <id>             Show shape content and dimensions")
print("  info <id>            Full shape dump")
print("  mkdir <id>           Create empty shape")
print("  rm <id>              Delete shape (if no dependents)")
print("  cp <src> <dst>       Clone shape")
print("  mv <src> <dst>       Move shape")
print("  echo text > <id>     Set shape content")
print("  edit <id> <content>  Edit shape content, propagate wave")
print("  grep <pattern>       Search shape content")
print("  open <id>            Full shape viewer with ancestry and stats")
print("  ancestry <id>        Show derivation chain to axiom")
print("")
print("Graph Operations:")
print("  deps <id>            Show dependencies")
print("  dependents <id>      Show reverse dependencies")
print("  wave <id>            Show propagation path")
print("  validate             Run coherence check")
print("  status               Engine status")
print("  tick                 Global tick counter")
print("")
print("Language:")
print("  run <source|id>      Execute shape-lang")
print("  <name>               Run executable shape (type: exec)")
print("  <name>               Display content shape (default)")
print("")
print("Shell:")
print("  env / export K=V     Environment variables")
print("  history / alias k=v  History and aliases")
print("  config [key] [val]   OS configuration (e.g. config headers off)")
print("  clear / help         Clear screen / this message")
print("")
print("Piping: ls | grep edit | cat")
print("All commands are shapes under os.shell.cmd.* — edit them to change the OS.")
"""
}

// ==========================================================================
// User Space
// ==========================================================================
// The filesystem root sits here. Your home directory.
// Navigate up (cd ..) toward the axioms. Navigate down into your work.

shape user : os {
  type: space
  layer: 5
  "Your workspace. Everything you create lives here. cd .. to explore the system beneath."
}

// ==========================================================================
// Configuration
// ==========================================================================
// OS-level preferences. Persisted. Edit from shell or browser.

shape os.config {
  type: system
  layer: 4
  "OS configuration. Persistent preferences."
}

shape os.config.headers : os.config {
  type: config
  layer: 4
  "on"
}

// ==========================================================================
// Session State
// ==========================================================================
// All OS state lives here. Persisted in the shape file. Survives restart.

shape os.session {
  type: system
  layer: 4
  "Session state. All OS state persisted as shapes."
}

shape os.session.shell {
  type: system
  layer: 4
  "Shell session state."
}

// ==========================================================================
// Server (layer 4)
// ==========================================================================

shape os.server : engine {
  type: system
  layer: 4
  "HTTP server. GET/POST shapes, SSE event stream, WebSocket terminal. The network interface to the engine."
}

// ==========================================================================
// Render (layer 4)
// ==========================================================================

shape os.render : engine {
  type: system
  layer: 4
  "Shapes → HTML/CSS. Element shapes become tags. Style shapes become CSS. The visual projection of the graph."
}

// ==========================================================================
// Layer 5 — Applications
// ==========================================================================

shape app : os {
  type: system
  layer: 5
  "Applications. Each app is a set of shapes + a render function."
}

shape app.browser : app, os.render {
  type: app
  layer: 5
  "Shape browser. Three-pane view: tree / detail / references. The graph made navigable."
}

shape app.desktop : app, os.render {
  type: app
  layer: 5
  "Desktop environment. Tiling window manager, workspaces, status bar. All state is shapes."
}
