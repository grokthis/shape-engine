shape os.wm.tiling.style : os.wm.tiling {
  type: style
  layer: 4
  """
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body {
  height: 100%;
  background: var(--bg);
  color: var(--fg);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 13px;
  overflow: hidden;
}
#statusbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 28px;
  padding: 0 12px;
  background: var(--statusbar);
  color: var(--statusbar-text);
  font-size: 11px;
  border-bottom: 1px solid var(--border);
  -webkit-app-region: drag;
}
#statusbar-left { display: flex; gap: 4px; }
#statusbar-center {
  font-family: 'SF Mono', monospace;
  color: var(--fg-dim);
  font-weight: 600;
}
#statusbar-right { display: flex; gap: 12px; }
.ws-indicator {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  border-radius: 3px;
  font-size: 10px;
  font-weight: 600;
  cursor: pointer;
  -webkit-app-region: no-drag;
}
.ws-indicator:hover { background: var(--bg-lighter); color: var(--fg); }
.ws-indicator.active { background: var(--accent); color: var(--bg); }
#workspace {
  height: calc(100% - 28px);
  position: relative;
}
.workspace {
  position: absolute;
  inset: 0;
  display: none;
}
.workspace.active { display: flex; }
.split {
  display: flex;
  flex: 1;
  gap: 2px;
}
.hsplit { flex-direction: row; }
.vsplit { flex-direction: column; }
.window {
  flex: 1;
  display: flex;
  flex-direction: column;
  border: 1px solid var(--border);
  border-radius: 4px;
  overflow: hidden;
  margin: 2px;
}
.window.focused { border-color: var(--border-focus); }
.window-titlebar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 28px;
  padding: 0 10px;
  background: var(--titlebar);
  color: var(--titlebar-text);
  font-size: 11px;
  font-weight: 600;
  cursor: default;
  flex-shrink: 0;
}
.window.focused .window-titlebar { color: var(--fg); }
.window-title { flex: 1; }
.window-controls { display: flex; gap: 6px; }
.win-btn {
  background: none;
  border: none;
  color: var(--fg-dim);
  cursor: pointer;
  font-size: 14px;
  line-height: 1;
  padding: 0 2px;
}
.win-btn:hover { color: var(--fg); }
.win-btn.close:hover { color: var(--red); }
.window-content { flex: 1; min-height: 0; overflow: hidden; display: flex; flex-direction: column; }
.app-root { flex: 1; min-height: 0; display: flex; flex-direction: column; overflow: hidden; }
.window-content iframe { width: 100%; height: 100%; border: none; }
#launcher {
  position: fixed;
  inset: 0;
  z-index: 100;
}
.launcher-backdrop {
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,0.5);
}
.launcher-content {
  position: absolute;
  top: 20%;
  left: 50%;
  transform: translateX(-50%);
  width: 400px;
  background: var(--bg-lighter);
  border: 1px solid var(--border);
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0,0,0,0.5);
}
#launcher-input {
  width: 100%;
  padding: 12px 16px;
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--border);
  color: var(--fg);
  font-size: 14px;
  outline: none;
}
.launcher-results { padding: 4px 0; }
.launcher-item {
  padding: 8px 16px;
  cursor: pointer;
  font-size: 13px;
}
.launcher-item:hover,
.launcher-item.selected { background: var(--accent); color: var(--bg); }
/* Resize gutter between tiled windows */
.resize-gutter {
  flex: 0 0 6px;
  background: var(--border);
  cursor: col-resize;
  z-index: 10;
  transition: background 0.15s;
}
.resize-gutter:hover,
.resize-gutter.dragging { background: var(--accent); }
.vsplit > .resize-gutter { cursor: row-resize; }
/* During drag, prevent iframes from stealing mouse events */
.resizing iframe { pointer-events: none; }
/* Windows use explicit flex-basis when resized, not flex:1 */
.window.sized { flex: 0 0 auto; }
"""
}
