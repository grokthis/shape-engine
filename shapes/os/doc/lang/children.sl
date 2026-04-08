shape os.doc.lang.children : os.doc {
  type: doc
  layer: 4
  section: 3
  synopsis: "children(prefix)"
  summary: "List child segments under a prefix."
  see_also: "lang.content, lang.exists, lang.split"
  """
== DESCRIPTION ==
Returns a list of child segment names under the given prefix.
Note: returns segments, not full IDs. Prepend the prefix to
get the full ID.

== EXAMPLES ==
  let cmds = children("os.shell.cmd")
  for c in cmds { print(c) }
  // prints: ls, cd, cat, ...
"""
}
