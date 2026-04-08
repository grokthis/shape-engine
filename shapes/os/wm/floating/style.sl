shape os.wm.floating.style : os.wm.floating {
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
/* Workspace is the desktop surface */
#workspace {
  position: absolute;
  top: 0; left: 0; right: 0;
  bottom: 36px; /* room for taskbar */
  overflow: hidden;
}
.workspace {
  position: absolute;
  inset: 0;
  display: none;
}
.workspace.active { display: block; }
.workspace::before {
  content: '';
  position: absolute;
  inset: 0;
  background: var(--desktop-bg, linear-gradient(135deg, var(--bg-dark) 0%, var(--bg) 50%, var(--bg-lighter) 100%));
  z-index: -1;
}
/* Free-floating windows */
.window {
  position: absolute;
  display: flex;
  flex-direction: column;
  border: 1px solid var(--border);
  border-radius: 6px;
  overflow: hidden;
  background: var(--bg);
  box-shadow: 0 4px 20px rgba(0,0,0,0.4);
  min-width: 200px;
  min-height: 120px;
}
.window.focused {
  border-color: var(--border-focus);
  box-shadow: 0 8px 30px rgba(0,0,0,0.5);
  z-index: 50;
}
.window.maximized {
  top: 0 !important;
  left: 0 !important;
  width: 100% !important;
  height: 100% !important;
  border-radius: 0;
}
.window.minimized { display: none; }
.window-titlebar {
  display: flex;
  align-items: center;
  height: 32px;
  padding: 0 10px;
  background: var(--titlebar);
  color: var(--titlebar-text);
  font-size: 12px;
  font-weight: 600;
  cursor: default;
  flex-shrink: 0;
  user-select: none;
  -webkit-user-select: none;
}
.window.focused .window-titlebar { color: var(--fg); }
.window-title { flex: 1; cursor: grab; }
.window-title:active { cursor: grabbing; }
.window-controls { display: flex; gap: 2px; }
.win-btn {
  background: none;
  border: none;
  color: var(--fg-dim);
  cursor: pointer;
  font-size: 16px;
  line-height: 1;
  width: 28px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 3px;
}
.win-btn:hover { background: var(--bg-lighter); color: var(--fg); }
.win-btn.close:hover { background: var(--red); color: var(--bg); }
.window-content { flex: 1; overflow: hidden; }
.window-content iframe { width: 100%; height: 100%; border: none; }
/* Resize handles */
.window .resize-handle {
  position: absolute;
  z-index: 10;
}
.resize-handle.n  { top: -3px; left: 6px; right: 6px; height: 6px; cursor: n-resize; }
.resize-handle.s  { bottom: -3px; left: 6px; right: 6px; height: 6px; cursor: s-resize; }
.resize-handle.e  { right: -3px; top: 6px; bottom: 6px; width: 6px; cursor: e-resize; }
.resize-handle.w  { left: -3px; top: 6px; bottom: 6px; width: 6px; cursor: w-resize; }
.resize-handle.ne { top: -3px; right: -3px; width: 10px; height: 10px; cursor: ne-resize; }
.resize-handle.nw { top: -3px; left: -3px; width: 10px; height: 10px; cursor: nw-resize; }
.resize-handle.se { bottom: -3px; right: -3px; width: 10px; height: 10px; cursor: se-resize; }
.resize-handle.sw { bottom: -3px; left: -3px; width: 10px; height: 10px; cursor: sw-resize; }
/* Prevent iframe stealing events during drag/resize */
body.dragging iframe,
body.resizing iframe { pointer-events: none; }
/* Taskbar */
#taskbar {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 36px;
  display: flex;
  align-items: center;
  background: var(--statusbar);
  border-top: 1px solid var(--border);
  padding: 0 8px;
  gap: 2px;
  z-index: 100;
}
#taskbar-start {
  padding: 4px 12px;
  font-size: 11px;
  font-weight: 700;
  color: var(--accent);
  cursor: pointer;
  border-radius: 3px;
  margin-right: 4px;
}
#taskbar-start:hover { background: var(--bg-lighter); }
.taskbar-item {
  padding: 4px 12px;
  font-size: 11px;
  color: var(--statusbar-text);
  cursor: pointer;
  border-radius: 3px;
  white-space: nowrap;
  max-width: 160px;
  overflow: hidden;
  text-overflow: ellipsis;
}
.taskbar-item:hover { background: var(--bg-lighter); color: var(--fg); }
.taskbar-item.active { background: var(--bg-lighter); color: var(--fg); border-bottom: 2px solid var(--accent); }
#taskbar-right {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 11px;
  color: var(--statusbar-text);
  padding-right: 8px;
}
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
}
.ws-indicator:hover { background: var(--bg-lighter); color: var(--fg); }
.ws-indicator.active { background: var(--accent); color: var(--bg); }
/* Statusbar hidden in floating mode — replaced by taskbar */
#statusbar { display: none; }
/* Launcher */
#launcher {
  position: fixed;
  inset: 0;
  z-index: 200;
}
.launcher-backdrop {
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,0.5);
}
.launcher-content {
  position: absolute;
  bottom: 44px;
  left: 8px;
  width: 320px;
  background: var(--bg-lighter);
  border: 1px solid var(--border);
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0,0,0,0.5);
}
#launcher-input {
  width: 100%;
  padding: 10px 14px;
  background: transparent;
  border: none;
  border-bottom: 1px solid var(--border);
  color: var(--fg);
  font-size: 13px;
  outline: none;
}
.launcher-results { padding: 4px 0; max-height: 300px; overflow-y: auto; }
.launcher-item {
  padding: 8px 14px;
  cursor: pointer;
  font-size: 13px;
}
.launcher-item:hover,
.launcher-item.selected { background: var(--accent); color: var(--bg); }
/* Hide tiling constructs */
.split { display: contents; }
"""
}
