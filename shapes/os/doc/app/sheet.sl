shape os.doc.app.sheet : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Spreadsheet editor"
  summary: "Cells are shapes, formulas are shape-lang, recalculation is wave propagation."
  """
# Sheets

Create and edit spreadsheets where every cell is a shape.

## Usage

- `sheet new budget` - create a new sheet
- `sheet set A1 "Revenue"` - set a cell value
- `sheet get B5` - read a cell value
- `sheet list` - list all sheets

## Formulas

Formulas start with `=` and support:
- Cell references: `=A1+B1`
- SUM: `=SUM(A1:A10)`
- AVERAGE: `=AVERAGE(B1:B5)`
- Arithmetic: `=A1*B1/100`

Formulas are translated to shape-lang internally. Dependencies are tracked
as shape deps, so recalculation happens via wave propagation.

## Web Interface

Open `/office/sheet/<id>` in a browser for the full grid editor with:
- Cell navigation (arrow keys, tab, enter)
- Formula bar
- Copy/paste (TSV format)
- CSV export
"""
}
