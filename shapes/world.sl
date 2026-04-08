// World: the worldbuilding system.
//
// A world IS a shape graph. Terrain, entities, physics, light, sound.
// Everything in the world IS a shape. Every interaction IS wave propagation.
// Building a world IS creating shapes. Exploring a world IS traversing shapes.
// Editing a world IS editing shapes. Sharing a world IS sharing the shape graph.
//
// The world IS the OS. The OS IS the world.
// There is no distinction between the application and the content.
// The tools to build the world ARE part of the world.
// The world builds itself through the tools it provides.

shape world {
  type: system
  layer: 5
  "A world built from shapes. Everything is interactive at every level."
}
