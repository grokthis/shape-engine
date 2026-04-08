shape os.render.editor.script {
  type: script
  layer: 4
  """
(function() {
  var root = document.getElementById('editor');

  // State.
  var buffers = [];       // [{id, lines, modified, cursor:{row,col}, scroll}]
  var activeIdx = -1;
  var mode = 'normal';    // normal, insert, command, search
  var cmdBuf = '';
  var searchTerm = '';
  var yankBuf = [];
  var message = '';
  var count = '';         // numeric prefix

  // DOM refs.
  var tabbar, viewport, gutter, content, statusline, commandline, cmdInput, welcome;

  function init() {
    root.innerHTML = '<div id="tabbar"></div>' +
      '<div id="viewport"><div id="gutter"></div><div id="content" tabindex="0"><div id="welcome">vip — vi perfected<br>shape editor<br><br>:e &lt;shape-id&gt; to open<br>:q to close</div></div></div>' +
      '<div id="statusline" class="normal"><span id="status-mode">NORMAL</span><span id="status-file"></span><span id="status-pos"></span></div>' +
      '<div id="commandline" class="hidden"><span class="cmd-prefix">:</span><input type="text" id="cmd-input"></div>';

    tabbar = document.getElementById('tabbar');
    viewport = document.getElementById('viewport');
    gutter = document.getElementById('gutter');
    content = document.getElementById('content');
    statusline = document.getElementById('statusline');
    commandline = document.getElementById('commandline');
    cmdInput = document.getElementById('cmd-input');
    welcome = document.getElementById('welcome');

    content.addEventListener('keydown', handleKey);
    content.addEventListener('click', handleClick);
    cmdInput.addEventListener('keydown', handleCmdKey);
    content.focus();

    // Open shape from URL param.
    var params = new URLSearchParams(window.location.search);
    var openId = params.get('id');
    if (openId) openBuffer(openId);
  }

  function buf() { return buffers[activeIdx]; }

  function openBuffer(id) {
    // Check if already open.
    for (var i = 0; i < buffers.length; i++) {
      if (buffers[i].id === id) { activeIdx = i; render(); return; }
    }
    // Fetch shape content.
    fetch('/shape/' + id).then(function(r) {
      if (!r.ok) { setMsg('shape not found: ' + id); render(); return r.text(); }
      return r.json();
    }).then(function(s) {
      if (!s || !s.id) return;
      var text = s.character ? (s.character.content || '') : '';
      var lines = text.split('\n');
      if (lines.length === 0) lines = [''];
      buffers.push({ id: s.id, lines: lines, modified: false, cursor: {row: 0, col: 0}, scroll: 0 });
      activeIdx = buffers.length - 1;
      render();
    });
  }

  function saveBuffer() {
    var b = buf();
    if (!b) return;
    var text = b.lines.join('\n');
    fetch('/shape', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({ id: b.id, character: { dimensions: {}, content: text } })
    }).then(function(r) {
      if (r.ok) { b.modified = false; setMsg('"' + b.id + '" written'); render(); }
      else { setMsg('save failed'); render(); }
    });
  }

  function closeBuffer(idx) {
    if (idx < 0 || idx >= buffers.length) return;
    buffers.splice(idx, 1);
    if (activeIdx >= buffers.length) activeIdx = buffers.length - 1;
    render();
  }

  function setMsg(m) { message = m; }

  // --- Rendering ---
  function render() {
    renderTabs();
    renderContent();
    renderStatus();
    if (welcome) welcome.style.display = buffers.length === 0 ? '' : 'none';
  }

  function renderTabs() {
    var html = '';
    for (var i = 0; i < buffers.length; i++) {
      var b = buffers[i];
      var cls = i === activeIdx ? ' active' : '';
      var mod = b.modified ? '<span class="modified">+</span>' : '';
      html += '<div class="tab' + cls + '" data-idx="' + i + '">' +
        b.id + mod + ' <span class="tab-close" data-close="' + i + '">&times;</span></div>';
    }
    tabbar.innerHTML = html;
    tabbar.querySelectorAll('.tab').forEach(function(t) {
      t.addEventListener('click', function(e) {
        if (e.target.classList.contains('tab-close')) {
          closeBuffer(parseInt(e.target.dataset.close));
          return;
        }
        activeIdx = parseInt(this.dataset.idx);
        render();
        content.focus();
      });
    });
  }

  function renderContent() {
    var b = buf();
    if (!b) { content.innerHTML = welcome ? welcome.outerHTML : ''; gutter.innerHTML = ''; return; }

    var viewH = viewport.offsetHeight;
    var lineH = 20;
    var visibleLines = Math.floor(viewH / lineH);
    // Ensure cursor is visible.
    if (b.cursor.row < b.scroll) b.scroll = b.cursor.row;
    if (b.cursor.row >= b.scroll + visibleLines) b.scroll = b.cursor.row - visibleLines + 1;

    var gutterHtml = '';
    var contentHtml = '';
    var end = Math.min(b.lines.length, b.scroll + visibleLines + 5);

    for (var i = b.scroll; i < end; i++) {
      var num = i + 1;
      gutterHtml += '<div style="height:20px">' + num + '</div>';

      var line = escHtml(b.lines[i]);
      var isCurrent = i === b.cursor.row;
      var cls = isCurrent ? ' current' : '';

      if (isCurrent) {
        var col = Math.min(b.cursor.col, b.lines[i].length);
        var before = escHtml(b.lines[i].substring(0, col));
        var cursorChar = b.lines[i][col] || ' ';
        var after = escHtml(b.lines[i].substring(col + 1));
        var cursorCls = mode === 'insert' ? 'cursor-line' : 'cursor-block';
        var charW = 7.8;
        var left = col * charW;
        line = before + '<span class="' + cursorCls + '" style="left:' + left + 'px"></span>' + escHtml(cursorChar) + after;
      }

      // Highlight search matches.
      if (searchTerm && !isCurrent) {
        var re = new RegExp(escRegex(searchTerm), 'gi');
        line = b.lines[i].replace(re, function(m) { return '<span class="search-match">' + escHtml(m) + '</span>'; });
      }

      contentHtml += '<div class="line' + cls + '">' + line + '</div>';
    }

    gutter.innerHTML = gutterHtml;
    gutter.style.paddingTop = '4px';
    content.innerHTML = contentHtml;
    content.scrollTop = 0;
  }

  function renderStatus() {
    var b = buf();
    var modeName = mode.toUpperCase();
    statusline.className = mode;
    document.getElementById('status-mode').textContent = '-- ' + modeName + ' --';
    document.getElementById('status-file').textContent = b ? (b.id + (b.modified ? ' [+]' : '')) : '';
    document.getElementById('status-pos').textContent = b ? ((b.cursor.row + 1) + ':' + (b.cursor.col + 1)) : '';

    if (message) {
      document.getElementById('status-file').textContent = message;
      message = '';
    }
  }

  // --- Input handling ---
  function handleKey(e) {
    if (mode === 'normal') normalKey(e);
    else if (mode === 'insert') insertKey(e);
    e.preventDefault();
    e.stopPropagation();
  }

  function handleClick(e) {
    content.focus();
    // TODO: click-to-position
  }

  function normalKey(e) {
    var b = buf();
    if (!b) {
      if (e.key === ':') { enterCommand(); return; }
      return;
    }
    var key = e.key;

    // Numeric prefix.
    if (key >= '0' && key <= '9' && (count !== '' || key !== '0')) {
      count += key;
      return;
    }
    var n = count ? parseInt(count) : 1;
    count = '';

    // Movement.
    if (key === 'h' || key === 'ArrowLeft') { b.cursor.col = Math.max(0, b.cursor.col - n); }
    else if (key === 'l' || key === 'ArrowRight') { b.cursor.col = Math.min(b.lines[b.cursor.row].length - 1, b.cursor.col + n); if (b.cursor.col < 0) b.cursor.col = 0; }
    else if (key === 'j' || key === 'ArrowDown') { b.cursor.row = Math.min(b.lines.length - 1, b.cursor.row + n); clampCol(b); }
    else if (key === 'k' || key === 'ArrowUp') { b.cursor.row = Math.max(0, b.cursor.row - n); clampCol(b); }
    else if (key === '0') { b.cursor.col = 0; }
    else if (key === '$') { b.cursor.col = Math.max(0, b.lines[b.cursor.row].length - 1); }
    else if (key === 'g') { b.cursor.row = 0; b.cursor.col = 0; }
    else if (key === 'G') { b.cursor.row = b.lines.length - 1; clampCol(b); }
    else if (key === 'w') { wordForward(b, n); }
    else if (key === 'b') { wordBackward(b, n); }
    // Scrolling.
    else if (e.ctrlKey && key === 'd') { b.cursor.row = Math.min(b.lines.length - 1, b.cursor.row + Math.floor(20 * n)); clampCol(b); }
    else if (e.ctrlKey && key === 'u') { b.cursor.row = Math.max(0, b.cursor.row - Math.floor(20 * n)); clampCol(b); }
    // Insert mode.
    else if (key === 'i') { mode = 'insert'; }
    else if (key === 'I') { b.cursor.col = 0; mode = 'insert'; }
    else if (key === 'a') { b.cursor.col = Math.min(b.lines[b.cursor.row].length, b.cursor.col + 1); mode = 'insert'; }
    else if (key === 'A') { b.cursor.col = b.lines[b.cursor.row].length; mode = 'insert'; }
    else if (key === 'o') { b.lines.splice(b.cursor.row + 1, 0, ''); b.cursor.row++; b.cursor.col = 0; b.modified = true; mode = 'insert'; }
    else if (key === 'O') { b.lines.splice(b.cursor.row, 0, ''); b.cursor.col = 0; b.modified = true; mode = 'insert'; }
    // Editing.
    else if (key === 'x') { for (var xi = 0; xi < n; xi++) delChar(b); }
    else if (key === 'd') { handleD(b, n); return; }  // wait for second key
    else if (key === 'y') { handleY(b, n); return; }
    else if (key === 'p') { paste(b, n); }
    else if (key === 'u') { setMsg('undo not yet implemented'); }
    else if (key === 'J') { joinLine(b); }
    // Search.
    else if (key === '/') { enterSearch(); return; }
    else if (key === 'n') { searchNext(b, 1); }
    else if (key === 'N') { searchNext(b, -1); }
    // Command.
    else if (key === ':') { enterCommand(); return; }

    render();
  }

  // dd = delete line, d$ = delete to end, etc.
  var pendingD = false;
  function handleD(b, n) {
    if (pendingD) { // dd
      pendingD = false;
      for (var i = 0; i < n; i++) {
        if (b.lines.length <= 1) { yankBuf = [b.lines[0]]; b.lines[0] = ''; break; }
        yankBuf = b.lines.splice(b.cursor.row, 1);
        if (b.cursor.row >= b.lines.length) b.cursor.row = b.lines.length - 1;
      }
      b.modified = true;
      clampCol(b);
      render();
      return;
    }
    pendingD = true;
    // Wait for next key — use a one-shot listener.
    var once = function(e2) {
      content.removeEventListener('keydown', once, true);
      e2.preventDefault();
      e2.stopPropagation();
      pendingD = false;
      if (e2.key === 'd') {
        // dd
        for (var i = 0; i < n; i++) {
          if (b.lines.length <= 1) { yankBuf = [b.lines[0]]; b.lines[0] = ''; break; }
          yankBuf = b.lines.splice(b.cursor.row, 1);
          if (b.cursor.row >= b.lines.length) b.cursor.row = b.lines.length - 1;
        }
        b.modified = true;
      } else if (e2.key === '$') {
        yankBuf = [b.lines[b.cursor.row].substring(b.cursor.col)];
        b.lines[b.cursor.row] = b.lines[b.cursor.row].substring(0, b.cursor.col);
        b.modified = true;
      } else if (e2.key === 'w') {
        // Delete word.
        var line = b.lines[b.cursor.row];
        var end = b.cursor.col;
        while (end < line.length && /\w/.test(line[end])) end++;
        while (end < line.length && /\s/.test(line[end])) end++;
        yankBuf = [line.substring(b.cursor.col, end)];
        b.lines[b.cursor.row] = line.substring(0, b.cursor.col) + line.substring(end);
        b.modified = true;
      }
      clampCol(b);
      render();
    };
    content.addEventListener('keydown', once, true);
  }

  var pendingY = false;
  function handleY(b, n) {
    var once = function(e2) {
      content.removeEventListener('keydown', once, true);
      e2.preventDefault();
      e2.stopPropagation();
      if (e2.key === 'y') {
        yankBuf = [];
        for (var i = 0; i < n; i++) {
          var r = b.cursor.row + i;
          if (r < b.lines.length) yankBuf.push(b.lines[r]);
        }
        setMsg(yankBuf.length + ' lines yanked');
      }
      render();
    };
    content.addEventListener('keydown', once, true);
  }

  function paste(b, n) {
    if (yankBuf.length === 0) return;
    for (var i = 0; i < n; i++) {
      if (yankBuf.length === 1 && yankBuf[0].indexOf('\n') < 0) {
        // Inline paste.
        var line = b.lines[b.cursor.row];
        b.lines[b.cursor.row] = line.substring(0, b.cursor.col + 1) + yankBuf[0] + line.substring(b.cursor.col + 1);
        b.cursor.col += yankBuf[0].length;
      } else {
        // Line paste below.
        for (var j = yankBuf.length - 1; j >= 0; j--) {
          b.lines.splice(b.cursor.row + 1, 0, yankBuf[j]);
        }
        b.cursor.row++;
      }
    }
    b.modified = true;
  }

  function delChar(b) {
    var line = b.lines[b.cursor.row];
    if (line.length === 0) return;
    b.lines[b.cursor.row] = line.substring(0, b.cursor.col) + line.substring(b.cursor.col + 1);
    clampCol(b);
    b.modified = true;
  }

  function joinLine(b) {
    if (b.cursor.row >= b.lines.length - 1) return;
    b.lines[b.cursor.row] += ' ' + b.lines[b.cursor.row + 1].trimStart();
    b.lines.splice(b.cursor.row + 1, 1);
    b.modified = true;
  }

  function insertKey(e) {
    var b = buf();
    if (!b) return;
    if (e.key === 'Escape') { mode = 'normal'; b.cursor.col = Math.max(0, b.cursor.col - 1); render(); return; }
    if (e.key === 'Backspace') {
      if (b.cursor.col > 0) {
        b.lines[b.cursor.row] = b.lines[b.cursor.row].substring(0, b.cursor.col - 1) + b.lines[b.cursor.row].substring(b.cursor.col);
        b.cursor.col--;
      } else if (b.cursor.row > 0) {
        var prevLen = b.lines[b.cursor.row - 1].length;
        b.lines[b.cursor.row - 1] += b.lines[b.cursor.row];
        b.lines.splice(b.cursor.row, 1);
        b.cursor.row--;
        b.cursor.col = prevLen;
      }
      b.modified = true;
      render();
      return;
    }
    if (e.key === 'Enter') {
      var line = b.lines[b.cursor.row];
      var before = line.substring(0, b.cursor.col);
      var after = line.substring(b.cursor.col);
      b.lines[b.cursor.row] = before;
      b.lines.splice(b.cursor.row + 1, 0, after);
      b.cursor.row++;
      b.cursor.col = 0;
      b.modified = true;
      render();
      return;
    }
    if (e.key === 'Tab') {
      insertChar(b, '  ');
      render();
      return;
    }
    if (e.key.length === 1 && !e.ctrlKey && !e.metaKey) {
      insertChar(b, e.key);
      render();
    }
  }

  function insertChar(b, ch) {
    var line = b.lines[b.cursor.row];
    b.lines[b.cursor.row] = line.substring(0, b.cursor.col) + ch + line.substring(b.cursor.col);
    b.cursor.col += ch.length;
    b.modified = true;
  }

  // --- Command mode ---
  function enterCommand() {
    mode = 'command';
    commandline.classList.remove('hidden');
    commandline.querySelector('.cmd-prefix').textContent = ':';
    cmdInput.value = '';
    cmdInput.focus();
    render();
  }

  function enterSearch() {
    mode = 'search';
    commandline.classList.remove('hidden');
    commandline.querySelector('.cmd-prefix').textContent = '/';
    cmdInput.value = '';
    cmdInput.focus();
    render();
  }

  function handleCmdKey(e) {
    if (e.key === 'Escape') { exitCommand(); return; }
    if (e.key === 'Enter') {
      var val = cmdInput.value.trim();
      exitCommand();
      if (mode === 'search' || commandline.querySelector('.cmd-prefix').textContent === '/') {
        searchTerm = val;
        searchNext(buf(), 1);
      } else {
        execCommand(val);
      }
      mode = 'normal';
      render();
      content.focus();
      return;
    }
  }

  function exitCommand() {
    mode = 'normal';
    commandline.classList.add('hidden');
    content.focus();
    render();
  }

  function execCommand(cmd) {
    var parts = cmd.split(/\s+/);
    var c = parts[0];
    if (c === 'w') { saveBuffer(); }
    else if (c === 'q') {
      if (buf() && buf().modified) { setMsg('unsaved changes (use :q! to force)'); }
      else { closeBuffer(activeIdx); }
    }
    else if (c === 'q!') { closeBuffer(activeIdx); }
    else if (c === 'wq') { saveBuffer(); setTimeout(function() { closeBuffer(activeIdx); }, 200); }
    else if (c === 'e' && parts[1]) { openBuffer(parts[1]); }
    else if (c === 'ls') {
      setMsg(buffers.map(function(b) { return b.id; }).join(', '));
    }
    else { setMsg('unknown command: ' + c); }
  }

  // --- Search ---
  function searchNext(b, dir) {
    if (!b || !searchTerm) return;
    var start = b.cursor.row + dir;
    for (var i = 0; i < b.lines.length; i++) {
      var r = (start + i * dir + b.lines.length) % b.lines.length;
      var idx = b.lines[r].toLowerCase().indexOf(searchTerm.toLowerCase());
      if (idx >= 0 && (r !== b.cursor.row || idx !== b.cursor.col)) {
        b.cursor.row = r;
        b.cursor.col = idx;
        render();
        return;
      }
    }
    setMsg('pattern not found: ' + searchTerm);
  }

  // --- Helpers ---
  function clampCol(b) {
    var maxCol = Math.max(0, b.lines[b.cursor.row].length - 1);
    if (mode === 'insert') maxCol = b.lines[b.cursor.row].length;
    b.cursor.col = Math.min(b.cursor.col, maxCol);
    if (b.cursor.col < 0) b.cursor.col = 0;
  }

  function wordForward(b, n) {
    for (var i = 0; i < n; i++) {
      var line = b.lines[b.cursor.row];
      var c = b.cursor.col;
      while (c < line.length && /\w/.test(line[c])) c++;
      while (c < line.length && /\s/.test(line[c])) c++;
      if (c >= line.length && b.cursor.row < b.lines.length - 1) {
        b.cursor.row++;
        b.cursor.col = 0;
      } else {
        b.cursor.col = Math.min(c, Math.max(0, line.length - 1));
      }
    }
  }

  function wordBackward(b, n) {
    for (var i = 0; i < n; i++) {
      var line = b.lines[b.cursor.row];
      var c = b.cursor.col - 1;
      if (c < 0 && b.cursor.row > 0) {
        b.cursor.row--;
        b.cursor.col = Math.max(0, b.lines[b.cursor.row].length - 1);
        continue;
      }
      while (c > 0 && /\s/.test(line[c])) c--;
      while (c > 0 && /\w/.test(line[c - 1])) c--;
      b.cursor.col = Math.max(0, c);
    }
  }

  function escHtml(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }
  function escRegex(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  init();
})();
"""
}
