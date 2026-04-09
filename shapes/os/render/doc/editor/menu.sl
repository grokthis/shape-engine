shape os.render.doc.editor.menubar {
  type: menubar
  layer: 4
  """
os.render.doc.editor.menu.file
os.render.doc.editor.menu.edit
os.render.doc.editor.menu.format
os.render.doc.editor.menu.insert
os.render.doc.editor.menu.help
  """
}

shape os.render.doc.editor.menu.file {
  type: menu
  label: File
  layer: 4
  """
os.render.doc.editor.menu.file.new
os.render.doc.editor.menu.file.open
os.render.doc.editor.menu.file.sep1
os.render.doc.editor.menu.file.save
os.render.doc.editor.menu.file.save_as
os.render.doc.editor.menu.file.sep2
os.render.doc.editor.menu.file.export_html
os.render.doc.editor.menu.file.export_pdf
os.render.doc.editor.menu.file.print
os.render.doc.editor.menu.file.sep3
os.render.doc.editor.menu.file.close
  """
}

shape os.render.doc.editor.menu.file.new {
  type: menuitem
  label: New Document
  shortcut: Cmd+N
  action: "newDoc()"
  layer: 4
}

shape os.render.doc.editor.menu.file.open {
  type: menuitem
  label: Open...
  shortcut: Cmd+O
  action: "openDoc()"
  layer: 4
}

shape os.render.doc.editor.menu.file.sep1 {
  type: menuseparator
  layer: 4
}

shape os.render.doc.editor.menu.file.save {
  type: menuitem
  label: Save
  shortcut: Cmd+S
  action: "saveDoc()"
  layer: 4
}

shape os.render.doc.editor.menu.file.save_as {
  type: menuitem
  label: Save As...
  shortcut: Cmd+Shift+S
  action: "saveDocAs()"
  layer: 4
}

shape os.render.doc.editor.menu.file.sep2 {
  type: menuseparator
  layer: 4
}

shape os.render.doc.editor.menu.file.export_html {
  type: menuitem
  label: Export as HTML
  action: "exportDoc('html')"
  layer: 4
}

shape os.render.doc.editor.menu.file.export_pdf {
  type: menuitem
  label: Export as PDF
  action: "exportDoc('pdf')"
  layer: 4
}

shape os.render.doc.editor.menu.file.print {
  type: menuitem
  label: Print
  shortcut: Cmd+P
  action: "window.print()"
  layer: 4
}

shape os.render.doc.editor.menu.file.sep3 {
  type: menuseparator
  layer: 4
}

shape os.render.doc.editor.menu.file.close {
  type: menuitem
  label: Close Window
  action: "window.close()"
  layer: 4
}

shape os.render.doc.editor.menu.edit {
  type: menu
  label: Edit
  layer: 4
  """
os.render.doc.editor.menu.edit.undo
os.render.doc.editor.menu.edit.redo
os.render.doc.editor.menu.edit.sep1
os.render.doc.editor.menu.edit.cut
os.render.doc.editor.menu.edit.copy
os.render.doc.editor.menu.edit.paste
os.render.doc.editor.menu.edit.sep2
os.render.doc.editor.menu.edit.select_all
os.render.doc.editor.menu.edit.find
  """
}

shape os.render.doc.editor.menu.edit.undo {
  type: menuitem
  label: Undo
  shortcut: Cmd+Z
  action: "document.execCommand('undo')"
  layer: 4
}

shape os.render.doc.editor.menu.edit.redo {
  type: menuitem
  label: Redo
  shortcut: Cmd+Y
  action: "document.execCommand('redo')"
  layer: 4
}

shape os.render.doc.editor.menu.edit.sep1 {
  type: menuseparator
  layer: 4
}

shape os.render.doc.editor.menu.edit.cut {
  type: menuitem
  label: Cut
  shortcut: Cmd+X
  action: "document.execCommand('cut')"
  layer: 4
}

shape os.render.doc.editor.menu.edit.copy {
  type: menuitem
  label: Copy
  shortcut: Cmd+C
  action: "document.execCommand('copy')"
  layer: 4
}

shape os.render.doc.editor.menu.edit.paste {
  type: menuitem
  label: Paste
  shortcut: Cmd+V
  action: "document.execCommand('paste')"
  layer: 4
}

shape os.render.doc.editor.menu.edit.sep2 {
  type: menuseparator
  layer: 4
}

shape os.render.doc.editor.menu.edit.select_all {
  type: menuitem
  label: Select All
  shortcut: Cmd+A
  action: "document.execCommand('selectAll')"
  layer: 4
}

shape os.render.doc.editor.menu.edit.find {
  type: menuitem
  label: Find...
  shortcut: Cmd+F
  action: "docFind()"
  layer: 4
}

shape os.render.doc.editor.menu.format {
  type: menu
  label: Format
  layer: 4
  """
os.render.doc.editor.menu.format.bold
os.render.doc.editor.menu.format.italic
os.render.doc.editor.menu.format.underline
os.render.doc.editor.menu.format.strike
os.render.doc.editor.menu.format.sep1
os.render.doc.editor.menu.format.clear
  """
}

shape os.render.doc.editor.menu.format.bold {
  type: menuitem
  label: Bold
  shortcut: Cmd+B
  action: "execCmd('bold')"
  layer: 4
}

shape os.render.doc.editor.menu.format.italic {
  type: menuitem
  label: Italic
  shortcut: Cmd+I
  action: "execCmd('italic')"
  layer: 4
}

shape os.render.doc.editor.menu.format.underline {
  type: menuitem
  label: Underline
  shortcut: Cmd+U
  action: "execCmd('underline')"
  layer: 4
}

shape os.render.doc.editor.menu.format.strike {
  type: menuitem
  label: Strikethrough
  action: "execCmd('strikeThrough')"
  layer: 4
}

shape os.render.doc.editor.menu.format.sep1 {
  type: menuseparator
  layer: 4
}

shape os.render.doc.editor.menu.format.clear {
  type: menuitem
  label: Clear Formatting
  action: "execCmd('removeFormat')"
  layer: 4
}

shape os.render.doc.editor.menu.insert {
  type: menu
  label: Insert
  layer: 4
  """
os.render.doc.editor.menu.insert.table
os.render.doc.editor.menu.insert.sep1
os.render.doc.editor.menu.insert.hr
  """
}

shape os.render.doc.editor.menu.insert.table {
  type: menuitem
  label: Table...
  action: "insertTable('custom')"
  layer: 4
}

shape os.render.doc.editor.menu.insert.sep1 {
  type: menuseparator
  layer: 4
}

shape os.render.doc.editor.menu.insert.hr {
  type: menuitem
  label: Horizontal Rule
  action: "insertHR()"
  layer: 4
}

shape os.render.doc.editor.menu.help {
  type: menu
  label: Help
  layer: 4
  """
os.render.doc.editor.menu.help.shortcuts
os.render.doc.editor.menu.help.about
  """
}

shape os.render.doc.editor.menu.help.shortcuts {
  type: menuitem
  label: Keyboard Shortcuts
  action: "showShortcuts()"
  layer: 4
}

shape os.render.doc.editor.menu.help.about {
  type: menuitem
  label: About Shape OS
  action: "showAbout()"
  layer: 4
}
