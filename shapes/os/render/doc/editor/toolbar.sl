shape os.render.doc.editor.toolbar {
  type: toolbar
  layer: 4
  deps: os.render.doc.editor.menubar
  """
os.render.doc.editor.toolbar.font_family
os.render.doc.editor.toolbar.font_size
os.render.doc.editor.toolbar.sep1
os.render.doc.editor.toolbar.bold
os.render.doc.editor.toolbar.italic
os.render.doc.editor.toolbar.underline
os.render.doc.editor.toolbar.strike
os.render.doc.editor.toolbar.sep2
os.render.doc.editor.toolbar.align
os.render.doc.editor.toolbar.heading
os.render.doc.editor.toolbar.sep4
os.render.doc.editor.toolbar.table_insert
os.render.doc.editor.toolbar.table_fmt
  """
}

shape os.render.doc.editor.toolbar.font_family {
  type: select
  id: font-family
  action: "execFormat('fontFamily',this.value)"
  """
--- Sans-serif
System UI:system-ui, sans-serif
Inter:Inter, sans-serif
Roboto:Roboto, sans-serif
Open Sans:Open Sans, sans-serif
Lato:Lato, sans-serif
Noto Sans:Noto Sans, sans-serif
Source Sans:Source Sans 3, sans-serif
Nunito:Nunito, sans-serif
Poppins:Poppins, sans-serif
Raleway:Raleway, sans-serif
Montserrat:Montserrat, sans-serif
Ubuntu:Ubuntu, sans-serif
Work Sans:Work Sans, sans-serif
Mulish:Mulish, sans-serif
DM Sans:DM Sans, sans-serif
Outfit:Outfit, sans-serif
Figtree:Figtree, sans-serif
Plus Jakarta Sans:Plus Jakarta Sans, sans-serif
--- Serif
Georgia:Georgia, serif
Merriweather:Merriweather, serif
Playfair Display:Playfair Display, serif
Lora:Lora, serif
PT Serif:PT Serif, serif
Libre Baskerville:Libre Baskerville, serif
EB Garamond:EB Garamond, serif
Cormorant Garamond:Cormorant Garamond, serif
Crimson Text:Crimson Text, serif
Source Serif:Source Serif 4, serif
Bitter:Bitter, serif
Spectral:Spectral, serif
--- Monospace
System Mono:monospace
Source Code Pro:Source Code Pro, monospace
JetBrains Mono:JetBrains Mono, monospace
Fira Code:Fira Code, monospace
IBM Plex Mono:IBM Plex Mono, monospace
Roboto Mono:Roboto Mono, monospace
Space Mono:Space Mono, monospace
Inconsolata:Inconsolata, monospace
Courier Prime:Courier Prime, monospace
--- Display
Oswald:Oswald, sans-serif
Bebas Neue:Bebas Neue, cursive
Anton:Anton, sans-serif
Righteous:Righteous, cursive
Pacifico:Pacifico, cursive
  """
}

shape os.render.doc.editor.toolbar.font_size {
  type: select
  id: font-size
  default_value: 14
  action: "execFormat('fontSize',this.value)"
  """
11:11
12:12
14:14
16:16
18:18
24:24
36:36
  """
}

shape os.render.doc.editor.toolbar.sep1 {
  type: separator
  layer: 4
}

shape os.render.doc.editor.toolbar.bold {
  type: button
  layer: 4
  label: B
  title: "Bold (Cmd+B)"
  action: "execCmd('bold')"
}

shape os.render.doc.editor.toolbar.italic {
  type: button
  layer: 4
  label: I
  title: "Italic (Cmd+I)"
  action: "execCmd('italic')"
}

shape os.render.doc.editor.toolbar.underline {
  type: button
  layer: 4
  label: U
  title: "Underline (Cmd+U)"
  action: "execCmd('underline')"
}

shape os.render.doc.editor.toolbar.strike {
  type: button
  layer: 4
  label: S
  title: Strikethrough
  action: "execCmd('strikeThrough')"
}

shape os.render.doc.editor.toolbar.sep2 {
  type: separator
  layer: 4
}

shape os.render.doc.editor.toolbar.align {
  type: select
  id: align-select
  layer: 4
  action: "if(this.value){execCmd(this.value)}"
  """
Align:
Left:justifyLeft
Center:justifyCenter
Right:justifyRight
Justified:justifyFull
  """
}

shape os.render.doc.editor.toolbar.heading {
  type: select
  id: heading-select
  layer: 4
  action: "setHeading(parseInt(this.value))"
  """
Paragraph:0
Heading 1:1
Heading 2:2
Heading 3:3
Heading 4:4
Heading 5:5
Heading 6:6
  """
}

shape os.render.doc.editor.toolbar.sep4 {
  type: separator
  layer: 4
}

shape os.render.doc.editor.toolbar.table_insert {
  type: select
  id: table-insert
  layer: 4
  action: "if(this.value){insertTable(this.value);this.value=''}"
  """
Table:
--- Preset sizes
2 × 2:2x2
3 × 3:3x3
4 × 4:4x4
5 × 5:5x5
2 × 5:2x5
3 × 6:3x6
--- Custom
Custom...:custom
  """
}

shape os.render.doc.editor.toolbar.table_fmt {
  type: select
  id: table-fmt
  layer: 4
  class: table-fmt
  action: "if(this.value){tableCmd(this.value);this.value=''}"
  """
Table:
--- Rows
Add Row Below:add_row
Add Row Above:add_row_above
Delete Row:del_row
--- Columns
Add Column Right:add_col
Add Column Left:add_col_left
Delete Column:del_col
--- Cells
Merge Selected:merge
Split Cell:split
  """
}

