// 3D rendering pipeline as shapes.
//
// The pipeline IS a chain of structural transforms:
//   Model space -> World space -> View space -> Clip space -> Screen space -> Pixels
//
// Each stage IS a shape. Each triangle flows through the chain.
// The pipeline IS wave propagation: a change to the camera
// propagates through view -> clip -> screen -> pixels.

shape hardware.gpu.pipeline : hardware.gpu {
  type: system
  layer: 3
  deps: [hardware.gpu.math, hardware.gpu.framebuffer]
  """
// 3D pipeline stages:
//   1. Vertex transform: model * view * projection
//   2. Triangle assembly: group vertices into triangles
//   3. Clipping: discard triangles outside view frustum
//   4. Screen mapping: NDC to pixel coordinates
//   5. Rasterization: fill triangle pixels
//   6. Fragment shading: compute pixel color
//   7. Framebuffer write: store pixels
"""
}

shape hardware.gpu.pipeline.triangle : hardware.gpu.pipeline {
  type: exec
  layer: 3
  """
// Rasterize a 2D triangle (already screen-space).
// v0, v1, v2: "x,y" screen coordinates.
// color: "r,g,b"
//
// Uses scanline rasterization: for each row, find the left and right
// edge intersections, fill the span.
//
// The triangle IS three edges. Each edge IS a line.
// Rasterization IS walking the edges simultaneously.

let p0 = split(v0, ",")
let p1 = split(v1, ",")
let p2 = split(v2, ",")
let x0 = to_int(index(p0, 0))
let y0 = to_int(index(p0, 1))
let x1 = to_int(index(p1, 0))
let y1 = to_int(index(p1, 1))
let x2 = to_int(index(p2, 0))
let y2 = to_int(index(p2, 1))

// Bounding box.
let minx = min_num([x0, x1, x2])
let maxx = max_num([x0, x1, x2])
let miny = min_num([y0, y1, y2])
let maxy = max_num([y0, y1, y2])

// Edge function: sign tells which side of edge a point is on.
// Positive = inside for CCW winding.
for py in range(miny, maxy + 1) {
  for px in range(minx, maxx + 1) {
    // Barycentric: edge functions for each triangle edge.
    let e0 = (x1 - x0) * (py - y0) - (y1 - y0) * (px - x0)
    let e1 = (x2 - x1) * (py - y1) - (y2 - y1) * (px - x1)
    let e2 = (x0 - x2) * (py - y2) - (y0 - y2) * (px - x2)
    if e0 >= 0 {
      if e1 >= 0 {
        if e2 >= 0 {
          let pid = "hardware.gpu.fb." + to_string(px) + "." + to_string(py)
          if exists(pid) {
            set_content(pid, color)
          } else {
            add_shape(pid, "pixel", color, 2)
          }
        }
      }
    }
  }
}
"""
}

shape hardware.gpu.pipeline.render3d : hardware.gpu.pipeline {
  type: exec
  layer: 3
  """
// Render a 3D scene.
//
// Scene is a list of triangle shapes under scene_root.
// Each triangle shape has dimensions:
//   v0, v1, v2: "x,y,z" vertex positions
//   color: "r,g,b"
//
// Camera has: position, target, up, fov.
//
// Pipeline:
//   1. For each triangle: transform vertices by view*projection
//   2. Perspective divide (w divide)
//   3. Map to screen coordinates
//   4. Rasterize

let scene = children(scene_root)
let w = to_int(default(width, "320"))
let h = to_int(default(height, "240"))
let half_w = w / 2
let half_h = h / 2

for tri_name in scene {
  let tri_id = scene_root + "." + tri_name
  let v0 = dim(tri_id, "v0")
  let v1 = dim(tri_id, "v1")
  let v2 = dim(tri_id, "v2")
  let col = dim(tri_id, "color")

  // Simple orthographic projection for now:
  // screen_x = x + half_w, screen_y = -y + half_h (flip Y)
  let p0 = split(v0, ",")
  let p1 = split(v1, ",")
  let p2 = split(v2, ",")

  let sx0 = to_int(index(p0, 0)) + half_w
  let sy0 = half_h - to_int(index(p0, 1))
  let sx1 = to_int(index(p1, 0)) + half_w
  let sy1 = half_h - to_int(index(p1, 1))
  let sx2 = to_int(index(p2, 0)) + half_w
  let sy2 = half_h - to_int(index(p2, 1))

  // Rasterize the screen-space triangle.
  // (Calls the triangle rasterizer above.)
  let sv0 = to_string(sx0) + "," + to_string(sy0)
  let sv1 = to_string(sx1) + "," + to_string(sy1)
  let sv2 = to_string(sx2) + "," + to_string(sy2)

  // Inline rasterize for now.
  let minx = min_num([sx0, sx1, sx2])
  let maxx = max_num([sx0, sx1, sx2])
  let miny = min_num([sy0, sy1, sy2])
  let maxy = max_num([sy0, sy1, sy2])

  for py in range(miny, maxy + 1) {
    for px in range(minx, maxx + 1) {
      let e0 = (sx1 - sx0) * (py - sy0) - (sy1 - sy0) * (px - sx0)
      let e1 = (sx2 - sx1) * (py - sy1) - (sy2 - sy1) * (px - sx1)
      let e2 = (sx0 - sx2) * (py - sy2) - (sy0 - sy2) * (px - sx2)
      if e0 >= 0 {
        if e1 >= 0 {
          if e2 >= 0 {
            let pid = "hardware.gpu.fb." + to_string(px) + "." + to_string(py)
            if exists(pid) {
              set_content(pid, col)
            } else {
              add_shape(pid, "pixel", col, 2)
            }
          }
        }
      }
    }
  }
}
"""
}
