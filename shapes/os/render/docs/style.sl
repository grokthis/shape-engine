shape os.render.docs.style {
  type: style
  layer: 4
  """
#docs {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 14px;
  background: var(--bg, #1a1b26);
  color: var(--fg, #a9b1d6);
  display: flex;
  height: 100%;
}
#docs-sidebar {
  width: 240px;
  min-width: 240px;
  background: var(--bg-darker, #13141c);
  border-right: 1px solid var(--border, #292e42);
  overflow-y: auto;
  padding: 12px 0;
}
.sidebar-title {
  font-weight: 600;
  font-size: 15px;
  padding: 8px 16px;
  color: var(--fg-bright, #c0caf5);
}
.sidebar-title a {
  color: inherit;
  text-decoration: none;
}
#docs-search {
  display: block;
  width: calc(100% - 24px);
  margin: 4px 12px 8px;
  padding: 6px 10px;
  background: var(--bg, #1a1b26);
  color: var(--fg, #a9b1d6);
  border: 1px solid var(--border, #292e42);
  border-radius: 4px;
  font-size: 13px;
  outline: none;
}
#docs-search:focus { border-color: var(--accent, #7aa2f7); }
.sidebar-cat {
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--fg-dim, #565f89);
  padding: 12px 16px 4px;
  font-weight: 600;
}
.sidebar-item {
  display: block;
  padding: 4px 16px 4px 24px;
  color: var(--fg, #a9b1d6);
  text-decoration: none;
  font-size: 13px;
}
.sidebar-item:hover { background: var(--bg-highlight, #292e42); color: var(--fg-bright, #c0caf5); }
.sidebar-item.active { background: var(--accent, #7aa2f7); color: #fff; border-radius: 2px; }
.sidebar-item.hidden { display: none; }
#docs-main {
  flex: 1;
  overflow-y: auto;
  padding: 32px 48px;
  max-width: 800px;
}
.breadcrumb {
  font-size: 12px;
  color: var(--fg-dim, #565f89);
  margin-bottom: 16px;
}
.breadcrumb a { color: var(--accent, #7aa2f7); text-decoration: none; }
.breadcrumb a:hover { text-decoration: underline; }
h1 { font-size: 24px; font-weight: 600; color: var(--fg-bright, #c0caf5); margin-bottom: 12px; }
h2 { font-size: 18px; font-weight: 600; color: var(--fg-bright, #c0caf5); margin: 24px 0 12px; }
h3 { font-size: 14px; font-weight: 600; color: var(--accent, #7aa2f7); margin: 20px 0 8px; text-transform: uppercase; letter-spacing: 0.03em; }
p { line-height: 1.6; margin-bottom: 8px; }
.summary { color: var(--fg-dim, #565f89); font-style: italic; margin-bottom: 16px; }
.synopsis {
  background: var(--bg-darker, #13141c);
  padding: 8px 14px;
  border-radius: 4px;
  margin-bottom: 16px;
  border: 1px solid var(--border, #292e42);
}
.synopsis code { font-family: 'SF Mono', 'Fira Code', monospace; color: var(--green, #9ece6a); }
pre {
  background: var(--bg-darker, #13141c);
  padding: 12px 14px;
  border-radius: 4px;
  border: 1px solid var(--border, #292e42);
  font-family: 'SF Mono', 'Fira Code', monospace;
  font-size: 13px;
  line-height: 1.5;
  overflow-x: auto;
  margin-bottom: 12px;
  color: var(--fg, #a9b1d6);
}
.see-also { margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border, #292e42); }
.see-also a {
  display: inline-block;
  margin-right: 12px;
  color: var(--accent, #7aa2f7);
  text-decoration: none;
  font-family: 'SF Mono', 'Fira Code', monospace;
  font-size: 13px;
}
.see-also a:hover { text-decoration: underline; }
.doc-table { width: 100%; border-collapse: collapse; margin-bottom: 16px; }
.doc-table td { padding: 4px 8px; vertical-align: top; }
.doc-name { white-space: nowrap; font-family: 'SF Mono', 'Fira Code', monospace; font-size: 13px; }
.doc-name a { color: var(--accent, #7aa2f7); text-decoration: none; }
.doc-name a:hover { text-decoration: underline; }
.doc-summary { color: var(--fg-dim, #565f89); font-size: 13px; }
"""
}
