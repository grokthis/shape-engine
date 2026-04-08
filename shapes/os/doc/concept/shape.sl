shape os.doc.concept.shape : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "shape — the primitive"
  summary: "Everything in the system is a shape: ID, Character (dimensions + content), Structure (deps + emergence)."
  see_also: "concept.character, concept.structure, cmd.cat, cmd.info"
  """
== DESCRIPTION ==
A shape is the fundamental unit. It has:
  - ID: a dotted path (e.g. engine.edit, os.shell.cmd.ls)
  - Character: what changes (dimensions map + free content)
  - Structure: the geometry governing transformation (deps, layer, emergence)
  - Tick: when it last changed

Everything in Shape OS is a shape: commands, config, apps, tests,
documentation, the laws themselves.

== EXAMPLES ==
  cat law                 # see the law shape
  info engine.edit        # full dump of a shape
  ls os.shell.cmd         # all commands are shapes
"""
}
