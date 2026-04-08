shape os.doc.concept.character : os.doc {
  type: doc
  layer: 4
  section: 7
  synopsis: "character — what changes"
  summary: "Dimensions (key-value map) and Content (free text). The mutable part of a shape."
  see_also: "concept.shape, concept.structure, cmd.edit, cmd.echo"
  """
== DESCRIPTION ==
Character is the part of a shape that changes. It has two parts:
  - Dimensions: a map of key-value strings (type, name, layer, etc.)
  - Content: free text (code, documentation, CSS, data, etc.)

When you edit a shape, you change its character. The structure
stays the same. This triggers wave propagation.

== EXAMPLES ==
  cat engine.edit         # shows dimensions and content
  echo "new text" > id    # set content
  edit id "new content"   # edit content, propagate wave
"""
}
