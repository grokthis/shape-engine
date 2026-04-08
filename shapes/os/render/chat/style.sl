shape os.render.chat.style {
  type: style
  layer: 4
  """
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  background: var(--bg, #1e1e2e);
  color: var(--text, #cdd6f4);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  height: 100vh;
  overflow: hidden;
}
#chat {
  display: flex; flex-direction: column; height: 100vh;
}
#chat-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 10px 16px;
  background: var(--surface, #181825);
  border-bottom: 1px solid var(--border, #313244);
  font-size: 13px; font-weight: 600;
}
#chat-status {
  font-size: 11px; color: var(--subtext, #a6adc8);
  padding: 2px 8px; border-radius: 10px;
  background: var(--surface, #181825);
  border: 1px solid var(--border, #313244);
}
#chat-status.active { color: var(--green, #a6e3a1); border-color: var(--green, #a6e3a1); }
#chat-status.error { color: var(--red, #f38ba8); border-color: var(--red, #f38ba8); }
#chat-messages {
  flex: 1; overflow-y: auto; padding: 16px;
  display: flex; flex-direction: column; gap: 12px;
}
.msg {
  max-width: 85%; padding: 10px 14px; border-radius: 12px;
  font-size: 13px; line-height: 1.5; white-space: pre-wrap;
  word-break: break-word;
}
.msg.user {
  align-self: flex-end;
  background: var(--accent, #89b4fa); color: #11111b;
  border-bottom-right-radius: 4px;
}
.msg.agent {
  align-self: flex-start;
  background: var(--surface, #313244); color: var(--text, #cdd6f4);
  border-bottom-left-radius: 4px;
}
.msg.error {
  align-self: flex-start;
  background: rgba(243, 139, 168, 0.15); color: var(--red, #f38ba8);
  border: 1px solid rgba(243, 139, 168, 0.3);
  border-bottom-left-radius: 4px;
}
.msg.system {
  align-self: center; text-align: center;
  color: var(--subtext, #a6adc8); font-size: 11px;
  padding: 4px 12px;
}
.msg .step-label {
  font-size: 10px; color: var(--subtext, #a6adc8);
  margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.5px;
}
.msg code {
  font-family: 'SF Mono', 'Fira Code', monospace; font-size: 12px;
  background: rgba(0,0,0,0.2); padding: 1px 4px; border-radius: 3px;
}
.msg pre {
  font-family: 'SF Mono', 'Fira Code', monospace; font-size: 12px;
  background: rgba(0,0,0,0.3); padding: 8px 10px; border-radius: 6px;
  margin: 6px 0; overflow-x: auto; white-space: pre;
}
.typing {
  align-self: flex-start; color: var(--subtext, #a6adc8);
  font-size: 12px; padding: 8px 14px;
}
.typing::after {
  content: ''; display: inline-block; width: 12px;
  animation: dots 1.4s infinite;
}
@keyframes dots {
  0%, 20% { content: '.'; }
  40% { content: '..'; }
  60%, 100% { content: '...'; }
}
#chat-input-area {
  display: flex; gap: 8px; padding: 12px 16px;
  background: var(--surface, #181825);
  border-top: 1px solid var(--border, #313244);
}
#chat-input {
  flex: 1; resize: none; border: 1px solid var(--border, #313244);
  border-radius: 8px; padding: 10px 14px;
  background: var(--bg, #1e1e2e); color: var(--text, #cdd6f4);
  font-family: inherit; font-size: 13px; line-height: 1.4;
  outline: none; max-height: 120px;
}
#chat-input:focus { border-color: var(--accent, #89b4fa); }
#chat-input::placeholder { color: var(--subtext, #585b70); }
#chat-send {
  width: 40px; height: 40px; border-radius: 8px; border: none;
  background: var(--accent, #89b4fa); color: #11111b;
  font-size: 16px; cursor: pointer; display: flex;
  align-items: center; justify-content: center;
  transition: opacity 0.15s;
}
#chat-send:hover { opacity: 0.85; }
#chat-send:disabled { opacity: 0.4; cursor: not-allowed; }
"""
}
