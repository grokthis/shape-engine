shape os.doc.desktop : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Desktop environment"
  summary: "Tiling/floating window manager with workspaces."
  see_also: "app.shell, app.browser"
  """
== DESCRIPTION ==
The desktop is a window manager built entirely from shapes.
All state (windows, workspaces, positions) persists in the
shape graph and survives restarts.

== KEYBOARD SHORTCUTS ==
  Ctrl+1-9           switch workspace
  Ctrl+Space / Cmd+Space   launcher
  Ctrl+Enter          new shell window
  Ctrl+W              close focused window
  Ctrl+Shift+P        command palette
  Alt+Tab             window switcher
  F1                  help for focused app
  Escape              close help/launcher/palette

== WINDOW MANAGEMENT ==
  Drag titlebar       move window
  Drag edges          resize window
  Double-click title  maximize/restore
  Drag to edge        snap (left/right/corners)
  Right-click title   context menu

== CONTEXT MENU ==
Right-click a window titlebar for Close, Maximize,
Minimize, Snap, Move to Workspace, and Help.
Right-click the desktop for New Shell, New Browser,
Launcher, Help, and Refresh.
"""
}
