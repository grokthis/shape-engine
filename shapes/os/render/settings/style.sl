shape os.render.settings.style {
  type: style
  layer: 4
  """
#settings-root {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 13px;
  background: var(--bg);
  color: var(--fg);
  max-width: 640px;
  margin: 0 auto;
  padding: 24px 20px;
  overflow-y: auto;
  height: 100%;
  box-sizing: border-box;
}
.settings-title {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 20px;
  color: var(--fg);
}
.settings-section-title {
  font-size: 13px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--fg-dim);
  margin: 24px 0 12px 0;
  padding-bottom: 6px;
  border-bottom: 1px solid var(--border);
}
.setting-info {
  flex: 1;
}
.setting-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid var(--border);
}
.setting-label {
  font-size: 13px;
  color: var(--fg);
}
.setting-desc {
  font-size: 11px;
  color: var(--fg-dim);
  margin-top: 2px;
}
.setting-value {
  flex-shrink: 0;
  margin-left: 20px;
}
select, input[type="text"] {
  background: var(--bg-lighter);
  color: var(--fg);
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 6px 10px;
  font-size: 12px;
  font-family: inherit;
  outline: none;
  min-width: 180px;
}
select:focus, input[type="text"]:focus {
  border-color: var(--accent);
}
.theme-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  margin: 8px 0;
}
.theme-card {
  padding: 10px;
  border: 2px solid var(--border);
  border-radius: 6px;
  cursor: pointer;
  text-align: center;
  font-size: 12px;
  transition: border-color 0.15s;
}
.theme-card:hover { border-color: var(--fg-dim); }
.theme-card.active { border-color: var(--accent); }
.theme-preview {
  height: 32px;
  border-radius: 3px;
  margin-bottom: 6px;
}
.btn {
  background: var(--accent);
  color: var(--bg);
  border: none;
  border-radius: 4px;
  padding: 6px 16px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
}
.btn:hover { opacity: 0.9; }
.settings-btn {
  padding: 5px 14px;
  border-radius: 6px;
  border: none;
  background: rgba(128,128,128,0.14);
  color: inherit;
  cursor: pointer;
  font-size: 13px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.15);
  transition: background 0.1s, transform 0.1s;
}
.settings-btn:hover { background: rgba(128,128,128,0.22); }
.settings-btn:active { transform: translateY(1px); }
.status {
  font-size: 11px;
  color: var(--green);
  margin-left: 8px;
  opacity: 0;
  transition: opacity 0.3s;
}
.status.show { opacity: 1; }
"""
}
