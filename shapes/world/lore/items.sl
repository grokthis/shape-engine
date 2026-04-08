// Items: equipment, artifacts, and materials.
//
// Every item IS a shape. Magical items have ethereal connections.
// Artifacts have celestial or abyssal connections.
// Crafting IS structural composition: materials + recipe = item.

shape world.lore.items : world.lore {
  type: lore
  layer: 5
  deps: [world.lore.magic]
  "Items, equipment, artifacts. Materials and crafting. Treasure."
}

shape world.lore.items.equipment : world.lore.items {
  type: data
  layer: 5
  """
// Equipment categories and examples.

// Weapons
add_shape("world.lore.item.longsword", "weapon", "Standard martial weapon. Versatile.", 5)
set_dim("world.lore.item.longsword", "damage", "1d8 slashing")
set_dim("world.lore.item.longsword", "properties", "versatile")
set_dim("world.lore.item.longsword", "weight", "3")
set_dim("world.lore.item.longsword", "cost", "15gp")

add_shape("world.lore.item.longbow", "weapon", "Standard ranged weapon.", 5)
set_dim("world.lore.item.longbow", "damage", "1d8 piercing")
set_dim("world.lore.item.longbow", "range", "150/600")
set_dim("world.lore.item.longbow", "properties", "ammunition,heavy,two_handed")

add_shape("world.lore.item.staff", "weapon", "Quarterstaff. Also an arcane focus.", 5)
set_dim("world.lore.item.staff", "damage", "1d6 bludgeoning")
set_dim("world.lore.item.staff", "properties", "versatile,arcane_focus")

// Armor
add_shape("world.lore.item.chain_mail", "armor", "Heavy armor. Good protection, noisy.", 5)
set_dim("world.lore.item.chain_mail", "ac", "16")
set_dim("world.lore.item.chain_mail", "type", "heavy")
set_dim("world.lore.item.chain_mail", "stealth", "disadvantage")

add_shape("world.lore.item.leather_armor", "armor", "Light armor. Quiet, flexible.", 5)
set_dim("world.lore.item.leather_armor", "ac", "11+dex")
set_dim("world.lore.item.leather_armor", "type", "light")

// Magic items
add_shape("world.lore.item.flaming_sword", "weapon", "Longsword wreathed in ethereal fire. +1d6 fire damage.", 5)
set_dim("world.lore.item.flaming_sword", "damage", "1d8+1d6 slashing+fire")
set_dim("world.lore.item.flaming_sword", "rarity", "rare")
set_dim("world.lore.item.flaming_sword", "attunement", "required")
set_dim("world.lore.item.flaming_sword", "plane_connection", "ethereal")

add_shape("world.lore.item.ring_of_protection", "ring", "Abjuration woven into metal. +1 AC, +1 saves.", 5)
set_dim("world.lore.item.ring_of_protection", "rarity", "rare")
set_dim("world.lore.item.ring_of_protection", "attunement", "required")

add_shape("world.lore.item.bag_of_holding", "wondrous", "Extradimensional space. A pocket of ethereal plane sewn into a bag.", 5)
set_dim("world.lore.item.bag_of_holding", "rarity", "uncommon")
set_dim("world.lore.item.bag_of_holding", "capacity", "500lbs,64cu_ft")
set_dim("world.lore.item.bag_of_holding", "plane_connection", "ethereal")

// Artifacts
add_shape("world.lore.item.orb_of_annihilation", "artifact", "Sphere of absolute void. Abyssal plane breach. Destroys all it touches.", 5)
set_dim("world.lore.item.orb_of_annihilation", "rarity", "legendary")
set_dim("world.lore.item.orb_of_annihilation", "plane_connection", "abyss")
set_dim("world.lore.item.orb_of_annihilation", "danger", "extreme")

add_shape("world.lore.item.hand_of_the_maker", "artifact", "Celestial artifact. Said to be a fragment of the first creation. Grants one Wish per century.", 5)
set_dim("world.lore.item.hand_of_the_maker", "rarity", "legendary")
set_dim("world.lore.item.hand_of_the_maker", "plane_connection", "celestial,primordial")
set_dim("world.lore.item.hand_of_the_maker", "features", "wish,create_demiplane,true_resurrection")

// Materials
add_shape("world.lore.material.mithril", "material", "Ethereal-infused metal. Light as silk, hard as steel. Elven forges only.", 5)
set_dim("world.lore.material.mithril", "source", "ironhold_mountains,silverwood")
set_dim("world.lore.material.mithril", "properties", "lightweight,magical_conductivity")

add_shape("world.lore.material.adamantine", "material", "Primordial metal. Nearly indestructible. Found in volcanic depths.", 5)
set_dim("world.lore.material.adamantine", "source", "ashlands,underdark")
set_dim("world.lore.material.adamantine", "properties", "unbreakable,critical_immunity")

add_shape("world.lore.material.dragonbone", "material", "Bone of ancient dragons. Resonates with celestial energy.", 5)
set_dim("world.lore.material.dragonbone", "source", "ashlands")
set_dim("world.lore.material.dragonbone", "properties", "magical_amplifier,elemental_resistance")
"""
}
