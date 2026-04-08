// Races: the peoples of the world.
//
// Each race IS a shape with biological, cultural, and magical dimensions.
// Racial traits are structural: they derive from which plane the race
// originated on. Elves are ethereal-touched. Dwarves are material-rooted.
// Humans are balanced across planes. Each race IS its relationship to
// the cosmic structure.

shape world.lore.races : world.lore {
  type: lore
  layer: 5
  deps: [world.lore.cosmology]
  "The peoples. Each race is a structural relationship to the planes."
}

shape world.lore.races.human : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.human", "race", "Adaptable, ambitious, short-lived. The most balanced race across all planes.", 5)
set_dim("world.lore.race.human", "origin_plane", "material")
set_dim("world.lore.race.human", "lifespan", "80")
set_dim("world.lore.race.human", "size", "medium")
set_dim("world.lore.race.human", "traits", "adaptable,ambitious,diverse")
set_dim("world.lore.race.human", "magic_affinity", "moderate")
set_dim("world.lore.race.human", "languages", "common")
set_dim("world.lore.race.human", "alignment_tendency", "neutral")
set_dim("world.lore.race.human", "stat_bonus", "all+1")
"""
}

shape world.lore.races.elf : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.elf", "race", "Long-lived, ethereal-touched. See the world through the lens of magic and time.", 5)
set_dim("world.lore.race.elf", "origin_plane", "ethereal")
set_dim("world.lore.race.elf", "lifespan", "750")
set_dim("world.lore.race.elf", "size", "medium")
set_dim("world.lore.race.elf", "traits", "graceful,perceptive,trance")
set_dim("world.lore.race.elf", "magic_affinity", "high")
set_dim("world.lore.race.elf", "languages", "common,elvish")
set_dim("world.lore.race.elf", "alignment_tendency", "chaotic_good")
set_dim("world.lore.race.elf", "stat_bonus", "dex+2,wis+1")
set_dim("world.lore.race.elf", "subraces", "high_elf,wood_elf,dark_elf,sea_elf")
"""
}

shape world.lore.races.dwarf : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.dwarf", "race", "Stout, enduring, material-rooted. Masters of stone, metal, and craft.", 5)
set_dim("world.lore.race.dwarf", "origin_plane", "material")
set_dim("world.lore.race.dwarf", "lifespan", "350")
set_dim("world.lore.race.dwarf", "size", "medium")
set_dim("world.lore.race.dwarf", "traits", "resilient,darkvision,stonecunning")
set_dim("world.lore.race.dwarf", "magic_affinity", "low")
set_dim("world.lore.race.dwarf", "languages", "common,dwarvish")
set_dim("world.lore.race.dwarf", "alignment_tendency", "lawful_good")
set_dim("world.lore.race.dwarf", "stat_bonus", "con+2,str+1")
set_dim("world.lore.race.dwarf", "subraces", "mountain_dwarf,hill_dwarf,deep_dwarf")
"""
}

shape world.lore.races.orc : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.orc", "race", "Fierce, shadow-touched. Born between the material and shadow planes.", 5)
set_dim("world.lore.race.orc", "origin_plane", "shadow")
set_dim("world.lore.race.orc", "lifespan", "50")
set_dim("world.lore.race.orc", "size", "medium")
set_dim("world.lore.race.orc", "traits", "aggressive,endurance,intimidating")
set_dim("world.lore.race.orc", "magic_affinity", "low")
set_dim("world.lore.race.orc", "languages", "common,orcish")
set_dim("world.lore.race.orc", "alignment_tendency", "chaotic")
set_dim("world.lore.race.orc", "stat_bonus", "str+2,con+1")
"""
}

shape world.lore.races.halfling : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.halfling", "race", "Small, lucky, deeply material. The most grounded of all races.", 5)
set_dim("world.lore.race.halfling", "origin_plane", "material")
set_dim("world.lore.race.halfling", "lifespan", "150")
set_dim("world.lore.race.halfling", "size", "small")
set_dim("world.lore.race.halfling", "traits", "lucky,brave,nimble")
set_dim("world.lore.race.halfling", "magic_affinity", "low")
set_dim("world.lore.race.halfling", "languages", "common,halfling")
set_dim("world.lore.race.halfling", "alignment_tendency", "lawful_good")
set_dim("world.lore.race.halfling", "stat_bonus", "dex+2,cha+1")
"""
}

shape world.lore.races.dragonborn : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.dragonborn", "race", "Draconic heritage. Celestial-touched through the first dragons.", 5)
set_dim("world.lore.race.dragonborn", "origin_plane", "celestial")
set_dim("world.lore.race.dragonborn", "lifespan", "80")
set_dim("world.lore.race.dragonborn", "size", "medium")
set_dim("world.lore.race.dragonborn", "traits", "breath_weapon,damage_resistance,draconic_ancestry")
set_dim("world.lore.race.dragonborn", "magic_affinity", "moderate")
set_dim("world.lore.race.dragonborn", "languages", "common,draconic")
set_dim("world.lore.race.dragonborn", "alignment_tendency", "lawful")
set_dim("world.lore.race.dragonborn", "stat_bonus", "str+2,cha+1")
"""
}

shape world.lore.races.tiefling : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.tiefling", "race", "Abyssal-touched. Infernal heritage, mortal soul. Walk between worlds.", 5)
set_dim("world.lore.race.tiefling", "origin_plane", "abyss")
set_dim("world.lore.race.tiefling", "lifespan", "100")
set_dim("world.lore.race.tiefling", "size", "medium")
set_dim("world.lore.race.tiefling", "traits", "darkvision,hellish_resistance,infernal_legacy")
set_dim("world.lore.race.tiefling", "magic_affinity", "high")
set_dim("world.lore.race.tiefling", "languages", "common,infernal")
set_dim("world.lore.race.tiefling", "alignment_tendency", "chaotic")
set_dim("world.lore.race.tiefling", "stat_bonus", "cha+2,int+1")
"""
}

shape world.lore.races.gnome : world.lore.races {
  type: race
  layer: 5
  """
add_shape("world.lore.race.gnome", "race", "Curious, inventive, ethereal-touched through curiosity rather than grace.", 5)
set_dim("world.lore.race.gnome", "origin_plane", "ethereal")
set_dim("world.lore.race.gnome", "lifespan", "400")
set_dim("world.lore.race.gnome", "size", "small")
set_dim("world.lore.race.gnome", "traits", "darkvision,gnome_cunning,tinker")
set_dim("world.lore.race.gnome", "magic_affinity", "moderate")
set_dim("world.lore.race.gnome", "languages", "common,gnomish")
set_dim("world.lore.race.gnome", "alignment_tendency", "good")
set_dim("world.lore.race.gnome", "stat_bonus", "int+2,con+1")
"""
}
