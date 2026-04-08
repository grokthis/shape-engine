// GPU: graphics processing as shapes.
//
// The graphics pipeline IS wave propagation through a transform chain:
//   Vertex -> Transform -> Clip -> Rasterize -> Fragment -> Pixel
//
// Each stage IS a shape. Each triangle IS a shape. Each pixel IS a shape.
// The framebuffer IS the shape graph projected to a 2D grid.
//
// On hardware: parallel shape-gates processing vertices/fragments.
// In the engine: shape evaluation producing a pixel array.

shape hardware.gpu : hardware {
  type: system
  layer: 2
  "Graphics processing unit. Vertices, transforms, rasterization, pixels. All shapes."
}
