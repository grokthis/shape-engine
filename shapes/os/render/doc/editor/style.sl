shape os.render.doc.editor.style {
  type: style
  layer: 4
  """
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body {
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 14px;
  background: var(--bg, #1a1b26);
  color: var(--fg, #c0caf5);
}
.doc-toolbar {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 8px;
  background: var(--bg2, #24283b);
  border-bottom: 1px solid var(--border, #414868);
  min-height: 40px;
  flex-wrap: wrap;
}
.doc-toolbar button {
  background: transparent;
  border: 1px solid var(--border, #414868);
  color: var(--fg, #c0caf5);
  padding: 2px 8px;
  border-radius: 3px;
  cursor: pointer;
  font-size: 12px;
  min-width: 28px;
}
.doc-toolbar button:hover { background: var(--bg3, #292e42); }
.doc-toolbar button.active { background: var(--accent, #7aa2f7); color: var(--bg, #1a1b26); }
.doc-toolbar select {
  background: var(--bg2, #24283b);
  color: var(--fg, #c0caf5);
  border: 1px solid var(--border, #414868);
  padding: 2px 4px;
  border-radius: 3px;
  font-size: 12px;
}
.doc-toolbar .separator {
  width: 1px;
  height: 24px;
  background: var(--border, #414868);
  margin: 0 4px;
}
.doc-page {
  max-width: 816px;
  min-height: 1056px;
  margin: 20px auto;
  padding: 72px 72px;
  background: var(--bg, #1a1b26);
  border: 1px solid var(--border, #414868);
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
}
.doc-block {
  min-height: 1em;
  padding: 2px 0;
  outline: none;
  line-height: 1.5;
}
.doc-block:focus {
  background: rgba(122, 162, 247, 0.05);
}
.doc-block[data-type="heading"] { font-weight: 700; }
.doc-block[data-level="1"] { font-size: 24px; margin: 16px 0 8px; }
.doc-block[data-level="2"] { font-size: 20px; margin: 12px 0 6px; }
.doc-block[data-level="3"] { font-size: 16px; margin: 8px 0 4px; }
.doc-block[data-type="list-item"] { padding-left: 24px; }
.doc-block[data-type="list-item"]::before { content: '\2022'; position: absolute; margin-left: -16px; }
.doc-block table {
  border-collapse: collapse;
  width: 100%;
}
.doc-block td, .doc-block th {
  border: 1px solid var(--border, #414868);
  padding: 4px 8px;
  min-width: 60px;
}
.doc-block img { max-width: 100%; }
.doc-status {
  display: flex;
  justify-content: space-between;
  padding: 4px 8px;
  background: var(--bg2, #24283b);
  border-top: 1px solid var(--border, #414868);
  font-size: 11px;
  color: var(--fg2, #565f89);
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
}
@media print {
  .doc-toolbar, .doc-status { display: none; }
  .doc-page { margin: 0; border: none; box-shadow: none; }
  body { background: white; color: black; }
}
"""
}
