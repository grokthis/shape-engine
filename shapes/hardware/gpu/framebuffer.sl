// Framebuffer: 2D grid of pixels.
//
// Each pixel IS a shape. The framebuffer IS the shape graph
// projected to a rectangle. Drawing IS creating/editing pixel shapes.
// The display IS reading the framebuffer shapes.
//
// On hardware: a block of memory addressed by (x,y).
// In the engine: shapes under hardware.gpu.fb.X.Y

shape hardware.gpu.framebuffer : hardware.gpu {
  type: unit
  layer: 2
  """
// Framebuffer dimensions.
// Default: 320x240 (quarter VGA).
// Each pixel: "r,g,b" as 0-255 values.
"""
}

shape hardware.gpu.framebuffer.clear : hardware.gpu.framebuffer {
  type: exec
  layer: 2
  """
// Clear the framebuffer to a color.
// color: "r,g,b" string.
let w = to_int(default(width, "320"))
let h = to_int(default(height, "240"))
for y in range(h) {
  for x in range(w) {
    let pid = "hardware.gpu.fb." + to_string(x) + "." + to_string(y)
    if exists(pid) {
      set_content(pid, color)
    } else {
      add_shape(pid, "pixel", color, 2)
    }
  }
}
"""
}

shape hardware.gpu.framebuffer.set_pixel : hardware.gpu.framebuffer {
  type: exec
  layer: 2
  """
// Set a single pixel.
let pid = "hardware.gpu.fb." + to_string(x) + "." + to_string(y)
if exists(pid) {
  set_content(pid, color)
} else {
  add_shape(pid, "pixel", color, 2)
}
"""
}

shape hardware.gpu.framebuffer.get_pixel : hardware.gpu.framebuffer {
  type: exec
  layer: 2
  """
// Read a pixel. Returns "r,g,b" or "0,0,0" if unset.
let pid = "hardware.gpu.fb." + to_string(x) + "." + to_string(y)
if exists(pid) {
  content(pid)
} else {
  "0,0,0"
}
"""
}

shape hardware.gpu.framebuffer.line : hardware.gpu.framebuffer {
  type: exec
  layer: 2
  """
// Draw a line from (x0,y0) to (x1,y1) using Bresenham's algorithm.
// color: "r,g,b"
//
// Bresenham's IS a structural walk: the line IS the shortest path
// between two points on the pixel grid. Each step IS a shape.

let dx = abs(x1 - x0)
let dy = abs(y1 - y0)
let sx = if_val(x0 < x1, 1, 0 - 1)
let sy = if_val(y0 < y1, 1, 0 - 1)
let err = dx - dy
let cx = x0
let cy = y0

while true {
  let pid = "hardware.gpu.fb." + to_string(cx) + "." + to_string(cy)
  if exists(pid) {
    set_content(pid, color)
  } else {
    add_shape(pid, "pixel", color, 2)
  }
  if cx == x1 {
    if cy == y1 {
      break
    }
  }
  let e2 = err * 2
  if e2 > 0 - dy {
    set err = err - dy
    set cx = cx + sx
  }
  if e2 < dx {
    set err = err + dx
    set cy = cy + sy
  }
}
"""
}

shape hardware.gpu.framebuffer.rect : hardware.gpu.framebuffer {
  type: exec
  layer: 2
  """
// Draw a filled rectangle.
for py in range(y, y + h) {
  for px in range(x, x + w) {
    let pid = "hardware.gpu.fb." + to_string(px) + "." + to_string(py)
    if exists(pid) {
      set_content(pid, color)
    } else {
      add_shape(pid, "pixel", color, 2)
    }
  }
}
"""
}

shape hardware.gpu.framebuffer.to_ppm : hardware.gpu.framebuffer {
  type: exec
  layer: 2
  """
// Export framebuffer as PPM image (text format).
// This IS the projection from shapes to image.
let w = to_int(default(width, "320"))
let h = to_int(default(height, "240"))
print("P3")
print(to_string(w) + " " + to_string(h))
print("255")
for y in range(h) {
  let row = ""
  for x in range(w) {
    let pid = "hardware.gpu.fb." + to_string(x) + "." + to_string(y)
    let c = "0 0 0"
    if exists(pid) {
      set c = replace(content(pid), ",", " ")
    }
    if row != "" { set row = row + " " }
    set row = row + c
  }
  print(row)
}
"""
}
