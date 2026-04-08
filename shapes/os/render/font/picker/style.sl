shape os.render.font.picker.style {
  type: style
  layer: 4
  """
.font-picker {
  position: absolute;
  background: var(--bg2, #24283b);
  border: 1px solid var(--border, #414868);
  border-radius: 4px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.4);
  max-height: 300px;
  overflow-y: auto;
  min-width: 200px;
  z-index: 100;
}
.font-picker .font-item {
  padding: 6px 12px;
  cursor: pointer;
  font-size: 13px;
}
.font-picker .font-item:hover {
  background: var(--bg3, #292e42);
}
.font-picker .font-item .preview {
  font-size: 16px;
  margin-top: 2px;
  color: var(--fg, #c0caf5);
}
.font-picker .font-item .name {
  font-size: 11px;
  color: var(--fg2, #565f89);
}
"""
}
