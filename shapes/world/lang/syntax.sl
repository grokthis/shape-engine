// Syntax: sentence structure as shape composition.
//
// A sentence IS a shape graph. Subject, verb, object are child shapes.
// Word order IS the traversal order of the graph.
// Agreement IS Law 1 (references close): the verb agrees with its subject.
// Embedding IS nesting: a clause IS a shape containing other shapes.
//
// Syntax IS the grammar of shape composition applied to language.

shape world.lang.syntax : world.lang {
  type: system
  layer: 5
  deps: [world.lang.morphology]
  "Sentence structure. Phrases, clauses, word order. The grammar of composition."
}

shape world.lang.syntax.rules : world.lang.syntax {
  type: data
  layer: 5
  """
// Syntactic categories (phrase types).
add_shape("world.lang.phrase.NP", "phrase_type", "Noun phrase. A thing or entity.", 5)
set_dim("world.lang.phrase.NP", "head", "noun")
set_dim("world.lang.phrase.NP", "modifiers", "det,adj,rel_clause,pp")

add_shape("world.lang.phrase.VP", "phrase_type", "Verb phrase. An action or state.", 5)
set_dim("world.lang.phrase.VP", "head", "verb")
set_dim("world.lang.phrase.VP", "complements", "NP,PP,CP,AP")

add_shape("world.lang.phrase.PP", "phrase_type", "Prepositional phrase. A relationship.", 5)
set_dim("world.lang.phrase.PP", "head", "preposition")
set_dim("world.lang.phrase.PP", "complement", "NP")

add_shape("world.lang.phrase.AP", "phrase_type", "Adjective phrase. A property.", 5)
set_dim("world.lang.phrase.AP", "head", "adjective")

add_shape("world.lang.phrase.CP", "phrase_type", "Complementizer phrase. An embedded clause.", 5)
set_dim("world.lang.phrase.CP", "head", "complementizer")
set_dim("world.lang.phrase.CP", "complement", "S")

add_shape("world.lang.phrase.S", "phrase_type", "Sentence. The complete thought.", 5)
set_dim("world.lang.phrase.S", "structure", "NP VP")

// Word order typology.
// The default conlang uses VSO (verb-subject-object) because:
// The action IS the shape. The actor IS the structure. The patient IS the character.
// VSO mirrors M' = f(C, S): transform first, then context, then content.
add_shape("world.lang.syntax.word_order", "config", "VSO", 5)
set_dim("world.lang.syntax.word_order", "basic", "VSO")
set_dim("world.lang.syntax.word_order", "adjective", "after_noun")
set_dim("world.lang.syntax.word_order", "genitive", "after_noun")
set_dim("world.lang.syntax.word_order", "relative_clause", "after_noun")
set_dim("world.lang.syntax.word_order", "adposition", "preposition")
"""
}
