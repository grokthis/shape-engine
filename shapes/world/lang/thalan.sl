// Thalan: the shape language.
//
// A constructed language derived from shape theory.
// The grammar IS the laws of coherence. The vocabulary IS the shape graph.
// Speaking Thalan IS describing structure. The language can express
// anything the shape engine can compute, because the language IS the engine.
//
// Name: Thalan (thal "shape" + an "voice/speech")
//
// Design principles:
//   - VSO word order (mirrors M' = f(C, S): action, context, content)
//   - Agglutinative morphology (shapes compose by attachment)
//   - 4 genders mapped to planes (animate, inanimate, celestial, shadow)
//   - Evidentiality marking (how you know: direct, reported, inferred)
//   - No irregular forms (coherence = regularity)
//   - Phonology: 5 vowels, 20 consonants, (C)V(C) syllable structure

shape world.lang.thalan : world.lang {
  type: language
  layer: 5
  deps: [world.lang.phonology, world.lang.morphology, world.lang.syntax, world.lore]
  "Thalan: the shape language. Grammar IS the laws of coherence."
}

shape world.lang.thalan.roots : world.lang.thalan {
  type: data
  layer: 5
  """
// Root vocabulary. Each root IS a morpheme shape connected to the world graph.
// Meaning IS connection: the word for "fire" connects to the fire element,
// the evocation school, the ashlands, red dragons.

// === Existence and structure ===
add_shape("world.lang.root.thal", "root", "shape, form, structure", 5)
set_dim("world.lang.root.thal", "class", "noun")
set_dim("world.lang.root.thal", "connects_to", "shape,law")

add_shape("world.lang.root.per", "root", "persist, endure, remain", 5)
set_dim("world.lang.root.per", "class", "verb")
set_dim("world.lang.root.per", "connects_to", "law.persistence")

add_shape("world.lang.root.kor", "root", "cohere, hold together, be consistent", 5)
set_dim("world.lang.root.kor", "class", "verb")
set_dim("world.lang.root.kor", "connects_to", "law.consistency")

add_shape("world.lang.root.vel", "root", "change, transform, become", 5)
set_dim("world.lang.root.vel", "class", "verb")
set_dim("world.lang.root.vel", "connects_to", "engine.edit")

add_shape("world.lang.root.nar", "root", "flow, wave, propagate", 5)
set_dim("world.lang.root.nar", "class", "verb")
set_dim("world.lang.root.nar", "connects_to", "engine.propagate")

add_shape("world.lang.root.an", "root", "voice, speech, language", 5)
set_dim("world.lang.root.an", "class", "noun")

add_shape("world.lang.root.sol", "root", "one, singular, atomic", 5)
set_dim("world.lang.root.sol", "class", "adjective")

add_shape("world.lang.root.mir", "root", "many, plural, composed", 5)
set_dim("world.lang.root.mir", "class", "adjective")

// === Elements and nature ===
add_shape("world.lang.root.ash", "root", "fire, heat, energy", 5)
set_dim("world.lang.root.ash", "class", "noun")
set_dim("world.lang.root.ash", "connects_to", "world.lore.school.evocation,world.lore.region.ashlands")

add_shape("world.lang.root.ven", "root", "water, flow, liquid", 5)
set_dim("world.lang.root.ven", "class", "noun")

add_shape("world.lang.root.ter", "root", "earth, stone, solid", 5)
set_dim("world.lang.root.ter", "class", "noun")
set_dim("world.lang.root.ter", "connects_to", "world.lore.region.ironhold_mountains")

add_shape("world.lang.root.aer", "root", "air, wind, breath", 5)
set_dim("world.lang.root.aer", "class", "noun")

add_shape("world.lang.root.lum", "root", "light, radiance, reveal", 5)
set_dim("world.lang.root.lum", "class", "noun")
set_dim("world.lang.root.lum", "connects_to", "world.lore.plane.celestial")

add_shape("world.lang.root.nok", "root", "dark, shadow, conceal", 5)
set_dim("world.lang.root.nok", "class", "noun")
set_dim("world.lang.root.nok", "connects_to", "world.lore.plane.shadow")

add_shape("world.lang.root.sil", "root", "tree, wood, growth", 5)
set_dim("world.lang.root.sil", "class", "noun")
set_dim("world.lang.root.sil", "connects_to", "world.lore.region.silverwood")

// === Beings ===
add_shape("world.lang.root.val", "root", "person, being, soul", 5)
set_dim("world.lang.root.val", "class", "noun")
set_dim("world.lang.root.val", "gender", "animate")

add_shape("world.lang.root.dra", "root", "dragon, ancient one, first-born", 5)
set_dim("world.lang.root.dra", "class", "noun")
set_dim("world.lang.root.dra", "gender", "celestial")
set_dim("world.lang.root.dra", "connects_to", "world.lore.creature_type.dragon")

add_shape("world.lang.root.mor", "root", "death, ending, dissolution", 5)
set_dim("world.lang.root.mor", "class", "noun")
set_dim("world.lang.root.mor", "gender", "shadow")

add_shape("world.lang.root.vir", "root", "life, vitality, growth", 5)
set_dim("world.lang.root.vir", "class", "noun")
set_dim("world.lang.root.vir", "gender", "animate")

// === Actions ===
add_shape("world.lang.root.kal", "root", "make, create, forge", 5)
set_dim("world.lang.root.kal", "class", "verb")
set_dim("world.lang.root.kal", "connects_to", "engine.edit")

add_shape("world.lang.root.den", "root", "know, understand, perceive", 5)
set_dim("world.lang.root.den", "class", "verb")
set_dim("world.lang.root.den", "connects_to", "world.lore.school.divination")

add_shape("world.lang.root.gar", "root", "fight, struggle, contend", 5)
set_dim("world.lang.root.gar", "class", "verb")

add_shape("world.lang.root.fen", "root", "protect, shield, ward", 5)
set_dim("world.lang.root.fen", "class", "verb")
set_dim("world.lang.root.fen", "connects_to", "world.lore.school.abjuration")

add_shape("world.lang.root.pas", "root", "walk, travel, cross", 5)
set_dim("world.lang.root.pas", "class", "verb")

add_shape("world.lang.root.ren", "root", "give, offer, share", 5)
set_dim("world.lang.root.ren", "class", "verb")

add_shape("world.lang.root.tak", "root", "take, seize, acquire", 5)
set_dim("world.lang.root.tak", "class", "verb")

add_shape("world.lang.root.dir", "root", "see, observe, witness", 5)
set_dim("world.lang.root.dir", "class", "verb")
set_dim("world.lang.root.dir", "connects_to", "world.lore.school.divination")

// === Properties ===
add_shape("world.lang.root.mag", "root", "great, large, powerful", 5)
set_dim("world.lang.root.mag", "class", "adjective")

add_shape("world.lang.root.tin", "root", "small, little, subtle", 5)
set_dim("world.lang.root.tin", "class", "adjective")

add_shape("world.lang.root.bel", "root", "good, right, coherent", 5)
set_dim("world.lang.root.bel", "class", "adjective")

add_shape("world.lang.root.mal", "root", "bad, wrong, incoherent", 5)
set_dim("world.lang.root.mal", "class", "adjective")

add_shape("world.lang.root.nov", "root", "new, young, fresh", 5)
set_dim("world.lang.root.nov", "class", "adjective")

add_shape("world.lang.root.old", "root", "old, ancient, enduring", 5)
set_dim("world.lang.root.old", "class", "adjective")
"""
}

