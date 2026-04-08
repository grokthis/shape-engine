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
    // Focus on click anywhere in window content.
    var content = win.querySelector('.window-content');
    if (content) {
      content.addEventListener('mousedown', function() { focusWindow(win); });
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
    var ws = currentWs;
    var split = ws.querySelector('.split');
    if (!split) {
      split = document.createElement('div');
      split.className = 'split hsplit';
      ws.appendChild(split);
    }

    // Resolve render prefix from app shape.
    var renderName = name;
    if (window.shapeEngine) {
      var appShape = window.shapeEngine.engine.getShape('os.app.' + name);
      if (appShape && appShape.character.dimensions.render) {
        renderName = appShape.character.dimensions.render;
      }
    }

    // Render app content structurally from shapes.
    var appStyle = '', appBody = '', appScript = '';
    if (window.shapeEngine) {
      appStyle = window.shapeEngine.renderShape('os.render.' + renderName + '.style') || '';
      appBody = window.shapeEngine.renderShape('os.render.' + renderName + '.body') || '';
      appScript = window.shapeEngine.renderShape('os.render.' + renderName + '.script') || '';
    }

    var win = document.createElement('div');
    win.className = 'window focused';
    win.dataset.app = name;
    var content = '';
    if (appStyle) content += '<style>' + appStyle + '</style>';
    if (appBody) content += appBody;
    if (appScript) content += '<script>' + appScript + '<\/script>';

    win.innerHTML = '<div class="window-titlebar"><span class="window-title">' + name +
      '</span><span class="window-controls"><button class="win-btn close">&times;</button></span></div>' +
      '<div class="window-content">' + content + '</div>';
    split.appendChild(win);
    bindWindowEvents(win);
    document.querySelectorAll('.window').forEach(function(w) { w.classList.remove('focused'); });
    win.classList.add('focused');
    insertGutters();
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
