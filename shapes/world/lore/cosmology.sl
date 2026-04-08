// Cosmology: the creation myth and structure of reality.
//
// Every fantasy world starts here. The cosmology IS the axiom of the world.
// What persists in this universe? What are the laws? What came first?
// The shape theory parallel: the cosmology IS Law 0 for the fictional world.

shape world.lore.cosmology : world.lore {
  type: lore
  layer: 5
  """
// The world's creation and cosmic structure.
//
// Planes of existence (emergence layers of the fictional world):
//   Primordial - raw creation energy, formless
//   Celestial  - realm of gods and cosmic forces
//   Ethereal   - spirit world, dreams, magic substrate
//   Material   - the physical world, mortal realm
//   Shadow     - echo of the material, decay and entropy
//   Abyssal    - void, dissolution, what doesn't cohere
//
// Each plane IS an emergence level. Higher planes see structure
// that lower planes cannot. Gods see the celestial. Mortals see
// the material. Mages reach into the ethereal.
//
// The creation myth: from the Primordial, persistence emerged.
// What cohered became the planes. What didn't cohere became the Abyss.
// The gods ARE the first persistent structures. They don't rule the world.
// They ARE the world's coherence. Law 0 in mythic form.
"""
}

shape world.lore.cosmology.planes : world.lore.cosmology {
  type: data
  layer: 5
  """
// Define the planes of existence.
add_shape("world.lore.plane.primordial", "plane", "Raw creation. Before form. The axiom.", 5)
set_dim("world.lore.plane.primordial", "level", "0")
set_dim("world.lore.plane.primordial", "accessible_by", "none")

add_shape("world.lore.plane.celestial", "plane", "Realm of gods. Cosmic law. Coherence itself.", 5)
set_dim("world.lore.plane.celestial", "level", "1")
set_dim("world.lore.plane.celestial", "accessible_by", "gods,ascended")

add_shape("world.lore.plane.ethereal", "plane", "Spirit world. Dreams. The substrate of magic.", 5)
set_dim("world.lore.plane.ethereal", "level", "2")
set_dim("world.lore.plane.ethereal", "accessible_by", "mages,spirits,fey")

add_shape("world.lore.plane.material", "plane", "The physical world. Where mortals live and die.", 5)
set_dim("world.lore.plane.material", "level", "3")
set_dim("world.lore.plane.material", "accessible_by", "all")

add_shape("world.lore.plane.shadow", "plane", "Echo of the material. Decay. Undeath. Entropy.", 5)
set_dim("world.lore.plane.shadow", "level", "4")
set_dim("world.lore.plane.shadow", "accessible_by", "necromancers,undead,shadow_walkers")

add_shape("world.lore.plane.abyss", "plane", "The void. Dissolution. What doesn't cohere.", 5)
set_dim("world.lore.plane.abyss", "level", "5")
set_dim("world.lore.plane.abyss", "accessible_by", "demons,warlocks")
"""
}
