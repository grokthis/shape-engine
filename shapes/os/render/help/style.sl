shape os.render.help.style {
  type: style
  layer: 4
  """
#help-content {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 13px;
  background: var(--bg, #1a1b26);
  color: var(--fg, #c0caf5);
  padding: 16px 20px;
}
#help-content h2 {
  font-size: 16px;
  font-weight: 600;
  margin: 0 0 8px 0;
  color: var(--accent, #7aa2f7);
}
#help-content h3 {
  font-size: 13px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--fg-dim, #565f89);
  margin: 16px 0 6px 0;
  padding-bottom: 4px;
  border-bottom: 1px solid var(--border, #292e42);
}
#help-content p {
  margin: 6px 0;
  line-height: 1.5;
}
.help-synopsis code {
  display: block;
  background: var(--bg-lighter, #24283b);
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 12px;
  margin: 6px 0 10px 0;
  color: var(--green, #9ece6a);
}
.help-summary {
  color: var(--fg-dim, #565f89);
  font-style: italic;
  margin-bottom: 12px !important;
}
#help-content pre {
  background: var(--bg-lighter, #24283b);
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 12px;
  overflow-x: auto;
  margin: 6px 0;
}
.help-see-also {
  margin-top: 16px;
  padding-top: 10px;
  border-top: 1px solid var(--border, #292e42);
  font-size: 12px;
}
.help-see-also a {
  color: var(--accent, #7aa2f7);
  text-decoration: none;
  margin-right: 8px;
}
.help-see-also a:hover { text-decoration: underline; }
"""
}
