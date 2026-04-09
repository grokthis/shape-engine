shape os.render.shortcuts.style {
  type: style
  layer: 5
  """
.shortcuts-root {
  display: flex;
  flex-direction: column;
  height: 100%;
  font-family: system-ui, sans-serif;
  font-size: 13px;
}

.shortcuts-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-bottom: 1px solid rgba(128,128,128,0.2);
  flex-shrink: 0;
}

.shortcuts-toolbar input {
  flex: 1;
  padding: 5px 10px;
  border-radius: 6px;
  border: 1px solid rgba(128,128,128,0.3);
  background: rgba(128,128,128,0.08);
  color: inherit;
  font-size: 13px;
  outline: none;
}

.shortcuts-toolbar input:focus {
  border-color: rgba(128,128,128,0.5);
  background: rgba(128,128,128,0.12);
}

.shortcuts-filter {
  display: flex;
  gap: 6px;
}

.filter-btn {
  padding: 4px 10px;
  border-radius: 5px;
  border: none;
  background: rgba(128,128,128,0.12);
  color: inherit;
  cursor: pointer;
  font-size: 12px;
  transition: background 0.12s;
}

.filter-btn:hover { background: rgba(128,128,128,0.2); }
.filter-btn.active { background: rgba(128,128,128,0.3); font-weight: 600; }

.shortcuts-body {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
}

.shortcut-group {
  margin-bottom: 20px;
}

.shortcut-group-title {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  opacity: 0.5;
  padding: 0 0 6px 0;
  border-bottom: 1px solid rgba(128,128,128,0.15);
  margin-bottom: 6px;
}

.shortcut-row {
  display: flex;
  align-items: center;
  padding: 7px 4px;
  border-radius: 5px;
  gap: 8px;
  cursor: default;
  transition: background 0.1s;
}

.shortcut-row:hover { background: rgba(128,128,128,0.08); }

.shortcut-desc {
  flex: 1;
  font-size: 13px;
}

.shortcut-app {
  font-size: 11px;
  opacity: 0.4;
  min-width: 60px;
  text-align: right;
}

.shortcut-key-wrap {
  display: flex;
  align-items: center;
  gap: 4px;
  min-width: 120px;
  justify-content: flex-end;
}

.shortcut-key {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-family: system-ui, sans-serif;
  font-size: 12px;
  font-weight: 500;
}

.key-part {
  padding: 2px 6px;
  border-radius: 4px;
  background: rgba(128,128,128,0.14);
  box-shadow: 0 1px 0 rgba(0,0,0,0.18);
  border: 1px solid rgba(128,128,128,0.2);
  font-size: 11px;
}

.shortcut-edit-btn {
  padding: 2px 8px;
  border-radius: 4px;
  border: none;
  background: transparent;
  color: inherit;
  opacity: 0;
  cursor: pointer;
  font-size: 11px;
  transition: opacity 0.1s, background 0.1s;
}

.shortcut-row:hover .shortcut-edit-btn {
  opacity: 0.5;
}

.shortcut-edit-btn:hover {
  opacity: 1 !important;
  background: rgba(128,128,128,0.15);
}

.shortcut-row.recording {
  background: rgba(0,100,255,0.08);
  border: 1px solid rgba(0,100,255,0.25);
}

.shortcut-row.recording .key-part {
  background: rgba(0,100,255,0.15);
  border-color: rgba(0,100,255,0.3);
  animation: pulse 1s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 0.7; }
  50% { opacity: 1; }
}

.shortcut-user-badge {
  font-size: 10px;
  padding: 1px 5px;
  border-radius: 3px;
  background: rgba(0,180,100,0.18);
  color: rgba(0,180,100,0.9);
  margin-left: 4px;
}

.shortcuts-empty {
  text-align: center;
  padding: 40px 20px;
  opacity: 0.4;
}

.shortcuts-reset-btn {
  padding: 3px 10px;
  border-radius: 5px;
  border: none;
  background: rgba(220,60,60,0.15);
  color: inherit;
  cursor: pointer;
  font-size: 12px;
  opacity: 0;
  transition: opacity 0.1s;
}

.shortcut-row:hover .shortcuts-reset-btn { opacity: 0.7; }
.shortcuts-reset-btn:hover { opacity: 1 !important; background: rgba(220,60,60,0.25); }
"""
}
