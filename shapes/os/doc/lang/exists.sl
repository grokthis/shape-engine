shape os.doc.lang.exists : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "exists(id)"
  summary: "Check if a shape exists."
  see_also: "lang.content, lang.dim, lang.children"
  """
== DESCRIPTION ==
Returns true if a shape with the given ID exists in the engine.

== EXAMPLES ==
  if exists("user.project") { print("found") }
"""
}
