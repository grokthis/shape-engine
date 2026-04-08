shape os.doc.lang.add_shape : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "add_shape(id, type [, content [, layer]])"
  summary: "Create a new shape programmatically."
  see_also: "lang.set_content, lang.set_dim"
  """
== DESCRIPTION ==
Creates a new shape with the given ID and type. Content and
layer are optional. Minimum 2 arguments.

== EXAMPLES ==
  add_shape("user.note", "text", "my note", 5)
  add_shape("user.temp", "data")
"""
}
