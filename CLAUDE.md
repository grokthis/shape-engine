# Shape Engine

The shape engine is the application of shape theory to itself: a structural editor, version control system, and projection engine unified by one principle — everything is a shape, and shapes transform according to M' = f(C, S).

---

## The Hitch

When building or debugging shapes, the hitch surface when:
- Shapes don't render or show blank content
- Render chains break (launcher → window → content)
- References fail silently (Law 1: all references must close)
- Content appears from nowhere or disappears (Law 2: conservation)

The hitch is the friction you feel when structure doesn't cohere. Use it.

---

## Shape Language Primer

The shape language (.sl files) is how you declare and compose shapes. Every .sl file declares one or more shapes. The language is declarative and evaluative: shape definitions ARE the program.

### Shape Declaration

```
shape os.app.browser : os {
  type: app
  name: Browser
  icon: {}
  category: system
  layer: 5
  render: browser          # optional: points to render target
  "Browse the shape graph."
}
```

**Structure**:
- `shape ID : parent { ... }` — declares a shape with hierarchical ID
- `type`, `category`, `layer` — metadata (searchable dimensions)
- String literals become content
- Key-value pairs become dimensions (character fields)
- `:` creates parent/child relationship

### Rendering Shapes

Shapes render through three mandatory projections:

```
shape os.render.browser.style {
  """CSS rules for browser window content"""
}

shape os.render.browser.body {
  """HTML/structure for window content"""
}

shape os.render.browser.script {
  """JavaScript for interactivity"""
}
```

When a window opens, the desktop handler (`os.handler.page.desktop`) calls:
```
let render_name = dim("os.app.shell", "render")
let app_body = render("os.render." + render_name + ".body")
```

**This is where blank windows come from**: if these shapes don't exist or return empty strings, the window has no content.

### Evaluation: the Program Layer

Shapes with content wrapped in `"""..."""` contain evaluable code. When you `render()` a shape, that code runs:

```
shape os.handler.page.desktop {
  type: handler
  layer: 5
  """
  let title = content("os.config.window.title")
  print("<html>...")
  for ws_name in ["1", "2", "3"] {
    let ws_id = "os.desktop.workspace." + ws_name
    if exists(ws_id) {
      print("<div>workspace " + ws_name + "</div>")
    }
  }
  """
}
```

The evaluator runs in-engine. The three stages:
1. **Parse**: text → AST
2. **Eval**: AST executes against engine, calling builtins
3. **Output**: accumulated print() calls become the rendered string

### Builtin Functions (Syscall Interface)

These are the boundary between shape machine (Go) and userspace (shape-lang):

| Function | Returns |
|----------|---------|
| `exists(shape_id)` | bool: shape exists in engine |
| `content(shape_id)` | string: the shape's character content |
| `dim(shape_id, dimension)` | string: a specific dimension value |
| `deps(shape_id)` | list: dependency IDs |
| `shapes_under(prefix)` | list: all shapes matching prefix |
| `render(shape_id)` | string: evaluate that shape's code |
| `print(text)` | void: accumulate to output |
| `split(string, sep)` | list: split by separator |
| `shape_count()` | int: total shapes in engine |
| `global_tick()` | int: current engine tick |

### Conditional Rendering

```
if exists("os.app.browser") {
  let body = render("os.render.browser.body")
  if body != "" {
    print(body)
  }
}
```

This pattern is critical: **check existence before rendering**. If you don't check and the shape doesn't exist, the render silently fails and returns empty string.

---

## Debug Capability: Tracing Content Flow

The engine has a **Debug flag** that logs every builtin operation:

```go
eng.Debug = true  // Enable in cmd/shape/main.go
```

When enabled, stderr shows:
```
[DEBUG] render("os.render.browser.body") -> "..."
[DEBUG] exists("os.app.shell") -> true
[DEBUG] content("os.config.launcher.pins") -> "browser,editor"
```

To debug blank windows:

1. **Enable debug mode** in main.go:
   ```go
   eng.Debug = true
   ```

2. **Run and watch stderr** for the render chain:
   ```bash
   go run ./cmd/shape/main.go 2>&1 | grep "render\|exists"
   ```

3. **Trace the break point**:
   - `render("os.handler.page.desktop")` completes ✓
   - `render("os.render.browser.body")` returns empty string ✗
   - Check: does `os.render.browser.body` exist?
   - Check: what's its content?

4. **Read the shape**:
   ```bash
   go run ./cmd/cuivien/main.go show os.render.browser.body
   ```

5. **Test rendering directly**:
   ```
   # In the shape REPL
   render("os.render.browser.body")
   ```

---

## Render Chain: Window Opening

From launcher click to content in window:

1. **Launcher handler** (`os.handler.page.launcher`) processes app click
2. **Window creation** (`os.desktop.workspace.N`) gets a new window child with `type: window` and `app: browser`
3. **Desktop handler** (`os.handler.page.desktop`) re-renders
4. **For each window**, calls:
   ```
   let render_name = dim("os.app." + app, "render")  // "browser"
   let app_body = render("os.render.browser.body")  // <-- this must exist
   print(app_body)                                   // render into window
   ```

**Blank window diagnosis**:
- Step 1: Window shape created? Check `os.desktop.workspace.1` has children
- Step 2: App render target correct? Check `dim("os.app.browser", "render")`
- Step 3: Render shapes exist? Check `os.render.browser.{style,body,script}`
- Step 4: Render shapes have content? Check `content("os.render.browser.body")`
- Step 5: Rendering succeeds? Enable debug, watch stderr

---

## Dimensions: Querying Shapes

Shapes live in dimensional space. Query them by dimension:

```
dim(shape_id, "type")       # Returns "app", "config", "handler", etc.
dim(shape_id, "layer")      # Returns emergence layer (0-6)
dim(shape_id, "category")   # Returns app category
```

For the launcher, this powers filtering:
```
let all_shapes = shapes_under("os.app.")
for app_sh in all_shapes {
  let app_type = dim(app_sh, "type")
  if app_type == "app" {
    // list this app
  }
}
```

---

## Emergence Layers

Shapes exist at layers 0-6, each with distinct role:

| Layer | Purpose |
|-------|---------|
| 0 | Foundation: engine, transforms, core shapes |
| 1 | Config: system settings (desktop theme, window manager, launcher setup) |
| 2 | Session: per-session state (active workspace, window list) |
| 3 | Desktop: static desktop structure (workspaces, window manager) |
| 4 | Handler: page handlers that render the UI (desktop, launcher) |
| 5 | App/Content: application shapes and their render targets |
| 6 | Projection: output (PDFs, exports, live views) |

When building: config lives at layer 1, apps at layer 5, handlers at layer 4.

---

## Fixing Blank Windows: Checklist

You're debugging blank windows. They open but show no content. Follow this:

1. **Enable debug mode** → watch render calls
2. **Trace render chain** → which call returns empty?
3. **Check existence** → does the shape exist?
4. **Check content** → does it have content or just metadata?
5. **Test render directly** → run `render(shape_id)` manually
6. **Verify hierarchy** → is the render shape in the right namespace?

The issue is almost always: a render shape is missing or has empty content.

---

## Current Status

The start menu system was just added. Windows open (✓) but content doesn't render (✗).

The render chain is: **launcher-click → window-shape → render("os.render.APP.body")**

**Next step**: Check whether the `os.render.*` shapes exist and have content. Use debug mode to trace the break.

