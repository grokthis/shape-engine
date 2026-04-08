// Semantics: meaning as connection.
//
// A word doesn't have a definition. It has connections.
// The meaning of "fire" IS its connections to: heat, light, destruction,
// the evocation school, the ashlands, red dragons, warmth, cooking, forge.
// Meaning IS the shape graph. Understanding IS traversal.
//
// This is why Thalan works as a programming language AND a natural language.
// Shape-lang is Thalan with different surface syntax.
// "Kalis thalen" (make shape) IS "add_shape()".
// "Peris thala" (shape persists) IS "exists()".
// "Velis thalen" (change shape) IS "edit()".

shape world.lang.semantics : world.lang {
  type: system
  layer: 5
  deps: [world.lang.syntax, world.lore]
  "Meaning IS connection. Words mean what they connect to in the world graph."
}

shape world.lang.semantics.frames : world.lang.semantics {
  type: data
  layer: 5
  """
// Semantic frames: the structural patterns of meaning.
// Each frame IS a shape with slots that words fill.
// A frame IS to semantics what a phrase rule IS to syntax.

add_shape("world.lang.frame.creation", "frame", "Someone creates something.", 5)
set_dim("world.lang.frame.creation", "agent", "animate")
set_dim("world.lang.frame.creation", "patient", "any")
set_dim("world.lang.frame.creation", "result", "new shape exists")
set_dim("world.lang.frame.creation", "verb", "kal")
set_dim("world.lang.frame.creation", "maps_to", "add_shape")

add_shape("world.lang.frame.destruction", "frame", "Something ceases to cohere.", 5)
set_dim("world.lang.frame.destruction", "agent", "any")
set_dim("world.lang.frame.destruction", "patient", "any")
set_dim("world.lang.frame.destruction", "result", "shape dissolves")
set_dim("world.lang.frame.destruction", "verb", "mor")
set_dim("world.lang.frame.destruction", "maps_to", "remove")

add_shape("world.lang.frame.transformation", "frame", "Something changes while persisting.", 5)
set_dim("world.lang.frame.transformation", "agent", "any")
set_dim("world.lang.frame.transformation", "patient", "any")
set_dim("world.lang.frame.transformation", "result", "shape changes, identity persists")
set_dim("world.lang.frame.transformation", "verb", "vel")
set_dim("world.lang.frame.transformation", "maps_to", "edit")

add_shape("world.lang.frame.perception", "frame", "Someone perceives structure.", 5)
set_dim("world.lang.frame.perception", "experiencer", "animate")
set_dim("world.lang.frame.perception", "stimulus", "any")
set_dim("world.lang.frame.perception", "verb", "dir,den")
set_dim("world.lang.frame.perception", "maps_to", "content,dim,exists")

add_shape("world.lang.frame.motion", "frame", "Something moves through structure.", 5)
set_dim("world.lang.frame.motion", "mover", "animate")
set_dim("world.lang.frame.motion", "path", "location")
set_dim("world.lang.frame.motion", "goal", "location")
set_dim("world.lang.frame.motion", "verb", "pas")

add_shape("world.lang.frame.transfer", "frame", "Something passes from one to another.", 5)
set_dim("world.lang.frame.transfer", "agent", "animate")
set_dim("world.lang.frame.transfer", "recipient", "animate")
set_dim("world.lang.frame.transfer", "theme", "any")
set_dim("world.lang.frame.transfer", "verb", "ren,tak")

add_shape("world.lang.frame.conflict", "frame", "Two forces contend.", 5)
set_dim("world.lang.frame.conflict", "combatant_a", "animate")
set_dim("world.lang.frame.conflict", "combatant_b", "animate")
set_dim("world.lang.frame.conflict", "result", "resolution")
set_dim("world.lang.frame.conflict", "verb", "gar")
set_dim("world.lang.frame.conflict", "note", "Law 3: contradictions must resolve")

add_shape("world.lang.frame.protection", "frame", "One guards another from harm.", 5)
set_dim("world.lang.frame.protection", "guardian", "animate")
set_dim("world.lang.frame.protection", "ward", "any")
set_dim("world.lang.frame.protection", "threat", "any")
set_dim("world.lang.frame.protection", "verb", "fen")
set_dim("world.lang.frame.protection", "maps_to", "abjuration")
"""
}

shape world.lang.semantics.engine : world.lang.semantics {
  type: exec
  layer: 5
  """
// The language engine. Parse a Thalan sentence, resolve meaning
// through the world graph, execute the underlying shape operation.
//
// "Kalis thalen" -> parse -> frame:creation(agent=speaker, patient=shape)
//   -> maps_to: add_shape -> execute
//
// Speaking Thalan IS programming. The language IS the engine.
// A mage casting a spell IS evaluating a shape-lang expression.
// "Ashnar!" (fire-propagate!) IS "evocation.fireball()".
//
// This is why magic works in-world: the mage speaks the structure
// and the world's shape engine executes it. Magic IS shape-lang
// spoken through the ethereal plane's evaluation layer.
"""
}
