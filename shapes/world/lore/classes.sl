// Classes: how characters interact with the world's structure.
//
// A class IS a structural relationship to the planes.
// A fighter operates purely in the material plane.
// A wizard reaches into the ethereal to reshape reality.
// A cleric channels the celestial through faith.
// A warlock tears power from the abyss.
//
// Class IS perspective. What planes can you see? What can you reach?

shape world.lore.classes : world.lore {
  type: lore
  layer: 5
  deps: [world.lore.cosmology, world.lore.races]
  "Character classes. How you interact with the structure of reality."
}

shape world.lore.classes.fighter : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.fighter", "class", "Master of material combat. Pure physical discipline.", 5)
set_dim("world.lore.class.fighter", "plane_access", "material")
set_dim("world.lore.class.fighter", "hit_die", "d10")
set_dim("world.lore.class.fighter", "primary_stat", "str,dex")
set_dim("world.lore.class.fighter", "armor", "all")
set_dim("world.lore.class.fighter", "weapons", "all")
set_dim("world.lore.class.fighter", "magic", "none")
set_dim("world.lore.class.fighter", "features", "fighting_style,second_wind,action_surge,extra_attack")
set_dim("world.lore.class.fighter", "subclasses", "champion,battle_master,eldritch_knight")
"""
}

shape world.lore.classes.wizard : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.wizard", "class", "Scholar of the ethereal. Reshapes reality through study and will.", 5)
set_dim("world.lore.class.wizard", "plane_access", "material,ethereal")
set_dim("world.lore.class.wizard", "hit_die", "d6")
set_dim("world.lore.class.wizard", "primary_stat", "int")
set_dim("world.lore.class.wizard", "armor", "none")
set_dim("world.lore.class.wizard", "weapons", "dagger,dart,sling,quarterstaff")
set_dim("world.lore.class.wizard", "magic", "arcane")
set_dim("world.lore.class.wizard", "spellcasting", "int,prepared,spellbook")
set_dim("world.lore.class.wizard", "features", "arcane_recovery,spell_mastery,signature_spells")
set_dim("world.lore.class.wizard", "subclasses", "evocation,abjuration,divination,necromancy,illusion,conjuration,transmutation,enchantment")
"""
}

shape world.lore.classes.cleric : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.cleric", "class", "Channel of the celestial. Faith IS the connection to cosmic law.", 5)
set_dim("world.lore.class.cleric", "plane_access", "material,celestial")
set_dim("world.lore.class.cleric", "hit_die", "d8")
set_dim("world.lore.class.cleric", "primary_stat", "wis")
set_dim("world.lore.class.cleric", "armor", "light,medium,shields")
set_dim("world.lore.class.cleric", "magic", "divine")
set_dim("world.lore.class.cleric", "spellcasting", "wis,prepared,prayer")
set_dim("world.lore.class.cleric", "features", "channel_divinity,divine_intervention,turn_undead")
set_dim("world.lore.class.cleric", "subclasses", "life,light,war,knowledge,tempest,trickery,death,nature")
"""
}

shape world.lore.classes.rogue : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.rogue", "class", "Expert of the material shadows. Operates in the cracks between structures.", 5)
set_dim("world.lore.class.rogue", "plane_access", "material,shadow")
set_dim("world.lore.class.rogue", "hit_die", "d8")
set_dim("world.lore.class.rogue", "primary_stat", "dex")
set_dim("world.lore.class.rogue", "armor", "light")
set_dim("world.lore.class.rogue", "magic", "none")
set_dim("world.lore.class.rogue", "features", "sneak_attack,cunning_action,evasion,uncanny_dodge")
set_dim("world.lore.class.rogue", "subclasses", "thief,assassin,arcane_trickster,swashbuckler,phantom")
"""
}

shape world.lore.classes.warlock : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.warlock", "class", "Bargainer with the abyss. Power through pact, not study or faith.", 5)
set_dim("world.lore.class.warlock", "plane_access", "material,abyss")
set_dim("world.lore.class.warlock", "hit_die", "d8")
set_dim("world.lore.class.warlock", "primary_stat", "cha")
set_dim("world.lore.class.warlock", "armor", "light")
set_dim("world.lore.class.warlock", "magic", "pact")
set_dim("world.lore.class.warlock", "spellcasting", "cha,pact_magic,invocations")
set_dim("world.lore.class.warlock", "features", "eldritch_blast,pact_boon,mystic_arcanum")
set_dim("world.lore.class.warlock", "subclasses", "fiend,archfey,great_old_one,celestial,hexblade")
"""
}

shape world.lore.classes.ranger : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.ranger", "class", "Walker between material and ethereal wilds. Nature IS the connection.", 5)
set_dim("world.lore.class.ranger", "plane_access", "material,ethereal")
set_dim("world.lore.class.ranger", "hit_die", "d10")
set_dim("world.lore.class.ranger", "primary_stat", "dex,wis")
set_dim("world.lore.class.ranger", "armor", "light,medium,shields")
set_dim("world.lore.class.ranger", "magic", "primal")
set_dim("world.lore.class.ranger", "features", "favored_enemy,natural_explorer,extra_attack,vanish")
set_dim("world.lore.class.ranger", "subclasses", "hunter,beast_master,gloom_stalker,horizon_walker")
"""
}

