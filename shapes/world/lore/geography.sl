// Geography: the lands of the world.
//
// Each region IS a shape with terrain, climate, inhabitants, and connections.
// The map IS the shape graph. Travel IS graph traversal.
// Trade routes ARE dependency connections. Political borders ARE
// the boundaries of overlapping governance shapes.

shape world.lore.geography : world.lore {
  type: lore
  layer: 5
  deps: [world.lore.races, world.lore.cosmology, world.terrain]
  "The lands. Continents, kingdoms, cities, dungeons. All connected."
}

shape world.lore.geography.regions : world.lore.geography {
  type: data
  layer: 5
  """
// The major regions of the default world.

add_shape("world.lore.region.verdant_reach", "region", "Vast temperate forests and rolling hills. Heartland of human civilization.", 5)
set_dim("world.lore.region.verdant_reach", "terrain", "forest,hills,plains")
set_dim("world.lore.region.verdant_reach", "climate", "temperate")
set_dim("world.lore.region.verdant_reach", "races", "human,halfling,gnome")
set_dim("world.lore.region.verdant_reach", "government", "feudal_kingdoms")
set_dim("world.lore.region.verdant_reach", "connections", "ironhold_mountains,silver_coast,darkwood")

add_shape("world.lore.region.ironhold_mountains", "region", "Towering peaks riddled with mines and dwarven halls.", 5)
set_dim("world.lore.region.ironhold_mountains", "terrain", "mountains,caves,tundra")
set_dim("world.lore.region.ironhold_mountains", "climate", "cold")
set_dim("world.lore.region.ironhold_mountains", "races", "dwarf,gnome,goliath")
set_dim("world.lore.region.ironhold_mountains", "government", "clan_councils")
set_dim("world.lore.region.ironhold_mountains", "connections", "verdant_reach,ashlands")

add_shape("world.lore.region.silverwood", "region", "Ancient elven forest. Trees older than human memory. Ethereal-touched.", 5)
set_dim("world.lore.region.silverwood", "terrain", "ancient_forest,groves,streams")
set_dim("world.lore.region.silverwood", "climate", "temperate")
set_dim("world.lore.region.silverwood", "races", "elf,fey")
set_dim("world.lore.region.silverwood", "government", "elven_courts")
set_dim("world.lore.region.silverwood", "connections", "verdant_reach,feywild_crossing")

add_shape("world.lore.region.silver_coast", "region", "Coastal trading cities. Diverse, wealthy, politically complex.", 5)
set_dim("world.lore.region.silver_coast", "terrain", "coast,islands,harbors")
set_dim("world.lore.region.silver_coast", "climate", "maritime")
set_dim("world.lore.region.silver_coast", "races", "human,halfling,tiefling,dragonborn")
set_dim("world.lore.region.silver_coast", "government", "merchant_republics")
set_dim("world.lore.region.silver_coast", "connections", "verdant_reach,sunken_isles,scorching_waste")

add_shape("world.lore.region.darkwood", "region", "Cursed forest. Shadow-plane bleeding through. Undead, werewolves, hags.", 5)
set_dim("world.lore.region.darkwood", "terrain", "dead_forest,swamp,ruins")
set_dim("world.lore.region.darkwood", "climate", "cold,perpetual_fog")
set_dim("world.lore.region.darkwood", "races", "undead,lycanthropes,hags")
set_dim("world.lore.region.darkwood", "government", "none")
set_dim("world.lore.region.darkwood", "connections", "verdant_reach,shadow_crossing")
set_dim("world.lore.region.darkwood", "danger", "high")

add_shape("world.lore.region.ashlands", "region", "Volcanic wasteland. Dragon territories. Ancient ruins from before the current age.", 5)
set_dim("world.lore.region.ashlands", "terrain", "volcanic,desert,lava_fields,ruins")
set_dim("world.lore.region.ashlands", "climate", "extreme_heat")
set_dim("world.lore.region.ashlands", "races", "dragonborn,orc,fire_giant")
set_dim("world.lore.region.ashlands", "government", "dragon_lords")
set_dim("world.lore.region.ashlands", "connections", "ironhold_mountains,scorching_waste")
set_dim("world.lore.region.ashlands", "danger", "extreme")

add_shape("world.lore.region.scorching_waste", "region", "Desert. Nomadic tribes, buried cities, sandworms.", 5)
set_dim("world.lore.region.scorching_waste", "terrain", "desert,dunes,oasis,buried_ruins")
set_dim("world.lore.region.scorching_waste", "climate", "arid")
set_dim("world.lore.region.scorching_waste", "races", "human,gnoll,yuan_ti")
set_dim("world.lore.region.scorching_waste", "government", "tribal_confederacy")
set_dim("world.lore.region.scorching_waste", "connections", "silver_coast,ashlands")

add_shape("world.lore.region.frostfell", "region", "Frozen north. Frost giants, ice dragons, barbarian clans.", 5)
set_dim("world.lore.region.frostfell", "terrain", "tundra,glaciers,frozen_sea")
set_dim("world.lore.region.frostfell", "climate", "arctic")
set_dim("world.lore.region.frostfell", "races", "human_barbarian,frost_giant,yeti")
set_dim("world.lore.region.frostfell", "government", "chieftains")
set_dim("world.lore.region.frostfell", "connections", "ironhold_mountains")
set_dim("world.lore.region.frostfell", "danger", "high")

add_shape("world.lore.region.underdark", "region", "Vast cave system beneath the surface. Dark elves, mind flayers, duergar.", 5)
set_dim("world.lore.region.underdark", "terrain", "caves,underground_sea,fungal_forest")
set_dim("world.lore.region.underdark", "climate", "subterranean")
set_dim("world.lore.region.underdark", "races", "drow,duergar,myconid,mind_flayer,aboleth")
set_dim("world.lore.region.underdark", "government", "city_states")
set_dim("world.lore.region.underdark", "connections", "ironhold_mountains,darkwood")
set_dim("world.lore.region.underdark", "danger", "extreme")
"""
}

