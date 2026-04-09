shape os.render.doc.editor.body {
  type: container
  class: doc-body
  layer: 4
  deps: os.render.doc.editor.toolbar
}

shape os.render.doc.editor.body.scroll {
  type: container
  class: doc-scroll
  layer: 4
}

shape os.render.doc.editor.body.scroll.page {
  type: editable
  id: doc-page
  layer: 4
}

shape os.render.doc.editor.body.status {
  type: statusbar
  id: doc
  layer: 4
  deps: os.render.doc.editor.body.scroll
}