shape world.lang.thalan.affixes : world.lang.thalan {
  type: data
  layer: 5
  """
// Affixes: the structural glue. Each affix IS a dimension modifier.

// === Noun suffixes ===
add_shape("world.lang.affix.a", "suffix", "nominative case (subject)", 5)
set_dim("world.lang.affix.a", "case", "nominative")

add_shape("world.lang.affix.en", "suffix", "accusative case (object)", 5)
set_dim("world.lang.affix.en", "case", "accusative")

add_shape("world.lang.affix.os", "suffix", "genitive case (possession)", 5)
set_dim("world.lang.affix.os", "case", "genitive")

add_shape("world.lang.affix.ar", "suffix", "dative case (recipient)", 5)
set_dim("world.lang.affix.ar", "case", "dative")

add_shape("world.lang.affix.im", "suffix", "locative case (location)", 5)
set_dim("world.lang.affix.im", "case", "locative")

add_shape("world.lang.affix.ul", "suffix", "instrumental case (by means of)", 5)
set_dim("world.lang.affix.ul", "case", "instrumental")

// Plural
add_shape("world.lang.affix.mir", "suffix", "plural marker", 5)
set_dim("world.lang.affix.mir", "number", "plural")

// === Verb suffixes ===
add_shape("world.lang.affix.is", "suffix", "present tense", 5)
set_dim("world.lang.affix.is", "tense", "present")

add_shape("world.lang.affix.as", "suffix", "past tense", 5)
set_dim("world.lang.affix.as", "tense", "past")

add_shape("world.lang.affix.us", "suffix", "future tense", 5)
set_dim("world.lang.affix.us", "tense", "future")

add_shape("world.lang.affix.eth", "suffix", "timeless/eternal (used for laws and truths)", 5)
set_dim("world.lang.affix.eth", "tense", "timeless")

// Evidentiality
add_shape("world.lang.affix.di", "suffix", "direct evidence (I saw it)", 5)
set_dim("world.lang.affix.di", "evidentiality", "direct")

add_shape("world.lang.affix.re", "suffix", "reported (someone told me)", 5)
set_dim("world.lang.affix.re", "evidentiality", "reported")

add_shape("world.lang.affix.in", "suffix", "inferred (I figured it out)", 5)
set_dim("world.lang.affix.in", "evidentiality", "inferred")

// === Derivational prefixes ===
add_shape("world.lang.affix.un", "prefix", "negation, un-, not", 5)
set_dim("world.lang.affix.un", "type", "negation")

add_shape("world.lang.affix.re_pfx", "prefix", "again, re-", 5)
set_dim("world.lang.affix.re_pfx", "type", "repetition")

add_shape("world.lang.affix.kal_pfx", "prefix", "one who does (agent)", 5)
set_dim("world.lang.affix.kal_pfx", "type", "agent")

// === Derivational suffixes ===
add_shape("world.lang.affix.tha", "suffix", "abstract noun (the quality of)", 5)
set_dim("world.lang.affix.tha", "derivation", "abstract_noun")

add_shape("world.lang.affix.ik", "suffix", "adjective from noun (having quality of)", 5)
set_dim("world.lang.affix.ik", "derivation", "adjective")

add_shape("world.lang.affix.el", "suffix", "place of (noun from noun)", 5)
set_dim("world.lang.affix.el", "derivation", "place")
"""
}

