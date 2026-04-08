// Morphology: word structure as shape composition.
//
// A morpheme IS the smallest meaningful shape. Morphemes compose into words.
// Root + affix = derived word. This IS shape composition: parent + child.
// Inflection IS dimension change on a shape (tense, number, case).
// Derivation IS creating a new shape that depends on the root.

shape world.lang.morphology : world.lang {
  type: system
  layer: 5
  deps: [world.lang.phonology]
  "Word formation. Roots, affixes, compounds. Morphemes are shapes that compose."
}

shape world.lang.morphology.types : world.lang.morphology {
  type: data
  layer: 5
  """
// Morpheme types.

add_shape("world.lang.morph_type.root", "morph_type", "The core meaning carrier. Cannot be decomposed further.", 5)
add_shape("world.lang.morph_type.prefix", "morph_type", "Attaches before the root. Modifies meaning.", 5)
add_shape("world.lang.morph_type.suffix", "morph_type", "Attaches after the root. Inflection or derivation.", 5)
add_shape("world.lang.morph_type.infix", "morph_type", "Inserted within the root. Rare in most languages.", 5)
add_shape("world.lang.morph_type.circumfix", "morph_type", "Wraps the root (prefix + suffix). German ge-...-t.", 5)

// Grammatical categories (dimensions on word shapes).
add_shape("world.lang.gram.tense", "category", "past,present,future,timeless", 5)
add_shape("world.lang.gram.aspect", "category", "perfective,imperfective,habitual,progressive", 5)
add_shape("world.lang.gram.mood", "category", "indicative,subjunctive,imperative,optative", 5)
add_shape("world.lang.gram.number", "category", "singular,dual,plural", 5)
add_shape("world.lang.gram.person", "category", "first,second,third", 5)
add_shape("world.lang.gram.case", "category", "nominative,accusative,genitive,dative,ablative,locative,instrumental,vocative", 5)
add_shape("world.lang.gram.gender", "category", "animate,inanimate,celestial,shadow", 5)
add_shape("world.lang.gram.definiteness", "category", "definite,indefinite,partitive", 5)
add_shape("world.lang.gram.evidentiality", "category", "direct,reported,inferred,assumed", 5)
"""
}
