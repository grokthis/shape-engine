shape os.render.doc.editor.style {
  type: style
  layer: 4
  """
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
.doc-toolbar button,
.doc-toolbar select {
  background: rgba(128,128,128,0.14);
  border: 1px solid rgba(128,128,128,0.28);
  color: var(--fg, #c0caf5);
  padding: 3px 10px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 12px;
  font-weight: 500;
  min-width: 30px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.22), inset 0 1px 0 rgba(255,255,255,0.09);
  transition: background 80ms, box-shadow 80ms, transform 80ms;
  user-select: none;
  appearance: none;
  -webkit-appearance: none;
}
.doc-toolbar button:hover,
.doc-toolbar select:hover {
  background: rgba(128,128,128,0.22);
  box-shadow: 0 2px 6px rgba(0,0,0,0.28), inset 0 1px 0 rgba(255,255,255,0.12);
}
.doc-toolbar button:active {
  background: rgba(0,0,0,0.14);
  box-shadow: inset 0 1px 4px rgba(0,0,0,0.22);
  transform: translateY(1px);
}
.doc-toolbar button.active {
  background: rgba(var(--accent-rgb, 122,162,247), 0.3);
  border-color: rgba(var(--accent-rgb, 122,162,247), 0.5);
  box-shadow: 0 1px 3px rgba(0,0,0,0.2), inset 0 1px 0 rgba(255,255,255,0.1);
}
.doc-toolbar select {
  padding-right: 22px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%23888'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 6px center;
}
.doc-toolbar .separator {
  width: 1px;
  height: 24px;
  background: var(--border, #414868);
  margin: 0 4px;
}
.doc-body {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.doc-scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  background: var(--bg, #1a1b26);
}
.doc-page {
  max-width: 816px;
  min-height: 1056px;
  margin: 20px auto;
  padding: 72px 72px;
  background: #fff;
  color: #111;
  border: 1px solid #ccc;
  box-shadow: 0 2px 12px rgba(0,0,0,0.25);
  cursor: text;
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
  flex-shrink: 0;
}
/* Menu bar */
.menubar {
  display: flex;
  align-items: stretch;
  background: rgba(0,0,0,0.12);
  border-bottom: 1px solid rgba(128,128,128,0.18);
  padding: 0 4px;
  font-size: 12px;
  position: relative;
  z-index: 200;
  user-select: none;
}
.menu { position: relative; }
.menu-label {
  display: block;
  padding: 5px 10px;
  cursor: default;
  color: var(--fg, #c0caf5);
  border-radius: 4px;
  white-space: nowrap;
}
.menu:hover > .menu-label { background: rgba(128,128,128,0.18); }
.menu-dropdown {
  display: none;
  position: absolute;
  top: calc(100% + 2px);
  left: 0;
  min-width: 220px;
  background: var(--bg, #1a1b26);
  border: 1px solid rgba(128,128,128,0.25);
  border-radius: 6px;
  box-shadow: 0 6px 24px rgba(0,0,0,0.4);
  padding: 4px;
  z-index: 1000;
}
.menu:hover > .menu-dropdown { display: block; }
.menuitem {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: default;
  color: var(--fg, #c0caf5);
  gap: 24px;
}
.menuitem:hover { background: rgba(128,128,128,0.2); }
.menuitem-label { flex: 1; }
.shortcut {
  font-family: inherit;
  font-size: 11px;
  color: var(--fg2, #565f89);
  background: rgba(128,128,128,0.12);
  border: 1px solid rgba(128,128,128,0.2);
  border-radius: 3px;
  padding: 1px 5px;
  white-space: nowrap;
}
.menu-sep {
  border: none;
  border-top: 1px solid rgba(128,128,128,0.18);
  margin: 3px 6px;
}

/* Table format dropdown */
.table-fmt { display: none; }
.table-fmt.visible { display: flex; }
.separator.table-fmt.visible { display: block; }
.doc-block table { border-collapse: collapse; width: 100%; }
.doc-block td, .doc-block th {
  border: 1px solid #aaa;
  padding: 6px 10px;
  min-width: 60px;
  position: relative;
}
.doc-block td.selected-cell { background: #e8f0fe; }
@media print {
  .doc-toolbar, .doc-status, .menubar { display: none; }
  .doc-page { margin: 0; border: none; box-shadow: none; }
}
"""
}
