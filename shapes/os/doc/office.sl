shape os.doc.office : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Shape Office"
  summary: "Integrated document system. Sheets, docs, fonts, import/export."
  """
# Shape Office

An integrated office suite where documents and spreadsheets ARE shapes.

## Architecture

Everything is shapes:
- A spreadsheet is cells-as-shapes with shape-lang formulas
- A document is blocks-as-shapes with runs-as-shapes
- Recalculation is wave propagation
- Editors are shapes containing JS/CSS

## Components

- **Sheets** (`/office/sheet/<id>`) - Full spreadsheet with formulas, grid, CSV/XLSX export
- **Documents** (`/office/doc/<id>`) - WYSIWYG editor with rich text, tables, headings
- **Fonts** - TTF parsing and serving via font shapes
- **Import/Export** - XLSX, DOCX, CSV, PDF support

## Shell Commands

- `sheet new budget` - create a sheet
- `sheet set A1 "Revenue"` - set a cell
- `doc new report` - create a document
- `doc append report paragraph "Hello"` - add a paragraph
- `export user.sheet.budget xlsx` - download as XLSX
- `export user.doc.report pdf` - download as PDF

## Shape Namespace

```
os.office.*              - office system root
os.office.sheet.*        - sheet shapes (formulas, computation)
os.office.doc.*          - document shapes (blocks, runs, styles)
os.office.font.*         - font shapes
os.render.sheet.*        - sheet editor CSS/JS
os.render.doc.*          - document editor CSS/JS
os.shell.cmd.sheet       - shell commands for sheets
os.shell.cmd.doc         - shell commands for documents
os.shell.cmd.export      - export command
os.shell.cmd.import      - import command
user.sheet.*             - user sheets
user.doc.*               - user documents
```
"""
}
