shape os.doc.lang.content : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "content(id)"
  summary: "Read a shape's content by ID."
  see_also: "lang.dim, lang.exists, lang.children"
  """
== DESCRIPTION ==
Returns the content string of the shape with the given ID.
Returns empty string if the shape doesn't exist.

== EXAMPLES ==
  let c = content("law")
  print(content("os.config.llm.model"))
"""
}
