// Creatures: the beings that inhabit the world.
//
// Each creature IS a shape with stats, abilities, and lore.
// The bestiary IS a shape catalog. Every creature connects to
// the cosmology through its origin plane, to races through its
// intelligence, to magic through its abilities.

shape world.lore.creatures : world.lore {
  type: lore
  layer: 5
  deps: [world.lore.cosmology, world.lore.magic]
  "Creatures of the world. Dragons, undead, fey, fiends, beasts, aberrations."
}

shape world.lore.creatures.types : world.lore.creatures {
  type: data
  layer: 5
  """
// Creature types. Each corresponds to a plane of origin.

add_shape("world.lore.creature_type.beast", "creature_type", "Natural animals. Material plane. No magic.", 5)
set_dim("world.lore.creature_type.beast", "plane", "material")

add_shape("world.lore.creature_type.humanoid", "creature_type", "Intelligent material beings. The playable races.", 5)
set_dim("world.lore.creature_type.humanoid", "plane", "material")

add_shape("world.lore.creature_type.dragon", "creature_type", "Celestial-born. Ancient, powerful, magical. First children of creation.", 5)
set_dim("world.lore.creature_type.dragon", "plane", "celestial")

add_shape("world.lore.creature_type.fey", "creature_type", "Ethereal natives. Capricious, magical, alien beauty.", 5)
set_dim("world.lore.creature_type.fey", "plane", "ethereal")

add_shape("world.lore.creature_type.celestial", "creature_type", "Angels, devas. Direct expressions of cosmic law.", 5)
set_dim("world.lore.creature_type.celestial", "plane", "celestial")

add_shape("world.lore.creature_type.undead", "creature_type", "Shadow-plane echoes of the living. Persist through necromantic coherence.", 5)
set_dim("world.lore.creature_type.undead", "plane", "shadow")

add_shape("world.lore.creature_type.fiend", "creature_type", "Abyssal entities. Demons, devils. Incoherence given form.", 5)
set_dim("world.lore.creature_type.fiend", "plane", "abyss")

add_shape("world.lore.creature_type.elemental", "creature_type", "Primordial forces given shape. Fire, water, earth, air.", 5)
set_dim("world.lore.creature_type.elemental", "plane", "primordial")

add_shape("world.lore.creature_type.aberration", "creature_type", "Things from beyond the planes. Beholders, mind flayers. Structures that shouldn't cohere but do.", 5)
set_dim("world.lore.creature_type.aberration", "plane", "void")

add_shape("world.lore.creature_type.construct", "creature_type", "Artificially coherent. Golems, animated objects. Structure without life.", 5)
set_dim("world.lore.creature_type.construct", "plane", "material")

add_shape("world.lore.creature_type.monstrosity", "creature_type", "Magical corruption of natural forms. Chimera, basilisk, hydra.", 5)
set_dim("world.lore.creature_type.monstrosity", "plane", "material")

add_shape("world.lore.creature_type.plant", "creature_type", "Vegetable life with awareness. Treants, blights, myconids.", 5)
set_dim("world.lore.creature_type.plant", "plane", "material")

add_shape("world.lore.creature_type.ooze", "creature_type", "Minimal structure. Gelatinous cubes, black puddings. Persistence without form.", 5)
set_dim("world.lore.creature_type.ooze", "plane", "material")

add_shape("world.lore.creature_type.giant", "creature_type", "Primordial-touched humanoids. Scaled up. Ancient lineage.", 5)
set_dim("world.lore.creature_type.giant", "plane", "primordial")
"""
}

