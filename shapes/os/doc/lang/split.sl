shape os.doc.lang.split : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "split(str, sep)"
  summary: "Split a string by separator, returns a list."
  see_also: "lang.len, lang.contains, lang.join"
  """
== DESCRIPTION ==
Splits a string into a list of substrings at each separator.

== EXAMPLES ==
  let parts = split("a,b,c", ",")
  // parts = ["a", "b", "c"]
"""
}
