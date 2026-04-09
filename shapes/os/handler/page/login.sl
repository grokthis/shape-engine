shape os.handler.page.login {
  type: handler
  layer: 5
  """
// Login page. Your password is a shape with full history.
// New users type a username to create a new userspace.

let title = "Shape OS"
if exists("os.config.window.title") {
  let t = content("os.config.window.title")
  if t != "" {
    set title = t
  }
}

let theme_ref = content("os.config.desktop.theme")
let theme_css = ""
if theme_ref != "" {
  set theme_css = render(theme_ref)
}

let sc = shape_count()

print("<!DOCTYPE html>")
print("<html lang=\"en\">")
print("<head>")
print("<meta charset=\"utf-8\">")
print("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">")
print("<title>" + title + " — Login</title>")
print("<style>")
if theme_css != "" {
  print(theme_css)
}
print("* { margin: 0; padding: 0; box-sizing: border-box; }")
print("body { background: #0a0a0f; color: #c8c8d0; font-family: 'SF Mono', monospace; height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; }")
print(".login-container { width: 320px; text-align: center; }")
print(".login-title { font-size: 1.8rem; font-weight: 300; margin-bottom: 0.3rem; color: #e0e0e8; letter-spacing: 0.05em; }")
print(".login-sub { font-size: 0.75rem; color: #666; margin-bottom: 2rem; }")
print(".login-form { display: flex; flex-direction: column; gap: 0.75rem; }")
print(".login-input { background: #12121a; border: 1px solid #2a2a3a; border-radius: 4px; padding: 0.7rem 1rem; color: #e0e0e8; font-family: inherit; font-size: 0.9rem; outline: none; transition: border-color 0.2s; }")
print(".login-input:focus { border-color: #4a4a6a; }")
print(".login-input::placeholder { color: #444; }")
print(".login-btn { background: #1a1a2e; border: 1px solid #2a2a3a; border-radius: 4px; padding: 0.7rem; color: #c8c8d0; font-family: inherit; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; }")
print(".login-btn:hover { background: #222238; border-color: #3a3a5a; }")
print(".login-error { color: #cc4444; font-size: 0.8rem; min-height: 1.2em; }")
print(".login-info { margin-top: 2rem; font-size: 0.7rem; color: #444; }")
print(".login-info .count { color: #666; }")
print(".login-users { margin-top: 1.5rem; }")
print(".login-users-title { font-size: 0.7rem; color: #555; margin-bottom: 0.5rem; }")
print(".user-list { display: flex; flex-wrap: wrap; gap: 0.4rem; justify-content: center; }")
print(".user-chip { background: #12121a; border: 1px solid #2a2a3a; border-radius: 12px; padding: 0.25rem 0.7rem; font-size: 0.75rem; cursor: pointer; transition: all 0.2s; }")
print(".user-chip:hover { background: #1a1a2e; border-color: #4a4a6a; }")
print("</style>")
print("</head>")
print("<body>")

print("<div class=\"login-container\">")
print("<div class=\"login-title\">" + title + "</div>")
print("<div class=\"login-sub\">" + sc + " shapes</div>")

print("<form class=\"login-form\" id=\"login-form\">")
print("<input class=\"login-input\" type=\"text\" id=\"username\" placeholder=\"username\" autocomplete=\"off\" autofocus>")
print("<input class=\"login-input\" type=\"password\" id=\"password\" placeholder=\"password (shape history)\">")
print("<button class=\"login-btn\" type=\"submit\">enter</button>")
print("<div class=\"login-error\" id=\"error\"></div>")
print("</form>")

// Show existing users.
let users = shapes_under("os.auth.user")
if len(users) > 0 {
  print("<div class=\"login-users\">")
  print("<div class=\"login-users-title\">known users</div>")
  print("<div class=\"user-list\">")
  for u in users {
    let uname = dim(u, "name")
    if uname != "" {
      print("<div class=\"user-chip\" onclick=\"document.getElementById('username').value='" + uname + "';document.getElementById('password').focus()\">" + uname + "</div>")
    }
  }
  print("</div>")
  print("</div>")
}

print("<div class=\"login-info\">new username = new userspace</div>")

print("</div>")

print("<script>")
print("document.getElementById('login-form').addEventListener('submit', async (e) => {")
print("  e.preventDefault();")
print("  const user = document.getElementById('username').value.trim();")
print("  const pass = document.getElementById('password').value;")
print("  const err = document.getElementById('error');")
print("  if (!user) { err.textContent = 'enter a username'; return; }")
print("  try {")
print("    const res = await fetch('/api/login', {")
print("      method: 'POST',")
print("      headers: {'Content-Type': 'application/json'},")
print("      body: JSON.stringify({user: user, password: pass})")
print("    });")
print("    const data = await res.json();")
print("    if (data.error) { err.textContent = data.error; }")
print("    else { window.location.href = '/desktop'; }")
print("  } catch(e) { err.textContent = 'connection failed'; }")
print("});")
print("</script>")
print("</body>")
print("</html>")
"""
}