shape world.lore.creatures.bestiary : world.lore.creatures {
  type: data
  layer: 5
  """
// Iconic creatures with stats.
// CR = challenge rating. Stats in D&D-style format.

add_shape("world.lore.creature.goblin", "creature", "Small, cunning, numerous. Raid in packs.", 5)
set_dim("world.lore.creature.goblin", "type", "humanoid")
set_dim("world.lore.creature.goblin", "cr", "0.25")
set_dim("world.lore.creature.goblin", "hp", "7")
set_dim("world.lore.creature.goblin", "ac", "15")
set_dim("world.lore.creature.goblin", "str", "8")
set_dim("world.lore.creature.goblin", "dex", "14")
set_dim("world.lore.creature.goblin", "size", "small")

add_shape("world.lore.creature.skeleton", "creature", "Animated bones. The simplest undead. Shadow-plane echo of a humanoid.", 5)
set_dim("world.lore.creature.skeleton", "type", "undead")
set_dim("world.lore.creature.skeleton", "cr", "0.25")
set_dim("world.lore.creature.skeleton", "hp", "13")
set_dim("world.lore.creature.skeleton", "ac", "13")

add_shape("world.lore.creature.wolf", "creature", "Pack predator. Material plane.", 5)
set_dim("world.lore.creature.wolf", "type", "beast")
set_dim("world.lore.creature.wolf", "cr", "0.25")
set_dim("world.lore.creature.wolf", "hp", "11")

add_shape("world.lore.creature.owlbear", "creature", "Magical hybrid. Bear body, owl head. Territorial.", 5)
set_dim("world.lore.creature.owlbear", "type", "monstrosity")
set_dim("world.lore.creature.owlbear", "cr", "3")
set_dim("world.lore.creature.owlbear", "hp", "59")

add_shape("world.lore.creature.troll", "creature", "Regenerating brute. Kill it with fire or acid.", 5)
set_dim("world.lore.creature.troll", "type", "giant")
set_dim("world.lore.creature.troll", "cr", "5")
set_dim("world.lore.creature.troll", "hp", "84")
set_dim("world.lore.creature.troll", "features", "regeneration,keen_smell")

add_shape("world.lore.creature.beholder", "creature", "Aberrant eye tyrant. Each eye ray IS a different spell. Should not exist but does.", 5)
set_dim("world.lore.creature.beholder", "type", "aberration")
set_dim("world.lore.creature.beholder", "cr", "13")
set_dim("world.lore.creature.beholder", "hp", "180")
set_dim("world.lore.creature.beholder", "features", "antimagic_cone,eye_rays,hover")

add_shape("world.lore.creature.lich", "creature", "Undead archmage. Achieved persistence through necromantic phylactery. The ultimate shadow-plane hack.", 5)
set_dim("world.lore.creature.lich", "type", "undead")
set_dim("world.lore.creature.lich", "cr", "21")
set_dim("world.lore.creature.lich", "hp", "135")
set_dim("world.lore.creature.lich", "features", "spellcasting_18th,phylactery,frightening_presence,legendary_actions")

add_shape("world.lore.creature.dragon_red_ancient", "creature", "Ancient red dragon. Celestial-born, fire incarnate. One of the first shapes.", 5)
set_dim("world.lore.creature.dragon_red_ancient", "type", "dragon")
set_dim("world.lore.creature.dragon_red_ancient", "cr", "24")
set_dim("world.lore.creature.dragon_red_ancient", "hp", "546")
set_dim("world.lore.creature.dragon_red_ancient", "features", "fire_breath,frightful_presence,legendary_actions,lair_actions")
set_dim("world.lore.creature.dragon_red_ancient", "size", "gargantuan")

add_shape("world.lore.creature.tarrasque", "creature", "Primordial force of destruction. Not evil. Not good. Just... persistent. Cannot be permanently killed.", 5)
set_dim("world.lore.creature.tarrasque", "type", "monstrosity")
set_dim("world.lore.creature.tarrasque", "cr", "30")
set_dim("world.lore.creature.tarrasque", "hp", "676")
set_dim("world.lore.creature.tarrasque", "features", "legendary_resistance,magic_resistance,reflective_carapace,siege_monster")
set_dim("world.lore.creature.tarrasque", "size", "gargantuan")
"""
}
