shape os.render.terminal.style {
  type: style
  layer: 4
  """
#terminal {
  font-family: 'SF Mono', 'Fira Code', 'JetBrains Mono', 'Cascadia Code', monospace;
  font-size: 13px;
  line-height: 1.5;
  color: var(--fg);
  background: var(--bg);
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 0;
}
#output {
  flex: 1;
  overflow-y: auto;
  padding: 12px 16px;
  white-space: pre-wrap;
  word-wrap: break-word;
}
#output .prompt { color: var(--prompt); }
#output .error { color: var(--error); }
#output .dim { color: var(--dim); }
#output .accent { color: var(--accent); }
#input-line {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  border-top: 1px solid var(--border);
  background: var(--bg);
}
#input-line .prompt {
  color: var(--prompt);
  white-space: pre;
  flex-shrink: 0;
}
#input {
  flex: 1;
  background: transparent;
  border: none;
  outline: none;
  color: var(--fg);
  font-family: inherit;
  font-size: inherit;
  line-height: inherit;
  caret-color: var(--cursor);
}
#input::selection { background: var(--selection); }
#status {
  display: flex;
  justify-content: space-between;
  padding: 4px 16px;
  font-size: 11px;
  color: var(--dim);
  border-top: 1px solid var(--border);
  background: var(--bg-dark, #16161e);
}
.welcome {
  color: var(--dim);
  margin-bottom: 8px;
}
"""
}
