shape theory.computing.peripheral.display : theory.computing.peripheral {
  type: unit
  layer: 0
  """
// Display Protocol.
//
// The display is the output contact boundary: how the computer's
// internal state becomes visible to human perception.
//
// Framebuffer:
//   Contiguous memory region. Each pixel = RGBA (4 bytes).
//   3840 x 2160 (4K): 33,177,600 bytes (~32 MB).
//   Double buffered: front buffer (being displayed) and back
//     buffer (being drawn). Swap on vsync to prevent tearing.
//   The framebuffer is a 2D projection of the computer's state
//   into the visual domain.
//
// GPU pipeline (simplified):
//   Vertex processing: transform 3D vertices to screen space.
//   Rasterization: convert triangles to pixel fragments.
//   Fragment processing: compute color per pixel (textures,
//     lighting, shading).
//   Output: write to framebuffer.
//   Modern GPUs: thousands of shader cores executing in parallel.
//   SIMT (Single Instruction Multiple Threads): same program,
//     different data, massive parallelism.
//
// Display output:
//   Display controller reads framebuffer at refresh rate.
//   Serializes pixels left-to-right, top-to-bottom.
//   Encodes as differential signal (LVDS, TMDS).
//   Blanking intervals between lines and frames for sync.
//
// Window composition:
//   Multiple applications share the display.
//   Each application renders to its own buffer.
//   Compositor combines buffers into the final framebuffer.
//   Z-ordering: which window is on top.
//   Clipping: only visible portions rendered.
//   The compositor is structural isolation (Definition 16.18):
//   applications are held in reference without mutual forcing.
//   Each app renders independently; the compositor combines.
//
// Derives from: theory.computing.peripheral
  """
}
