shape os.render.browser.style {
  type: style
  layer: 4
  """
#browser {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 13px;
  color: var(--fg, #a9b1d6);
  background: var(--bg, #1a1b26);
  display: flex;
  flex-direction: column;
  height: 100%;
}
#browser-nav {
  display: flex;
  padding: 8px 12px;
  gap: 8px;
  border-bottom: 1px solid var(--border, #292e42);
  background: var(--bg-dark, #16161e);
}
#browser-path {
  flex: 1;
  background: var(--bg-lighter, #1f2335);
  border: 1px solid var(--border, #292e42);
  border-radius: 4px;
  padding: 6px 10px;
  color: var(--fg, #a9b1d6);
  font-family: 'SF Mono', monospace;
  font-size: 12px;
  outline: none;
}
#browser-path:focus { border-color: var(--accent, #7aa2f7); }
#browser-go {
  background: var(--accent, #7aa2f7);
  color: var(--bg, #1a1b26);
  border: none;
  border-radius: 4px;
  padding: 6px 16px;
  cursor: pointer;
  font-weight: 600;
}
#browser-content {
  flex: 1;
  display: flex;
  overflow: hidden;
}
#browser-tree {
  width: 280px;
  overflow-y: auto;
  border-right: 1px solid var(--border, #292e42);
  padding: 8px 0;
}
#browser-detail {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}
.tree-item {
  padding: 4px 12px;
  cursor: pointer;
  font-family: 'SF Mono', monospace;
  font-size: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.tree-item:hover { background: var(--bg-lighter, #1f2335); }
.tree-item.active { background: var(--accent, #7aa2f7); color: var(--bg, #1a1b26); }
.tree-type { color: var(--dim, #565f89); font-size: 10px; margin-left: 4px; }
.detail-id { font-family: 'SF Mono', monospace; color: var(--accent, #7aa2f7); margin-bottom: 8px; }
.detail-type { color: var(--dim, #565f89); margin-bottom: 12px; }
.detail-content {
  background: var(--bg-dark, #16161e);
  border: 1px solid var(--border, #292e42);
  border-radius: 4px;
  padding: 12px;
  white-space: pre-wrap;
  font-family: 'SF Mono', monospace;
  font-size: 12px;
  margin-bottom: 12px;
}
.detail-dims { margin-bottom: 12px; }
.detail-dims dt { color: var(--dim, #565f89); font-size: 11px; }
.detail-dims dd { margin-bottom: 4px; }
.detail-deps a { color: var(--accent, #7aa2f7); text-decoration: none; }
.detail-deps a:hover { text-decoration: underline; }
"""
}
