shape os.shortcuts {
  type: namespace
  layer: 3
  "System shortcut definitions. User overrides live at <user>.shortcuts.**"
}

shape os.shortcuts.document {
  type: namespace
  layer: 3
  "Document editor shortcuts."
}

shape os.shortcuts.document.save {
  type: shortcut
  key: Cmd+S
  action: document_save
  app: document
  category: File
  description: Save document
  layer: 3
}

shape os.shortcuts.document.save_as {
  type: shortcut
  key: Cmd+Shift+S
  action: document_save_as
  app: document
  category: File
  description: Save document as...
  layer: 3
}

shape os.shortcuts.document.open {
  type: shortcut
  key: Cmd+O
  action: document_open
  app: document
  category: File
  description: Open document
  layer: 3
}

shape os.shortcuts.document.new {
  type: shortcut
  key: Cmd+N
  action: document_new
  app: document
  category: File
  description: New document
  layer: 3
}

shape os.shortcuts.document.print {
  type: shortcut
  key: Cmd+P
  action: doc_print
  app: document
  category: File
  description: Print document
  layer: 3
}

shape os.shortcuts.document.bold {
  type: shortcut
  key: Cmd+B
  action: format_bold
  app: document
  category: Format
  description: Bold
  layer: 3
}

shape os.shortcuts.document.italic {
  type: shortcut
  key: Cmd+I
  action: format_italic
  app: document
  category: Format
  description: Italic
  layer: 3
}

shape os.shortcuts.document.underline {
  type: shortcut
  key: Cmd+U
  action: format_underline
  app: document
  category: Format
  description: Underline
  layer: 3
}

shape os.shortcuts.document.strike {
  type: shortcut
  key: Cmd+Shift+X
  action: format_strike
  app: document
  category: Format
  description: Strikethrough
  layer: 3
}

shape os.shortcuts.document.clear_format {
  type: shortcut
  key: Cmd+Shift+C
  action: format_clear
  app: document
  category: Format
  description: Clear formatting
  layer: 3
}

shape os.shortcuts.document.undo {
  type: shortcut
  key: Cmd+Z
  action: edit_undo
  app: document
  category: Edit
  description: Undo
  layer: 3
}

shape os.shortcuts.document.redo {
  type: shortcut
  key: Cmd+Y
  action: edit_redo
  app: document
  category: Edit
  description: Redo
  layer: 3
}

shape os.shortcuts.document.cut {
  type: shortcut
  key: Cmd+X
  action: edit_cut
  app: document
  category: Edit
  description: Cut
  layer: 3
}

shape os.shortcuts.document.copy {
  type: shortcut
  key: Cmd+C
  action: edit_copy
  app: document
  category: Edit
  description: Copy
  layer: 3
}

shape os.shortcuts.document.paste {
  type: shortcut
  key: Cmd+V
  action: edit_paste
  app: document
  category: Edit
  description: Paste
  layer: 3
}

shape os.shortcuts.document.select_all {
  type: shortcut
  key: Cmd+A
  action: edit_select_all
  app: document
  category: Edit
  description: Select all
  layer: 3
}

shape os.shortcuts.document.find {
  type: shortcut
  key: Cmd+F
  action: edit_find
  app: document
  category: Edit
  description: Find
  layer: 3
}

shape os.shortcuts.document.insert_table {
  type: shortcut
  key: Cmd+Shift+T
  action: insert_table
  app: document
  category: Insert
  description: Insert table
  layer: 3
}

shape os.shortcuts.document.insert_hr {
  type: shortcut
  key: Cmd+Shift+H
  action: insert_hr
  app: document
  category: Insert
  description: Insert horizontal rule
  layer: 3
}
