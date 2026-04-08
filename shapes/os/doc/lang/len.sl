shape os.doc.lang.len : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "len(value)"
  summary: "Length of a string or list."
  see_also: "lang.split, lang.children"
  """
== DESCRIPTION ==
Returns the length of a string (character count) or a list
(element count).

== EXAMPLES ==
  len("hello")              // 5
  len(children("os.shell")) // number of shell children
"""
}
