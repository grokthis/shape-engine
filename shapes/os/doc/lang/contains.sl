shape os.doc.lang.contains : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "contains(str, substr)"
  summary: "Check if a string contains a substring."
  see_also: "lang.has_prefix, lang.split"
  """
== DESCRIPTION ==
Returns true if str contains substr.

== EXAMPLES ==
  if contains(content("law"), "persist") { print("yes") }
"""
}