shape world.lang.thalan.lexicon : world.lang.thalan {
  type: data
  layer: 5
  """
// Derived vocabulary. Root + affixes = words.
// Each word IS a composed shape connecting roots to meaning.

// === Core words ===
// thal = shape
// thala = shape (nominative) - "a shape..."
// thalen = shape (accusative) - "...the shape"
// thalos = of a shape (genitive)
// thalmir = shapes (plural)
// thalik = structural, shape-like (adjective)
// thaltha = structure (abstract noun: the quality of being shaped)

// per = persist
// peris = persists (present)
// peras = persisted (past)
// pereth = persists (timeless truth)
// pertha = persistence (abstract noun)

// === Beings ===
// val = person
// vala = person (nom)
// kalval = creator (one who makes + person)
// denval = sage, knower (one who knows + person)
// garval = warrior (one who fights + person)
// fenval = guardian (one who protects + person)

// === Compounds ===
// thalan = shape-speech = this language
// ashter = fire-stone = obsidian (volcanic glass)
// lumven = light-water = potion of healing
// silven = tree-water = sap, medicine
// draaer = dragon-air = dragon breath
// nokvir = shadow-life = undeath
// magkal = great-make = forge, create something powerful
// thalden = shape-know = understand the structure

// === Example sentences (VSO) ===
//
// "Pereth thala."
//   persist-TIMELESS shape-NOM
//   "A shape persists." (Law 0)
//
// "Kalis-di kalvala thalen magik."
//   make-PRES-DIRECT creator-NOM shape-ACC great-ADJ
//   "The creator makes a great shape." (I saw it happen)
//
// "Naris-re ashen silim."
//   propagate-PRES-REPORTED fire-ACC forest-LOC
//   "Fire spreads in the forest." (Someone told me)
//
// "Denas-in mortha."
//   know-PAST-INFERRED death-ABSTRACT
//   "Understood mortality." (I figured it out)
//
// "Garus dramir garvalmir-en."
//   fight-FUT dragon-PL warrior-PL-ACC
//   "Dragons will fight the warriors."
"""
}
