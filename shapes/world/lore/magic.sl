// Magic: the structural mechanics of reaching between planes.
//
// Magic IS structural recognition applied to the fictional world.
// A spell IS a pattern that the caster recognizes in the ethereal
// and projects into the material. The wizard studies the patterns.
// The sorcerer IS the pattern. The cleric receives the pattern.
// The warlock steals the pattern.
//
// Spell slots ARE coherence capacity: how much ethereal structure
// you can hold in your material form before it dissolves.
// Spell levels ARE emergence levels: higher spells reach deeper planes.

shape world.lore.magic : world.lore {
  type: lore
  layer: 5
  deps: [world.lore.cosmology, world.lore.classes]
  "Magic system. Spells are structural patterns. Casting is plane-reaching."
}

shape world.lore.magic.schools : world.lore.magic {
  type: data
  layer: 5
  """
// The eight schools of magic. Each IS a type of structural manipulation.

add_shape("world.lore.school.evocation", "school", "Direct energy projection. Fire, lightning, force. The simplest structural manipulation: push energy from ethereal to material.", 5)
set_dim("world.lore.school.evocation", "plane_source", "ethereal")
set_dim("world.lore.school.evocation", "effect", "damage,healing")

add_shape("world.lore.school.abjuration", "school", "Structural defense. Shields, wards, banishment. Reinforce the boundary between planes.", 5)
set_dim("world.lore.school.abjuration", "plane_source", "celestial")
set_dim("world.lore.school.abjuration", "effect", "protection,dispel")

add_shape("world.lore.school.divination", "school", "See across planes. Scrying, detection, foresight. Read the structure of reality.", 5)
set_dim("world.lore.school.divination", "plane_source", "ethereal")
set_dim("world.lore.school.divination", "effect", "information,prediction")

add_shape("world.lore.school.illusion", "school", "Project ethereal patterns into material perception. What seems real IS real to the observer.", 5)
set_dim("world.lore.school.illusion", "plane_source", "ethereal")
set_dim("world.lore.school.illusion", "effect", "deception,creation")

add_shape("world.lore.school.conjuration", "school", "Pull material from other locations or planes. Teleportation, summoning. Structural relocation.", 5)
set_dim("world.lore.school.conjuration", "plane_source", "ethereal")
set_dim("world.lore.school.conjuration", "effect", "transport,summoning")

add_shape("world.lore.school.transmutation", "school", "Change the structure of material directly. Polymorph, stone to flesh. The most structural school.", 5)
set_dim("world.lore.school.transmutation", "plane_source", "ethereal")
set_dim("world.lore.school.transmutation", "effect", "transformation,enhancement")

add_shape("world.lore.school.enchantment", "school", "Reshape the structure of minds. Charm, command, modify memory. Dangerous plane-reaching into another consciousness.", 5)
set_dim("world.lore.school.enchantment", "plane_source", "ethereal")
set_dim("world.lore.school.enchantment", "effect", "mind_control,buff")

add_shape("world.lore.school.necromancy", "school", "Reach into the shadow plane. Animate dead, drain life. Manipulate the boundary between life and entropy.", 5)
set_dim("world.lore.school.necromancy", "plane_source", "shadow")
set_dim("world.lore.school.necromancy", "effect", "death,undeath,drain")
"""
}

shape world.lore.magic.spells : world.lore.magic {
  type: data
  layer: 5
  """
// Spell levels 0-9 correspond to emergence depth.
// Cantrips (0): surface ethereal patterns, no slot cost.
// Level 1-3: shallow ethereal reach. Most casters can do this.
// Level 4-6: deep ethereal. Requires significant coherence capacity.
// Level 7-9: plane-crossing. Touches celestial or abyssal structure.
//   9th level spells reshape reality itself (Wish, True Polymorph).

// Example spells (a few at each level to establish the pattern):

// Cantrips
add_shape("world.lore.spell.fire_bolt", "spell", "Hurl a mote of fire. Simplest evocation.", 5)
set_dim("world.lore.spell.fire_bolt", "level", "0")
set_dim("world.lore.spell.fire_bolt", "school", "evocation")
set_dim("world.lore.spell.fire_bolt", "damage", "1d10 fire")
set_dim("world.lore.spell.fire_bolt", "range", "120")

add_shape("world.lore.spell.mage_hand", "spell", "Project ethereal force as a spectral hand.", 5)
set_dim("world.lore.spell.mage_hand", "level", "0")
set_dim("world.lore.spell.mage_hand", "school", "conjuration")

add_shape("world.lore.spell.prestidigitation", "spell", "Minor ethereal manipulation. The shape of magic at its simplest.", 5)
set_dim("world.lore.spell.prestidigitation", "level", "0")
set_dim("world.lore.spell.prestidigitation", "school", "transmutation")

// Level 1
add_shape("world.lore.spell.magic_missile", "spell", "Unerring force darts. Guaranteed hit because the structure IS the targeting.", 5)
set_dim("world.lore.spell.magic_missile", "level", "1")
set_dim("world.lore.spell.magic_missile", "school", "evocation")
set_dim("world.lore.spell.magic_missile", "damage", "3d4+3 force")

add_shape("world.lore.spell.shield", "spell", "Instant abjuration. Structural reinforcement of personal space.", 5)
set_dim("world.lore.spell.shield", "level", "1")
set_dim("world.lore.spell.shield", "school", "abjuration")

add_shape("world.lore.spell.cure_wounds", "spell", "Channel celestial coherence into damaged structure. Healing IS coherence restoration.", 5)
set_dim("world.lore.spell.cure_wounds", "level", "1")
set_dim("world.lore.spell.cure_wounds", "school", "evocation")
set_dim("world.lore.spell.cure_wounds", "healing", "1d8+mod")

// Level 3
add_shape("world.lore.spell.fireball", "spell", "Massive evocation. The iconic spell. Raw ethereal energy detonated in material space.", 5)
set_dim("world.lore.spell.fireball", "level", "3")
set_dim("world.lore.spell.fireball", "school", "evocation")
set_dim("world.lore.spell.fireball", "damage", "8d6 fire")
set_dim("world.lore.spell.fireball", "area", "20ft sphere")

add_shape("world.lore.spell.counterspell", "spell", "Abjuration that disrupts another spell's ethereal pattern mid-cast.", 5)
set_dim("world.lore.spell.counterspell", "level", "3")
set_dim("world.lore.spell.counterspell", "school", "abjuration")

// Level 5
add_shape("world.lore.spell.teleportation_circle", "spell", "Permanent conjuration. A structural shortcut through material space.", 5)
set_dim("world.lore.spell.teleportation_circle", "level", "5")
set_dim("world.lore.spell.teleportation_circle", "school", "conjuration")

add_shape("world.lore.spell.raise_dead", "spell", "Pull a soul back from the shadow plane. Restore coherence to a dissolved structure.", 5)
set_dim("world.lore.spell.raise_dead", "level", "5")
set_dim("world.lore.spell.raise_dead", "school", "necromancy")

// Level 9
add_shape("world.lore.spell.wish", "spell", "The ultimate spell. Reach all the way to the primordial and reshape reality. The caster IS the axiom for one moment.", 5)
set_dim("world.lore.spell.wish", "level", "9")
set_dim("world.lore.spell.wish", "school", "conjuration")

add_shape("world.lore.spell.true_polymorph", "spell", "Complete structural transformation. Change anything into anything. Transmutation at the deepest level.", 5)
set_dim("world.lore.spell.true_polymorph", "level", "9")
set_dim("world.lore.spell.true_polymorph", "school", "transmutation")
"""
}