shape world.lore.geography.cities : world.lore.geography {
  type: data
  layer: 5
  """
// Major cities.

add_shape("world.lore.city.haven", "city", "Capital of the Verdant Reach. Largest human city. Center of trade and politics.", 5)
set_dim("world.lore.city.haven", "region", "verdant_reach")
set_dim("world.lore.city.haven", "population", "250000")
set_dim("world.lore.city.haven", "government", "monarchy")
set_dim("world.lore.city.haven", "features", "royal_palace,mages_guild,grand_temple,market_district,harbor")

add_shape("world.lore.city.irondeep", "city", "Greatest dwarven hold. Miles of tunnels carved into the mountain heart.", 5)
set_dim("world.lore.city.irondeep", "region", "ironhold_mountains")
set_dim("world.lore.city.irondeep", "population", "80000")
set_dim("world.lore.city.irondeep", "government", "clan_council")
set_dim("world.lore.city.irondeep", "features", "great_forge,mithril_mines,hall_of_ancestors,underground_farms")

add_shape("world.lore.city.starfall", "city", "Elven capital. Built in the canopy of the oldest trees. Ethereal-touched architecture.", 5)
set_dim("world.lore.city.starfall", "region", "silverwood")
set_dim("world.lore.city.starfall", "population", "30000")
set_dim("world.lore.city.starfall", "government", "elven_court")
set_dim("world.lore.city.starfall", "features", "tree_palaces,moonwell,arcane_library,portal_garden")

add_shape("world.lore.city.portmorrow", "city", "Largest port. Merchant republic. Every race, every good, every vice.", 5)
set_dim("world.lore.city.portmorrow", "region", "silver_coast")
set_dim("world.lore.city.portmorrow", "population", "180000")
set_dim("world.lore.city.portmorrow", "government", "merchant_council")
set_dim("world.lore.city.portmorrow", "features", "grand_bazaar,thieves_guild,shipyards,arena,foreign_quarter")

add_shape("world.lore.city.ashspire", "city", "Dragonborn citadel built on a dormant volcano. Seat of the Dragon Lords.", 5)
set_dim("world.lore.city.ashspire", "region", "ashlands")
set_dim("world.lore.city.ashspire", "population", "40000")
set_dim("world.lore.city.ashspire", "government", "dragon_council")
set_dim("world.lore.city.ashspire", "features", "dragon_roosts,obsidian_forge,fire_temple,gladiator_pits")
"""
}
