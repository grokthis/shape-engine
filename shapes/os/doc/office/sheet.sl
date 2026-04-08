shape os.doc.office.sheet : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Sheet formulas"
  summary: "Formula reference for the spreadsheet system."
  """
# Sheet Formula Reference

## Cell References

- `=A1` - value of cell A1
- `=A1+B1` - arithmetic on cell values
- `=A1*B1/100` - multiplication and division

## Functions

- `=SUM(A1:A10)` - sum of a range
- `=AVERAGE(B1:B5)` - average of a range
- `=MIN(C1:C10)` / `=MAX(C1:C10)` - min/max
- `=COUNT(A1:A10)` - count non-empty cells
- `=IF(A1>0, "positive", "negative")` - conditional

## How It Works

Formulas are translated to shape-lang by the JS editor:
1. `=SUM(A1:A5)` becomes `sum([content(sheet.A1), ..., content(sheet.A5)])`
2. Cell dependencies become shape deps
3. When a dep changes, wave propagation re-evaluates the formula
4. The result is stored in the cell's `value` dimension
"""
}
