// Lore: the worldbuilding content system.
//
// Lore IS shapes. Races, classes, magic, history, geography, politics.
// Every piece of lore is a shape with connections to every other piece.
// The lore graph IS the world's memory. Query any node, traverse to any other.
// Consistency IS Law 3: contradictions in lore trigger resolution.
// History IS the trace: every change to the world is a moment.

shape world.lore : world {
  type: system
  layer: 5
  "The living lore of the world. Everything connects to everything."
}
