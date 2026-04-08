shape os.render.sheet.style {
  type: style
  layer: 4
  """
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body {
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
  font-size: 13px;
  background: var(--bg, #1a1b26);
  color: var(--fg, #c0caf5);
}
#sheet {
  display: flex;
  flex-direction: column;
  height: 100vh;
}
.sheet-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 8px;
  background: var(--bg2, #24283b);
  border-bottom: 1px solid var(--border, #414868);
  min-height: 36px;
}
.sheet-toolbar button {
  background: transparent;
  border: 1px solid var(--border, #414868);
  color: var(--fg, #c0caf5);
  padding: 2px 8px;
  border-radius: 3px;
  cursor: pointer;
  font-size: 12px;
}
.sheet-toolbar button:hover {
  background: var(--bg3, #292e42);
}
.formula-bar {
  display: flex;
  align-items: center;
  padding: 2px 8px;
  background: var(--bg2, #24283b);
  border-bottom: 1px solid var(--border, #414868);
  min-height: 28px;
}
.formula-bar .cell-ref {
  width: 60px;
  text-align: center;
  font-weight: 600;
  color: var(--accent, #7aa2f7);
  border-right: 1px solid var(--border, #414868);
  padding-right: 8px;
  margin-right: 8px;
}
.formula-bar input {
  flex: 1;
  background: transparent;
  border: none;
  color: var(--fg, #c0caf5);
  font-family: inherit;
  font-size: 13px;
  outline: none;
}
.grid-container {
  flex: 1;
  overflow: auto;
  position: relative;
}
.grid {
  display: grid;
  position: relative;
  min-width: max-content;
}
.grid .col-header {
  position: sticky;
  top: 0;
  z-index: 2;
  background: var(--bg2, #24283b);
  border-bottom: 1px solid var(--border, #414868);
  border-right: 1px solid var(--border, #414868);
  text-align: center;
  padding: 4px;
  font-weight: 600;
  font-size: 11px;
  color: var(--fg2, #565f89);
  min-width: 80px;
  user-select: none;
}
.grid .row-header {
  position: sticky;
  left: 0;
  z-index: 1;
  background: var(--bg2, #24283b);
  border-right: 1px solid var(--border, #414868);
  border-bottom: 1px solid var(--border, #414868);
  text-align: center;
  padding: 4px;
  font-weight: 600;
  font-size: 11px;
  color: var(--fg2, #565f89);
  min-width: 40px;
  user-select: none;
}
.grid .corner {
  position: sticky;
  top: 0;
  left: 0;
  z-index: 3;
  background: var(--bg2, #24283b);
  border-right: 1px solid var(--border, #414868);
  border-bottom: 1px solid var(--border, #414868);
}
.grid .cell {
  border-right: 1px solid var(--border, #414868);
  border-bottom: 1px solid var(--border, #414868);
  padding: 2px 4px;
  min-height: 24px;
  min-width: 80px;
  outline: none;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  cursor: cell;
}
.grid .cell:focus, .grid .cell.selected {
  outline: 2px solid var(--accent, #7aa2f7);
  outline-offset: -2px;
  z-index: 1;
}
.grid .cell.editing {
  background: var(--bg, #1a1b26);
  outline: 2px solid var(--green, #9ece6a);
  outline-offset: -2px;
}
.sheet-status {
  display: flex;
  justify-content: space-between;
  padding: 2px 8px;
  background: var(--bg2, #24283b);
  border-top: 1px solid var(--border, #414868);
  font-size: 11px;
  color: var(--fg2, #565f89);
  min-height: 22px;
}
"""
}
