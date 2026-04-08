shape os.office.integration.sheet-embed : os.office.integration {
  type: func
  layer: 4
  """
// Embed a sheet in a document block.
// Usage: create a block with block_type=sheet, dims[sheet_ref]=<sheet-id>
// The block shape should dep on the sheet root.
// The doc editor JS detects block_type=sheet and renders an inline grid.
fn embed_sheet(doc_id, block_order, sheet_id) {
  let bid = doc_id + ".b." + block_order
  add_shape(bid, "block", 4)
  set_dim(bid, "block_type", "sheet")
  set_dim(bid, "order", block_order)
  set_dim(bid, "sheet_ref", sheet_id)
  add_dep(bid, sheet_id)
  auto "embedded " + sheet_id + " in " + doc_id
}
"""
}
