shape os.office.integration.pivot : os.office.integration {
  type: func
  layer: 4
  """
// Pivot table: an agent shape that reads source cells, groups, and aggregates.
// The pivot table depends on its source sheet and recomputes via agent.exec.
//
// To create a pivot:
//   shape user.sheet.pivot.sales : user.sheet.data {
//     type: pivot
//     fn: agent.exec
//     source: user.sheet.data
//     rows: category
//     cols: month
//     values: amount
//     agg: sum
//     content: <shape-lang that reads source, groups, aggregates>
//   }
fn create_pivot(name, source, rows_dim, cols_dim, values_dim, agg) {
  let id = "user.sheet.pivot." + name
  add_shape(id, "pivot", 4)
  set_dim(id, "source", source)
  set_dim(id, "rows", rows_dim)
  set_dim(id, "cols", cols_dim)
  set_dim(id, "values", values_dim)
  set_dim(id, "agg", agg)
  add_dep(id, source)
  auto "created pivot " + id
}
"""
}
