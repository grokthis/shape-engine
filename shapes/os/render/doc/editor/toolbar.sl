shape os.render.doc.editor.toolbar {
  type: html
  layer: 4
  """
<div class="doc-toolbar" id="doc-toolbar">
  <select id="font-family" onchange="execFormat('fontFamily', this.value)">
    <option value="sans-serif">Sans Serif</option>
    <option value="serif">Serif</option>
    <option value="monospace">Monospace</option>
  </select>
  <select id="font-size" onchange="execFormat('fontSize', this.value)">
    <option value="11">11</option>
    <option value="12">12</option>
    <option value="14" selected>14</option>
    <option value="16">16</option>
    <option value="18">18</option>
    <option value="24">24</option>
    <option value="36">36</option>
  </select>
  <div class="separator"></div>
  <button id="btn-bold" onclick="execCmd('bold')" title="Bold (Cmd+B)"><b>B</b></button>
  <button id="btn-italic" onclick="execCmd('italic')" title="Italic (Cmd+I)"><i>I</i></button>
  <button id="btn-underline" onclick="execCmd('underline')" title="Underline (Cmd+U)"><u>U</u></button>
  <button id="btn-strike" onclick="execCmd('strikeThrough')" title="Strikethrough"><s>S</s></button>
  <div class="separator"></div>
  <button onclick="execCmd('justifyLeft')" title="Align Left">L</button>
  <button onclick="execCmd('justifyCenter')" title="Align Center">C</button>
  <button onclick="execCmd('justifyRight')" title="Align Right">R</button>
  <div class="separator"></div>
  <button onclick="setHeading(1)" title="Heading 1">H1</button>
  <button onclick="setHeading(2)" title="Heading 2">H2</button>
  <button onclick="setHeading(3)" title="Heading 3">H3</button>
  <button onclick="setHeading(0)" title="Paragraph">P</button>
  <div class="separator"></div>
  <button onclick="insertTable()" title="Insert Table">Table</button>
  <button onclick="exportDoc()" title="Export">Export</button>
</div>
"""
}
