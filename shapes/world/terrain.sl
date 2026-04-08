// Terrain: procedural landscape as shapes.
//
// A heightmap IS a 2D grid of height values. Each cell IS a shape.
// Procedural generation IS structural: noise IS a fractal shape.
// Each octave of noise IS an emergence level.
// The terrain IS the sum of all octaves. That's fractal coherence.

shape world.terrain : world {
  type: system
  layer: 5
  deps: [world.scene, hardware.gpu.framebuffer]
  "Procedural terrain. Heightmaps, noise, erosion. Fractal shapes."
}

shape world.terrain.heightmap : world.terrain {
  type: exec
  layer: 5
  """
// Generate a heightmap using simple hash-based noise.
// width, height: grid dimensions.
// seed: random seed.
// octaves: number of noise layers (more = more detail).
//
// Each octave doubles the frequency and halves the amplitude.
// This IS the polynomial fractal: each level adds structure
// at a finer scale.

let w = to_int(default(width, "64"))
let h = to_int(default(height, "64"))
let s = to_int(default(seed, "42"))
let oct = to_int(default(octaves, "4"))

for y in range(h) {
  for x in range(w) {
    let height_val = 0
    let amp = 128
    let freq = 1

    for o in range(oct) {
      // Simple integer hash noise.
      let nx = x * freq + s
      let ny = y * freq + s * 7
      let hash = mod(nx * 73856093 + ny * 19349663, 256)
      // Smooth: average with neighbors.
      let hash2 = mod((nx + 1) * 73856093 + ny * 19349663, 256)
      let hash3 = mod(nx * 73856093 + (ny + 1) * 19349663, 256)
      let smooth = (hash + hash2 + hash3) / 3
      set height_val = height_val + smooth * amp / 256
      set amp = amp / 2
      set freq = freq * 2
    }

    let hid = "world.terrain.h." + to_string(x) + "." + to_string(y)
    add_shape(hid, "height", to_string(height_val), 5)
  }
}
print("Generated " + to_string(w) + "x" + to_string(h) + " heightmap, " + to_string(oct) + " octaves")
"""
}