shape world.lore.classes.paladin : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.paladin", "class", "Oath-bound warrior. The oath IS the structural connection to the celestial.", 5)
set_dim("world.lore.class.paladin", "plane_access", "material,celestial")
set_dim("world.lore.class.paladin", "hit_die", "d10")
set_dim("world.lore.class.paladin", "primary_stat", "str,cha")
set_dim("world.lore.class.paladin", "armor", "all")
set_dim("world.lore.class.paladin", "magic", "divine")
set_dim("world.lore.class.paladin", "features", "divine_smite,lay_on_hands,aura_of_protection,divine_sense")
set_dim("world.lore.class.paladin", "subclasses", "devotion,ancients,vengeance,redemption,conquest")
"""
}

shape world.lore.classes.bard : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.bard", "class", "Weaver of all planes through story and song. The lore itself IS magic.", 5)
set_dim("world.lore.class.bard", "plane_access", "material,ethereal,shadow")
set_dim("world.lore.class.bard", "hit_die", "d8")
set_dim("world.lore.class.bard", "primary_stat", "cha")
set_dim("world.lore.class.bard", "armor", "light")
set_dim("world.lore.class.bard", "magic", "arcane")
set_dim("world.lore.class.bard", "spellcasting", "cha,known,performance")
set_dim("world.lore.class.bard", "features", "bardic_inspiration,jack_of_all_trades,song_of_rest,countercharm")
set_dim("world.lore.class.bard", "subclasses", "lore,valor,glamour,whispers,swords,creation")
"""
}

shape world.lore.classes.druid : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.druid", "class", "Shape of nature itself. Wild shape IS literal structural transformation.", 5)
set_dim("world.lore.class.druid", "plane_access", "material,ethereal")
set_dim("world.lore.class.druid", "hit_die", "d8")
set_dim("world.lore.class.druid", "primary_stat", "wis")
set_dim("world.lore.class.druid", "armor", "light,medium,shields")
set_dim("world.lore.class.druid", "magic", "primal")
set_dim("world.lore.class.druid", "spellcasting", "wis,prepared,nature")
set_dim("world.lore.class.druid", "features", "wild_shape,druidic,beast_spells,timeless_body")
set_dim("world.lore.class.druid", "subclasses", "land,moon,shepherd,spores,stars,wildfire")
"""
}

shape world.lore.classes.monk : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.monk", "class", "Discipline of body and ki. The body IS the structure. Ki IS the coherence.", 5)
set_dim("world.lore.class.monk", "plane_access", "material,ethereal")
set_dim("world.lore.class.monk", "hit_die", "d8")
set_dim("world.lore.class.monk", "primary_stat", "dex,wis")
set_dim("world.lore.class.monk", "armor", "none")
set_dim("world.lore.class.monk", "magic", "ki")
set_dim("world.lore.class.monk", "features", "martial_arts,ki,unarmored_defense,deflect_missiles,slow_fall,stunning_strike")
set_dim("world.lore.class.monk", "subclasses", "open_hand,shadow,four_elements,sun_soul,mercy,astral_self")
"""
}

shape world.lore.classes.sorcerer : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.sorcerer", "class", "Born with ethereal structure in the blood. Magic IS innate, not learned.", 5)
set_dim("world.lore.class.sorcerer", "plane_access", "material,ethereal")
set_dim("world.lore.class.sorcerer", "hit_die", "d6")
set_dim("world.lore.class.sorcerer", "primary_stat", "cha")
set_dim("world.lore.class.sorcerer", "armor", "none")
set_dim("world.lore.class.sorcerer", "magic", "arcane")
set_dim("world.lore.class.sorcerer", "spellcasting", "cha,known,innate")
set_dim("world.lore.class.sorcerer", "features", "sorcery_points,metamagic,font_of_magic")
set_dim("world.lore.class.sorcerer", "subclasses", "draconic,wild_magic,divine_soul,shadow,storm,aberrant_mind,clockwork_soul")
"""
}

shape world.lore.classes.barbarian : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.barbarian", "class", "Raw material force. Rage IS unstructured power channeled through the body.", 5)
set_dim("world.lore.class.barbarian", "plane_access", "material")
set_dim("world.lore.class.barbarian", "hit_die", "d12")
set_dim("world.lore.class.barbarian", "primary_stat", "str")
set_dim("world.lore.class.barbarian", "armor", "light,medium,shields")
set_dim("world.lore.class.barbarian", "magic", "none")
set_dim("world.lore.class.barbarian", "features", "rage,unarmored_defense,reckless_attack,danger_sense,brutal_critical")
set_dim("world.lore.class.barbarian", "subclasses", "berserker,totem,storm,zealot,beast,wild_magic")
"""
}

shape world.lore.classes.artificer : world.lore.classes {
  type: class
  layer: 5
  """
add_shape("world.lore.class.artificer", "class", "Engineer of magic and matter. Infusions ARE structural modifications.", 5)
set_dim("world.lore.class.artificer", "plane_access", "material,ethereal")
set_dim("world.lore.class.artificer", "hit_die", "d8")
set_dim("world.lore.class.artificer", "primary_stat", "int")
set_dim("world.lore.class.artificer", "armor", "light,medium,shields")
set_dim("world.lore.class.artificer", "magic", "arcane")
set_dim("world.lore.class.artificer", "spellcasting", "int,prepared,tools")
set_dim("world.lore.class.artificer", "features", "infusions,magical_tinkering,tool_expertise,flash_of_genius")
set_dim("world.lore.class.artificer", "subclasses", "alchemist,artillerist,battle_smith,armorer")
"""
}
