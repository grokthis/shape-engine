shape os.render.editor.style {
  type: style
  layer: 4
  """
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  background: var(--bg);
  color: var(--fg);
  font-family: 'SF Mono', 'Menlo', 'Consolas', monospace;
  font-size: 13px;
  height: 100vh;
  overflow: hidden;
}
#editor {
  display: flex;
  flex-direction: column;
  height: 100%;
}
#tabbar {
  display: flex;
  background: var(--bg-dark);
  border-bottom: 1px solid var(--border);
  height: 28px;
  align-items: center;
  overflow-x: auto;
  flex-shrink: 0;
}
.tab {
  padding: 4px 14px;
  font-size: 11px;
  color: var(--fg-dim);
  cursor: pointer;
  border-right: 1px solid var(--border);
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 6px;
}
.tab:hover { color: var(--fg); }
.tab.active { background: var(--bg); color: var(--fg); }
.tab .modified { color: var(--yellow); }
.tab .tab-close {
  font-size: 14px;
  opacity: 0.4;
  cursor: pointer;
}
.tab .tab-close:hover { opacity: 1; color: var(--red); }
#viewport {
  flex: 1;
  display: flex;
  overflow: hidden;
  position: relative;
}
#gutter {
  width: 48px;
  background: var(--bg-dark);
  color: var(--fg-dim);
  text-align: right;
  padding: 4px 8px 4px 0;
  font-size: 12px;
  line-height: 20px;
  overflow: hidden;
  user-select: none;
  flex-shrink: 0;
  border-right: 1px solid var(--border);
}
#content {
  flex: 1;
  padding: 4px 8px;
  line-height: 20px;
  overflow-y: auto;
  overflow-x: hidden;
  white-space: pre;
  outline: none;
  position: relative;
}
.line {
  height: 20px;
  position: relative;
}
.line.current { background: var(--bg-lighter); }
.cursor-block {
  position: absolute;
  width: 7.8px;
  height: 18px;
  top: 1px;
  background: var(--cursor);
  opacity: 0.7;
  animation: blink 1s step-end infinite;
}
.cursor-line {
  position: absolute;
  width: 2px;
  height: 18px;
  top: 1px;
  background: var(--cursor);
  animation: blink 0.6s step-end infinite;
}
@keyframes blink { 50% { opacity: 0; } }
.search-match { background: var(--yellow); color: var(--bg); border-radius: 2px; }
.selection { background: var(--selection); }
#statusline {
  height: 24px;
  display: flex;
  align-items: center;
  padding: 0 8px;
  font-size: 11px;
  flex-shrink: 0;
}
#statusline.normal { background: var(--accent); color: var(--bg); }
#statusline.insert { background: var(--green); color: var(--bg); }
#statusline.visual { background: var(--yellow); color: var(--bg); }
#statusline.command { background: var(--bg-dark); color: var(--fg); }
#status-mode { font-weight: 700; margin-right: 12px; }
#status-file { flex: 1; }
#status-pos { margin-left: 12px; }
#commandline {
  height: 24px;
  display: flex;
  align-items: center;
  padding: 0 8px;
  background: var(--bg-dark);
  border-top: 1px solid var(--border);
  font-size: 12px;
  flex-shrink: 0;
}
#commandline input {
  background: transparent;
  border: none;
  color: var(--fg);
  font-family: inherit;
  font-size: 12px;
  flex: 1;
  outline: none;
}
#commandline .cmd-prefix {
  color: var(--accent);
  margin-right: 4px;
}
#commandline.hidden { display: none; }
#welcome {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--fg-dim);
  font-size: 14px;
  text-align: center;
  line-height: 1.8;
}
"""
}
