// Editor: the worldbuilding tools.
//
// The editor IS part of the world. There is no distinction between
// the tool and the content. Editing a world IS editing shapes.
// The editor shapes ARE shapes in the world.
// You can edit the editor from within the editor.
//
// This is the worldbuilding OS. Not an application that runs on the OS.
// The OS IS the worldbuilding tool IS the world.

shape world.editor : world {
  type: system
  layer: 5
  deps: [world.scene, world.entity, world.terrain, world.physics, hardware.gpu, hardware.audio, hardware.input]
  "The worldbuilding editor. Tools are shapes. Worlds are shapes. Everything is interactive."
}

shape world.editor.select : world.editor {
  type: exec
  layer: 5
  """
// Select an entity or shape in the world.
// Click on it (via raycast from mouse to scene) or name it directly.
// Selected shape becomes the focus of all editing tools.
set_dim("world.editor.state", "selected", target)
print("Selected: " + target)
"""
}

shape world.editor.move : world.editor {
  type: exec
  layer: 5
  """
// Move the selected entity to a new position.
let sel = dim("world.editor.state", "selected")
if sel != "" {
  let tid = sel + ".transform"
  if exists(tid) {
    set_dim(tid, "position", to_string(x) + "," + to_string(y) + "," + to_string(z))
    print("Moved " + sel + " to " + to_string(x) + "," + to_string(y) + "," + to_string(z))
  }
}
"""
}

shape world.editor.spawn : world.editor {
  type: exec
  layer: 5
  """
// Spawn a new entity in the world.
// type: "cube", "sphere", "light", "camera", "empty"
// name: entity name

if type == "cube" {
  // Create entity with transform + mesh + physics.
  let eid = "world.entity." + name
  add_shape(eid, "entity", "", 5)
  add_shape(eid + ".transform", "component", "", 5)
  set_dim(eid + ".transform", "position", default(at, "0,0,0"))
  set_dim(eid + ".transform", "scale", "1,1,1")
  add_shape(eid + ".mesh", "component", "", 5)
  set_dim(eid + ".mesh", "type", "cube")
  set_dim(eid + ".mesh", "color", default(color, "128,128,255"))
  print("Spawned cube: " + name)
} else if type == "light" {
  let eid = "world.entity." + name
  add_shape(eid, "entity", "", 5)
  add_shape(eid + ".transform", "component", "", 5)
  set_dim(eid + ".transform", "position", default(at, "0,10,0"))
  add_shape(eid + ".light", "component", "", 5)
  set_dim(eid + ".light", "type", "point")
  set_dim(eid + ".light", "color", default(color, "255,255,255"))
  set_dim(eid + ".light", "intensity", "100")
  print("Spawned light: " + name)
} else if type == "camera" {
  let eid = "world.entity." + name
  add_shape(eid, "entity", "", 5)
  add_shape(eid + ".transform", "component", "", 5)
  set_dim(eid + ".transform", "position", default(at, "0,5,-10"))
  add_shape(eid + ".camera", "component", "", 5)
  set_dim(eid + ".camera", "fov", "60")
  print("Spawned camera: " + name)
} else {
  let eid = "world.entity." + name
  add_shape(eid, "entity", "", 5)
  add_shape(eid + ".transform", "component", "", 5)
  set_dim(eid + ".transform", "position", default(at, "0,0,0"))
  print("Spawned empty: " + name)
}
"""
}

shape world.editor.inspect : world.editor {
  type: exec
  layer: 5
  """
// Inspect an entity: show all components and their values.
let eid = default(target, dim("world.editor.state", "selected"))
if eid == "" {
  print("Nothing selected")
} else {
  if !exists(eid) {
    print("Entity not found: " + eid)
  } else {
    print("Entity: " + eid)
    let comps = children(eid)
    for comp in comps {
      let cid = eid + "." + comp
      print("  " + comp + ":")
      let d = dims(cid)
      if d != "" {
        let lines = split(d, "\n")
        for line in lines {
          print("    " + line)
        }
      }
      let c = content(cid)
      if c != "" {
        print("    content: " + c)
      }
    }
  }
}
"""
}
