shape os.wm.tiling.script : os.wm.tiling {
  type: script
  layer: 4
  """
(function() {
  var currentWs = document.querySelector('.workspace.active');

  function switchWorkspace(n) {
    document.querySelectorAll('.workspace').forEach(function(ws) {
      ws.classList.toggle('active', ws.dataset.ws === String(n));
    });
    document.querySelectorAll('.ws-indicator').forEach(function(ind) {
      ind.classList.toggle('active', ind.dataset.ws === String(n));
    });
    currentWs = document.querySelector('.workspace.active');
    fetch('/desktop/workspace', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({workspace: String(n)})
    });
  }

  document.querySelectorAll('.ws-indicator').forEach(function(ind) {
    ind.addEventListener('click', function() {
      switchWorkspace(parseInt(this.dataset.ws));
    });
  });

  function focusWindow(win) {
    document.querySelectorAll('.window').forEach(function(w) { w.classList.remove('focused'); });
    win.classList.add('focused');
    var id = win.dataset.id;
    if (id) {
      fetch('/desktop/focus', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({id: id})
      });
    }
  }

  function bindWindowEvents(win) {
    // Click anywhere on the window (titlebar, borders, content area)
    win.addEventListener('mousedown', function() { focusWindow(win); });
    // Detect when the iframe inside gets focus (click inside app content)
    var iframe = win.querySelector('iframe');
    if (iframe) {
      iframe.addEventListener('focus', function() { focusWindow(win); });
      // Polling fallback: iframes don't always fire focus events reliably
      iframe.addEventListener('load', function() {
        try {
          iframe.contentWindow.addEventListener('mousedown', function() { focusWindow(win); });
        } catch(e) { /* cross-origin, fall back to focus event */ }
      });
    }
    var closeBtn = win.querySelector('.win-btn.close');
    if (closeBtn) {
      closeBtn.addEventListener('click', function(e) {
        e.stopPropagation();
        var id = win.dataset.id;
        if (id) fetch('/desktop/window/' + id, {method: 'DELETE'});
        win.remove();
      });
    }
  }
  document.querySelectorAll('.window').forEach(bindWindowEvents);

  var launcher = document.getElementById('launcher');
  var launcherInput = document.getElementById('launcher-input');

  function openLauncher() {
    launcher.style.display = '';
    launcherInput.value = '';
    launcherInput.focus();
    filterLauncher('');
  }
  function closeLauncher() { launcher.style.display = 'none'; }
  function filterLauncher(query) {
    query = query.toLowerCase();
    document.querySelectorAll('.launcher-item').forEach(function(item) {
      item.style.display = item.textContent.toLowerCase().indexOf(query) >= 0 ? '' : 'none';
    });
  }

  if (launcherInput) {
    launcherInput.addEventListener('input', function() { filterLauncher(this.value); });
    launcherInput.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') closeLauncher();
      if (e.key === 'Enter') {
        var visible = document.querySelector('.launcher-item:not([style*="display: none"])');
        if (visible) launchApp(visible.dataset.app);
        closeLauncher();
      }
    });
  }
  if (document.querySelector('.launcher-backdrop')) {
    document.querySelector('.launcher-backdrop').addEventListener('click', closeLauncher);
  }
  document.querySelectorAll('.launcher-item').forEach(function(item) {
    item.addEventListener('click', function() {
      launchApp(this.dataset.app);
      closeLauncher();
    });
  });

  function launchApp(name) {
    var wsNum = currentWs ? currentWs.dataset.ws : '1';
    Promise.all([
      fetch('/desktop/window', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({workspace: wsNum, app: name})
      }).then(function(r) { return r.json(); }),
      fetch('/desktop/appurl/' + name).then(function(r) { return r.json(); })
    ]).then(function(results) {
      var data = results[0];
      var url = results[1].url;
      var ws = currentWs;
      var split = ws.querySelector('.split');
      if (!split) {
        split = document.createElement('div');
        split.className = 'split hsplit';
        ws.appendChild(split);
      }
      var win = document.createElement('div');
      win.className = 'window focused';
      win.dataset.app = name;
      win.dataset.id = data.id;
      win.innerHTML = '<div class="window-titlebar"><span class="window-title">' + name +
        '</span><span class="window-controls"><button class="win-btn close">&times;</button></span></div>' +
        '<div class="window-content"><iframe src="' + url + '" frameborder="0"></iframe></div>';
      split.appendChild(win);
      bindWindowEvents(win);
      document.querySelectorAll('.window').forEach(function(w) { w.classList.remove('focused'); });
      win.classList.add('focused');
    });
  }

  document.addEventListener('keydown', function(e) {
    if (e.ctrlKey && e.key >= '1' && e.key <= '9') {
      switchWorkspace(parseInt(e.key));
      e.preventDefault();
    }
    if ((e.metaKey || e.ctrlKey) && e.key === ' ') {
      if (launcher.style.display === 'none') openLauncher();
      else closeLauncher();
      e.preventDefault();
    }
    if (e.ctrlKey && e.key === 'Enter') {
      launchApp('shell');
      e.preventDefault();
    }
    if (e.ctrlKey && e.key === 'w') {
      var fw = document.querySelector('.window.focused');
      if (fw) {
        var id = fw.dataset.id;
        if (id) fetch('/desktop/window/' + id, {method: 'DELETE'});
        fw.remove();
      }
      e.preventDefault();
    }
  });

  // --- Resize gutters between tiled windows ---
  function insertGutters() {
    document.querySelectorAll('.split').forEach(function(split) {
      var windows = Array.from(split.children).filter(function(c) {
        return c.classList.contains('window');
      });
      // Remove old gutters.
      split.querySelectorAll('.resize-gutter').forEach(function(g) { g.remove(); });
      // Insert gutter between each pair.
      for (var i = 0; i < windows.length - 1; i++) {
        var gutter = document.createElement('div');
        gutter.className = 'resize-gutter';
        windows[i].after(gutter);
      }
    });
  }
  insertGutters();

  // Drag logic.
  var dragGutter = null, dragSplit = null, dragPrev = null, dragNext = null, dragStart = 0, dragTotal = 0;

  document.addEventListener('mousedown', function(e) {
    if (!e.target.classList.contains('resize-gutter')) return;
    dragGutter = e.target;
    dragSplit = dragGutter.parentElement;
    var isH = dragSplit.classList.contains('hsplit');
    // Find adjacent windows.
    var prev = dragGutter.previousElementSibling;
    var next = dragGutter.nextElementSibling;
    if (!prev || !next) return;
    dragPrev = prev;
    dragNext = next;
    dragGutter.classList.add('dragging');
    document.body.classList.add('resizing');
    var prevRect = prev.getBoundingClientRect();
    var nextRect = next.getBoundingClientRect();
    dragTotal = isH ? (prevRect.width + nextRect.width) : (prevRect.height + nextRect.height);
    dragStart = isH ? e.clientX : e.clientY;
    // Set initial sizes.
    var prevSize = isH ? prevRect.width : prevRect.height;
    prev.style.flex = '0 0 ' + prevSize + 'px';
    prev.classList.add('sized');
    next.style.flex = '1 1 0';
    e.preventDefault();
  });

  document.addEventListener('mousemove', function(e) {
    if (!dragGutter) return;
    var isH = dragSplit.classList.contains('hsplit');
    var delta = (isH ? e.clientX : e.clientY) - dragStart;
    var prevRect = dragPrev.getBoundingClientRect();
    var currentSize = isH ? prevRect.width : prevRect.height;
    var newSize = currentSize + delta;
    // Clamp: min 80px, max total - 80px.
    if (newSize < 80) newSize = 80;
    if (newSize > dragTotal - 80) newSize = dragTotal - 80;
    dragPrev.style.flex = '0 0 ' + newSize + 'px';
    dragStart = isH ? e.clientX : e.clientY;
    e.preventDefault();
  });

  document.addEventListener('mouseup', function() {
    if (!dragGutter) return;
    dragGutter.classList.remove('dragging');
    document.body.classList.remove('resizing');
    dragGutter = null;
  });
})();
"""
}
