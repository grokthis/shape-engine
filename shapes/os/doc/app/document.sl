shape os.doc.app.document : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Document editor"
  summary: "WYSIWYG document editing. Blocks and runs are shapes."
  """
# Document

Create and edit rich text documents where every block and run is a shape.

## Usage

- `doc new report` - create a new document
- `doc append report paragraph "Hello world"` - add a paragraph
- `doc append report heading "Title"` - add a heading
- `doc list` - list all documents

## Web Interface

Open `/office/doc/<id>` in a browser for the full WYSIWYG editor with:
- Rich text formatting (bold, italic, underline)
- Headings (H1-H6)
- Tables
- Keyboard shortcuts (Cmd+B, Cmd+I, Cmd+U)
- HTML export
"""
}
