// Language: universal language modeling engine.
//
// Language IS shapes. Phonemes are atomic shapes. Morphemes compose them.
// Words compose morphemes. Sentences compose words. Grammar IS the
// structural rules: Law 1 (references close), Law 3 (no contradictions).
// Meaning IS connection to the world graph. A word means what it connects to.
//
// This engine models any language (natural or constructed) and provides
// the tools to build new ones from structural primitives.

shape world.lang : world {
  type: system
  layer: 5
  deps: [world.lore]
  "Universal language engine. Phonology, morphology, syntax, semantics. All shapes."
}
