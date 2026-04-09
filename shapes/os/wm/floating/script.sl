shape os.wm.floating.script : os.wm.floating {
  type: script
  layer: 4
  """
(function() {
  var zIndex = 100;
  var currentWs = document.querySelector('.workspace.active');

  // --- Taskbar ---
  var taskbar = document.getElementById('taskbar');
  if (!taskbar) {
    taskbar = document.createElement('div');
    taskbar.id = 'taskbar';
    document.body.appendChild(taskbar);
  }
  taskbar.innerHTML = '<div id="taskbar-start">Shape</div><div id="taskbar-items"></div><div id="taskbar-right"></div>';
  var taskbarItems = taskbar.querySelector('#taskbar-items');
  if (!taskbarItems) {
    taskbarItems = document.createElement('div');
    taskbarItems.id = 'taskbar-items';
    taskbarItems.style.cssText = 'display:flex;gap:2px;flex:1;overflow:hidden;';
    taskbar.insertBefore(taskbarItems, taskbar.querySelector('#taskbar-right'));
  }

  // Workspace indicators in taskbar-right.
  var taskbarRight = taskbar.querySelector('#taskbar-right');
  var wsHtml = '';
  document.querySelectorAll('.ws-indicator').forEach(function(ind) {
    wsHtml += '<span class="ws-indicator' + (ind.classList.contains('active') ? ' active' : '') + '" data-ws="' + ind.dataset.ws + '">' + ind.dataset.ws + '</span>';
  });
  taskbarRight.innerHTML = wsHtml + '<span id="taskbar-clock"></span>';

  // Clock.
  function updateClock() {
    var el = document.getElementById('taskbar-clock');
    if (el) {
      var d = new Date();
      el.textContent = d.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
    }
  }
  updateClock();
  setInterval(updateClock, 30000);

  // Workspace switching.
  function switchWorkspace(n) {
    document.querySelectorAll('.workspace').forEach(function(ws) {
      ws.classList.toggle('active', ws.dataset.ws === String(n));
    });
    taskbarRight.querySelectorAll('.ws-indicator').forEach(function(ind) {
      ind.classList.toggle('active', ind.dataset.ws === String(n));
    });
    currentWs = document.querySelector('.workspace.active');
    updateTaskbar();
    fetch('/desktop/workspace', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({workspace: String(n)})
    });
  }
  taskbarRight.addEventListener('click', function(e) {
    var ind = e.target.closest('.ws-indicator');
    if (ind) switchWorkspace(parseInt(ind.dataset.ws));
  });

  // --- Position windows ---
  function positionWindows() {
    document.querySelectorAll('.workspace').forEach(function(ws) {
      var wins = ws.querySelectorAll('.window');
      var total = wins.length;
      wins.forEach(function(win, i) {
        if (!win.style.left || win.style.left === '0px') {
          var offset = 30 + i * 30;
          var w = Math.min(800, window.innerWidth * 0.6);
          var h = Math.min(600, (window.innerHeight - 36) * 0.7);
          win.style.left = offset + 'px';
          win.style.top = offset + 'px';
          win.style.width = w + 'px';
          win.style.height = h + 'px';
        }
        addResizeHandles(win);
      });
    });
  }

  function addResizeHandles(win) {
    if (win.querySelector('.resize-handle')) return;
    ['n','s','e','w','ne','nw','se','sw'].forEach(function(dir) {
      var h = document.createElement('div');
      h.className = 'resize-handle ' + dir;
      h.dataset.dir = dir;
      win.appendChild(h);
    });
  }

  positionWindows();

  // --- Focus ---
  function focusWindow(win) {
    document.querySelectorAll('.window').forEach(function(w) { w.classList.remove('focused'); });
    win.classList.add('focused');
    win.style.zIndex = ++zIndex;
    updateTaskbar();
    var id = win.dataset.id;
    if (id) {
      fetch('/desktop/focus', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({id: id})
      });
    }
  }

  // --- Drag ---
  var dragWin = null, dragX = 0, dragY = 0;

  function onTitleMousedown(e) {
    var win = e.target.closest('.window');
    if (!win || e.target.closest('.win-btn')) return;
    if (win.classList.contains('maximized')) return;
    dragWin = win;
    dragX = e.clientX - win.offsetLeft;
    dragY = e.clientY - win.offsetTop;
    document.body.classList.add('dragging');
    focusWindow(win);
    e.preventDefault();
  }

  document.addEventListener('mousemove', function(e) {
    if (dragWin) {
      dragWin.style.left = (e.clientX - dragX) + 'px';
      dragWin.style.top = (e.clientY - dragY) + 'px';
      e.preventDefault();
    }
    if (resizeWin) {
      doResize(e);
      e.preventDefault();
    }
  });

  document.addEventListener('mouseup', function() {
    if (dragWin) {
      // Apply snap if dragged to an edge zone.
      if (snapZone) {
        var r = snapRect(snapZone);
        if (r) {
          dragWin.classList.remove('maximized');
          dragWin.style.left = r.left + 'px';
          dragWin.style.top = r.top + 'px';
          dragWin.style.width = r.width + 'px';
          dragWin.style.height = r.height + 'px';
        }
        snapZone = null;
        if (typeof snapPreview !== 'undefined') snapPreview.style.display = 'none';
      }
      saveWindowGeometryDebounced(dragWin);
      document.body.classList.remove('dragging');
      dragWin = null;
    }
    if (resizeWin) {
      saveWindowGeometryDebounced(resizeWin);
      document.body.classList.remove('resizing');
      resizeWin = null;
    }
  });

  // --- Resize ---
  var resizeWin = null, resizeDir = '', resizeStartX = 0, resizeStartY = 0;
  var resizeStartW = 0, resizeStartH = 0, resizeStartL = 0, resizeStartT = 0;

  document.addEventListener('mousedown', function(e) {
    var handle = e.target.closest('.resize-handle');
    if (!handle) return;
    var win = handle.closest('.window');
    if (!win || win.classList.contains('maximized')) return;
    resizeWin = win;
    resizeDir = handle.dataset.dir;
    resizeStartX = e.clientX;
    resizeStartY = e.clientY;
    resizeStartW = win.offsetWidth;
    resizeStartH = win.offsetHeight;
    resizeStartL = win.offsetLeft;
    resizeStartT = win.offsetTop;
    document.body.classList.add('resizing');
    focusWindow(win);
    e.preventDefault();
  });

  function doResize(e) {
    var dx = e.clientX - resizeStartX;
    var dy = e.clientY - resizeStartY;
    var d = resizeDir;
    var w = resizeStartW, h = resizeStartH, l = resizeStartL, t = resizeStartT;
    if (d.indexOf('e') >= 0) w = Math.max(200, resizeStartW + dx);
    if (d.indexOf('w') >= 0) { w = Math.max(200, resizeStartW - dx); l = resizeStartL + (resizeStartW - w); }
    if (d.indexOf('s') >= 0) h = Math.max(120, resizeStartH + dy);
    if (d.indexOf('n') >= 0) { h = Math.max(120, resizeStartH - dy); t = resizeStartT + (resizeStartH - h); }
    resizeWin.style.width = w + 'px';
    resizeWin.style.height = h + 'px';
    resizeWin.style.left = l + 'px';
    resizeWin.style.top = t + 'px';
  }

  // --- Window buttons ---
  function bindWindowEvents(win) {
    win.addEventListener('mousedown', function(e) {
      if (e.target.closest('.resize-handle')) return;
      // Bring window to front but don't steal focus from inputs.
      var tag = e.target.tagName;
      if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || e.target.isContentEditable) {
        // Just bring to front without disrupting focus.
        document.querySelectorAll('.window').forEach(function(w) { w.classList.remove('focused'); });
        win.classList.add('focused');
        return;
      }
      focusWindow(win);
    });
    var titlebar = win.querySelector('.window-title');
    if (titlebar) titlebar.addEventListener('mousedown', onTitleMousedown);
    win.querySelectorAll('.win-btn').forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.stopPropagation();
        if (btn.classList.contains('close')) {
          var id = win.dataset.id;
          if (id) fetch('/desktop/window/' + id, {method: 'DELETE'});
          win.remove();
          updateTaskbar();
        } else if (btn.classList.contains('maximize')) {
          win.classList.toggle('maximized');
        } else if (btn.classList.contains('minimize')) {
          win.classList.add('minimized');
          updateTaskbar();
        }
      });
    });
  }

  // Add maximize and minimize buttons to existing windows.
  document.querySelectorAll('.window').forEach(function(win) {
    var controls = win.querySelector('.window-controls');
    if (controls && !controls.querySelector('.minimize')) {
      var minBtn = document.createElement('button');
      minBtn.className = 'win-btn minimize';
      minBtn.title = 'minimize';
      minBtn.innerHTML = '&#8211;';
      var maxBtn = document.createElement('button');
      maxBtn.className = 'win-btn maximize';
      maxBtn.title = 'maximize';
      maxBtn.innerHTML = '&#9633;';
      var closeBtn = controls.querySelector('.close');
      controls.insertBefore(minBtn, closeBtn);
      controls.insertBefore(maxBtn, closeBtn);
    }
    bindWindowEvents(win);
  });

  // --- Taskbar ---
  function updateTaskbar() {
    if (!taskbarItems) return;
    taskbarItems.innerHTML = '';
    var wins = currentWs ? currentWs.querySelectorAll('.window') : [];
    wins.forEach(function(win) {
      var item = document.createElement('div');
      item.className = 'taskbar-item';
      if (win.classList.contains('focused') && !win.classList.contains('minimized')) item.className += ' active';
      item.textContent = win.dataset.app || 'window';
      item.addEventListener('click', function() {
        if (win.classList.contains('minimized')) {
          win.classList.remove('minimized');
        }
        focusWindow(win);
      });
      taskbarItems.appendChild(item);
    });
  }
  updateTaskbar();

  // --- Launcher ---
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

  document.getElementById('taskbar-start').addEventListener('click', function() {
    if (launcher.style.display === 'none') openLauncher();
    else closeLauncher();
  });

  function launchApp(name) {
    var ws = currentWs;

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
    var offset = 30 + ws.querySelectorAll('.window').length * 30;
    win.style.cssText = 'left:' + offset + 'px;top:' + offset + 'px;width:800px;height:600px;z-index:' + (++zIndex);

    var content = '';
    if (appStyle) content += '<style>' + appStyle + '</style>';
    if (appBody) content += appBody;
    if (appScript) content += '<script>' + appScript + '<\/script>';

    win.innerHTML = '<div class="window-titlebar"><span class="window-title">' + name +
      '</span><span class="window-controls">' +
      '<button class="win-btn minimize" title="minimize">&#8211;</button>' +
      '<button class="win-btn maximize" title="maximize">&#9633;</button>' +
      '<button class="win-btn close" title="close">&times;</button>' +
      '</span></div>' +
      '<div class="window-content">' + content + '</div>';
    ws.appendChild(win);
    addResizeHandles(win);
    bindWindowEvents(win);
    document.querySelectorAll('.window').forEach(function(w) { w.classList.remove('focused'); });
    win.classList.add('focused');
    updateTaskbar();
  }

  // --- Window snapping ---
  var snapZone = null;
  var snapPreview = document.createElement('div');
  snapPreview.id = 'snap-preview';
  snapPreview.style.cssText = 'display:none;position:fixed;background:rgba(100,150,255,0.15);border:2px solid rgba(100,150,255,0.5);border-radius:6px;z-index:99999;pointer-events:none;transition:all 0.15s ease;';
  document.body.appendChild(snapPreview);

  function getSnapZone(x, y) {
    var w = window.innerWidth, h = window.innerHeight, edge = 12;
    if (x <= edge && y <= edge) return 'top-left';
    if (x >= w - edge && y <= edge) return 'top-right';
    if (x <= edge && y >= h - edge) return 'bottom-left';
    if (x >= w - edge && y >= h - edge) return 'bottom-right';
    if (x <= edge) return 'left';
    if (x >= w - edge) return 'right';
    if (y <= edge) return 'top';
    return null;
  }

  function snapRect(zone) {
    var w = window.innerWidth, h = window.innerHeight, tb = 36;
    switch(zone) {
      case 'left': return {left:0,top:tb,width:w/2,height:h-tb};
      case 'right': return {left:w/2,top:tb,width:w/2,height:h-tb};
      case 'top': return {left:0,top:tb,width:w,height:h-tb};
      case 'top-left': return {left:0,top:tb,width:w/2,height:(h-tb)/2};
      case 'top-right': return {left:w/2,top:tb,width:w/2,height:(h-tb)/2};
      case 'bottom-left': return {left:0,top:tb+(h-tb)/2,width:w/2,height:(h-tb)/2};
      case 'bottom-right': return {left:w/2,top:tb+(h-tb)/2,width:w/2,height:(h-tb)/2};
    }
    return null;
  }

  // Patch drag mousemove for snap preview.
  document.addEventListener('mousemove', function(e) {
    if (!dragWin) { snapPreview.style.display = 'none'; snapZone = null; return; }
    var zone = getSnapZone(e.clientX, e.clientY);
    snapZone = zone;
    if (zone) {
      var r = snapRect(zone);
      snapPreview.style.display = 'block';
      snapPreview.style.left = r.left + 'px';
      snapPreview.style.top = r.top + 'px';
      snapPreview.style.width = r.width + 'px';
      snapPreview.style.height = r.height + 'px';
    } else {
      snapPreview.style.display = 'none';
    }
  });

  // Snap preview cleanup (drag mouseup handles the actual snap above).

  // --- Double-click titlebar = maximize/restore ---
  document.addEventListener('dblclick', function(e) {
    var titlebar = e.target.closest('.window-titlebar');
    if (!titlebar) return;
    var win = titlebar.closest('.window');
    if (win) { win.classList.toggle('maximized'); saveWindowGeometryDebounced(win); }
  });

  // --- Context menu ---
  var ctxMenu = document.createElement('div');
  ctxMenu.id = 'ctx-menu';
  ctxMenu.style.cssText = 'display:none;position:fixed;background:var(--surface,#1e1e2e);border:1px solid var(--border,#444);border-radius:6px;padding:4px 0;z-index:100000;min-width:160px;box-shadow:0 4px 12px rgba(0,0,0,0.4);font-size:13px;color:var(--text,#cdd6f4);';
  document.body.appendChild(ctxMenu);

  function showCtx(x, y, items) {
    ctxMenu.innerHTML = '';
    items.forEach(function(item) {
      if (item === '---') {
        var hr = document.createElement('div');
        hr.style.cssText = 'height:1px;background:var(--border,#444);margin:4px 0;';
        ctxMenu.appendChild(hr);
      } else {
        var el = document.createElement('div');
        el.textContent = item.label;
        el.style.cssText = 'padding:6px 16px;cursor:pointer;';
        el.addEventListener('mouseenter', function() { this.style.background = 'var(--accent,#89b4fa)'; this.style.color = '#000'; });
        el.addEventListener('mouseleave', function() { this.style.background = ''; this.style.color = ''; });
        el.addEventListener('click', function() { ctxMenu.style.display = 'none'; item.action(); });
        ctxMenu.appendChild(el);
      }
    });
    ctxMenu.style.left = Math.min(x, window.innerWidth - 180) + 'px';
    ctxMenu.style.top = Math.min(y, window.innerHeight - items.length * 30) + 'px';
    ctxMenu.style.display = 'block';
  }

  document.addEventListener('click', function() { ctxMenu.style.display = 'none'; });

  document.addEventListener('contextmenu', function(e) {
    var titlebar = e.target.closest('.window-titlebar');
    var win = e.target.closest('.window');
    if (titlebar && win) {
      e.preventDefault();
      showCtx(e.clientX, e.clientY, [
        {label: 'Close', action: function() { var id = win.dataset.id; if (id) fetch('/desktop/window/'+id,{method:'DELETE'}); win.remove(); updateTaskbar(); }},
        {label: 'Maximize', action: function() { win.classList.toggle('maximized'); saveWindowGeometryDebounced(win); }},
        {label: 'Minimize', action: function() { win.classList.add('minimized'); updateTaskbar(); }},
        '---',
        {label: 'Snap Left', action: function() { var r=snapRect('left'); win.style.left=r.left+'px';win.style.top=r.top+'px';win.style.width=r.width+'px';win.style.height=r.height+'px';win.classList.remove('maximized'); saveWindowGeometryDebounced(win); }},
        {label: 'Snap Right', action: function() { var r=snapRect('right'); win.style.left=r.left+'px';win.style.top=r.top+'px';win.style.width=r.width+'px';win.style.height=r.height+'px';win.classList.remove('maximized'); saveWindowGeometryDebounced(win); }},
        '---',
        {label: 'To Workspace 1', action: function() { moveWindowToWs(win, '1'); }},
        {label: 'To Workspace 2', action: function() { moveWindowToWs(win, '2'); }},
        {label: 'To Workspace 3', action: function() { moveWindowToWs(win, '3'); }},
        '---',
        {label: 'Help', action: function() { showHelp('os.app.' + (win.dataset.app || 'shell')); }}
      ]);
    } else if (!win) {
      e.preventDefault();
      showCtx(e.clientX, e.clientY, [
        {label: 'New Shell', action: function() { launchApp('shell'); }},
        {label: 'New Browser', action: function() { launchApp('browser'); }},
        '---',
        {label: 'Launcher', action: openLauncher},
        {label: 'Help (F1)', action: function() { showHelp('os.desktop'); }},
        {label: 'Refresh', action: function() { location.reload(); }}
      ]);
    }
  });

  function moveWindowToWs(win, wsNum) {
    // Hide from current workspace, move shape dep.
    win.remove();
    updateTaskbar();
    var wsId = win.dataset.id;
    if (wsId) {
      fetch('/desktop/window/' + wsId, {method: 'DELETE'}).then(function() {
        fetch('/desktop/window', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({workspace: wsNum, app: win.dataset.app})
        });
      });
    }
  }

  // --- Alt-Tab window switcher ---
  var altTabOverlay = document.createElement('div');
  altTabOverlay.id = 'alt-tab';
  altTabOverlay.style.cssText = 'display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);background:var(--surface,#1e1e2e);border:1px solid var(--border,#444);border-radius:10px;padding:16px;z-index:100001;display:none;gap:8px;box-shadow:0 8px 32px rgba(0,0,0,0.6);';
  document.body.appendChild(altTabOverlay);
  var altTabIdx = 0;
  var altTabActive = false;

  function showAltTab() {
    var wins = currentWs ? Array.from(currentWs.querySelectorAll('.window:not(.minimized)')) : [];
    if (wins.length < 2) return;
    altTabActive = true;
    altTabIdx = 1;
    altTabOverlay.innerHTML = '';
    altTabOverlay.style.display = 'flex';
    wins.forEach(function(w, i) {
      var item = document.createElement('div');
      item.style.cssText = 'padding:10px 18px;border-radius:6px;text-align:center;min-width:80px;font-size:13px;';
      item.textContent = w.dataset.app || 'window';
      item.dataset.idx = i;
      if (i === altTabIdx) item.style.background = 'var(--accent,#89b4fa)';
      altTabOverlay.appendChild(item);
    });
  }

  function cycleAltTab(dir) {
    var wins = currentWs ? Array.from(currentWs.querySelectorAll('.window:not(.minimized)')) : [];
    if (wins.length < 2) return;
    altTabIdx = (altTabIdx + dir + wins.length) % wins.length;
    Array.from(altTabOverlay.children).forEach(function(el, i) {
      el.style.background = i === altTabIdx ? 'var(--accent,#89b4fa)' : '';
      el.style.color = i === altTabIdx ? '#000' : '';
    });
  }

  function commitAltTab() {
    var wins = currentWs ? Array.from(currentWs.querySelectorAll('.window:not(.minimized)')) : [];
    if (wins[altTabIdx]) focusWindow(wins[altTabIdx]);
    altTabOverlay.style.display = 'none';
    altTabActive = false;
  }

  // --- Command palette ---
  var palette = document.createElement('div');
  palette.id = 'cmd-palette';
  palette.style.cssText = 'display:none;position:fixed;top:20%;left:50%;transform:translateX(-50%);width:400px;max-width:90vw;background:var(--surface,#1e1e2e);border:1px solid var(--border,#444);border-radius:10px;z-index:100002;box-shadow:0 8px 32px rgba(0,0,0,0.6);overflow:hidden;';
  palette.innerHTML = '<input id="palette-input" type="text" placeholder="Type a command..." style="width:100%;padding:12px 16px;border:none;background:transparent;color:var(--text,#cdd6f4);font-size:14px;outline:none;box-sizing:border-box;border-bottom:1px solid var(--border,#444);"><div id="palette-results" style="max-height:240px;overflow-y:auto;"></div>';
  document.body.appendChild(palette);

  var paletteCommands = [
    {label: 'New Shell Window', action: function() { launchApp('shell'); }},
    {label: 'New Browser Window', action: function() { launchApp('browser'); }},
    {label: 'New Editor Window', action: function() { launchApp('editor'); }},
    {label: 'Switch to Workspace 1', action: function() { switchWorkspace(1); }},
    {label: 'Switch to Workspace 2', action: function() { switchWorkspace(2); }},
    {label: 'Switch to Workspace 3', action: function() { switchWorkspace(3); }},
    {label: 'Close Focused Window', action: function() { var fw=document.querySelector('.window.focused'); if(fw){var id=fw.dataset.id;if(id)fetch('/desktop/window/'+id,{method:'DELETE'});fw.remove();updateTaskbar();} }},
    {label: 'Maximize Focused Window', action: function() { var fw=document.querySelector('.window.focused'); if(fw){fw.classList.toggle('maximized');saveWindowGeometryDebounced(fw);} }},
    {label: 'Snap Left', action: function() { var fw=document.querySelector('.window.focused'); if(fw){var r=snapRect('left');fw.style.left=r.left+'px';fw.style.top=r.top+'px';fw.style.width=r.width+'px';fw.style.height=r.height+'px';fw.classList.remove('maximized');saveWindowGeometryDebounced(fw);} }},
    {label: 'Snap Right', action: function() { var fw=document.querySelector('.window.focused'); if(fw){var r=snapRect('right');fw.style.left=r.left+'px';fw.style.top=r.top+'px';fw.style.width=r.width+'px';fw.style.height=r.height+'px';fw.classList.remove('maximized');saveWindowGeometryDebounced(fw);} }},
    {label: 'Open Launcher', action: openLauncher},
    {label: 'Help', action: function() { var fw=document.querySelector('.window.focused'); showHelp('os.app.' + (fw ? fw.dataset.app || 'shell' : 'shell')); }},
    {label: 'Documentation', action: function() { launchApp('docs'); }},
    {label: 'Refresh Desktop', action: function() { location.reload(); }}
  ];

  function openPalette() {
    palette.style.display = 'block';
    var input = document.getElementById('palette-input');
    input.value = '';
    input.focus();
    filterPalette('');
  }

  function closePalette() { palette.style.display = 'none'; }

  function filterPalette(q) {
    q = q.toLowerCase();
    var results = document.getElementById('palette-results');
    results.innerHTML = '';
    paletteCommands.forEach(function(cmd) {
      if (q && cmd.label.toLowerCase().indexOf(q) < 0) return;
      var el = document.createElement('div');
      el.textContent = cmd.label;
      el.style.cssText = 'padding:8px 16px;cursor:pointer;font-size:13px;';
      el.addEventListener('mouseenter', function() { this.style.background = 'var(--accent,#89b4fa)'; this.style.color = '#000'; });
      el.addEventListener('mouseleave', function() { this.style.background = ''; this.style.color = ''; });
      el.addEventListener('click', function() { closePalette(); cmd.action(); });
      results.appendChild(el);
    });
  }

  document.getElementById('palette-input').addEventListener('input', function() { filterPalette(this.value); });
  document.getElementById('palette-input').addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closePalette();
    if (e.key === 'Enter') {
      var first = document.querySelector('#palette-results > div');
      if (first) first.click();
    }
  });

  // --- Notification toasts ---
  var toastContainer = document.createElement('div');
  toastContainer.id = 'toast-container';
  toastContainer.style.cssText = 'position:fixed;top:44px;right:12px;z-index:100003;display:flex;flex-direction:column;gap:6px;pointer-events:none;';
  document.body.appendChild(toastContainer);

  function showToast(msg, duration) {
    duration = duration || 3000;
    var toast = document.createElement('div');
    toast.style.cssText = 'background:var(--surface,#1e1e2e);border:1px solid var(--border,#444);border-radius:6px;padding:8px 14px;font-size:12px;color:var(--text,#cdd6f4);box-shadow:0 4px 12px rgba(0,0,0,0.4);opacity:0;transition:opacity 0.2s;pointer-events:auto;max-width:280px;word-break:break-word;';
    toast.textContent = msg;
    toastContainer.appendChild(toast);
    requestAnimationFrame(function() { toast.style.opacity = '1'; });
    setTimeout(function() {
      toast.style.opacity = '0';
      setTimeout(function() { toast.remove(); }, 200);
    }, duration);
  }

  // --- WebSocket event stream ---
  function connectEvents() {
    var proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
    var ws = new WebSocket(proto + '//' + location.host + '/ws/events');
    ws.onmessage = function(e) {
      try {
        var evt = JSON.parse(e.data);
        // Update tick in statusbar.
        if (evt.tick) {
          var right = document.getElementById('statusbar-right');
          if (right) {
            var spans = right.querySelectorAll('span');
            if (spans.length >= 2) spans[1].textContent = 'tick ' + evt.tick;
          }
        }
        // Show toast for interesting events.
        if (evt.type === 'edit' && evt.shape) {
          showToast(evt.shape + ' edited (tick ' + evt.tick + ')');
        } else if (evt.type === 'add' && evt.shape) {
          showToast('+ ' + evt.shape);
        }
      } catch(ex) {}
    };
    ws.onclose = function() { setTimeout(connectEvents, 2000); };
    ws.onerror = function() { ws.close(); };
  }
  try { connectEvents(); } catch(ex) {}

  // --- Keyboard shortcuts ---
  document.addEventListener('keydown', function(e) {
    // F1: help for focused window.
    if (e.key === 'F1') {
      e.preventDefault();
      var fw = document.querySelector('.window.focused');
      var app = fw ? (fw.dataset.app || 'shell') : 'shell';
      if (helpPanel.style.display === 'flex') { helpPanel.style.display = 'none'; }
      else { showHelp('os.app.' + app); }
      return;
    }
    // Escape: close help panel (among other things).
    if (e.key === 'Escape' && helpPanel.style.display === 'flex') {
      helpPanel.style.display = 'none';
      e.preventDefault();
      return;
    }
    // Alt-Tab.
    if (e.altKey && e.key === 'Tab') {
      e.preventDefault();
      if (!altTabActive) showAltTab();
      else cycleAltTab(e.shiftKey ? -1 : 1);
      return;
    }

    // Commit alt-tab on Alt release.
    if (altTabActive && !e.altKey) {
      // Handled by keyup below.
    }

    // Command palette.
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'p') {
      e.preventDefault();
      if (palette.style.display === 'none') openPalette();
      else closePalette();
      return;
    }

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
        updateTaskbar();
      }
      e.preventDefault();
    }
  });

  document.addEventListener('keyup', function(e) {
    if (altTabActive && e.key === 'Alt') {
      commitAltTab();
    }
  });

  // --- Help overlay ---
  var helpPanel = document.createElement('div');
  helpPanel.id = 'help-panel';
  helpPanel.style.cssText = 'display:none;position:fixed;right:12px;top:48px;width:380px;max-height:70vh;background:var(--surface,#1e1e2e);border:1px solid var(--border,#444);border-radius:8px;z-index:100004;box-shadow:0 8px 32px rgba(0,0,0,0.6);overflow:hidden;display:none;flex-direction:column;';
  helpPanel.innerHTML = '<div style="display:flex;align-items:center;padding:6px 10px;border-bottom:1px solid var(--border,#444);flex-shrink:0;"><span style="flex:1;font-size:12px;font-weight:600;color:var(--fg-dim,#888);">Help</span><button id="help-close" style="background:none;border:none;color:var(--fg-dim,#888);cursor:pointer;font-size:16px;line-height:1;">&times;</button></div><div id="help-content" style="flex:1;overflow-y:auto;padding:12px;font-size:12px;font-family:monospace;white-space:pre-wrap;color:var(--fg,#ccc);min-height:200px;"></div>';
  document.body.appendChild(helpPanel);

  document.getElementById('help-close').addEventListener('click', function() {
    helpPanel.style.display = 'none';
  });

  function showHelp(shapeId) {
    var el = document.getElementById('help-content');
    var text = '';
    if (window.shapeEngine) {
      text = window.shapeEngine.renderShape('os.doc.' + shapeId) || '';
      if (!text) text = window.shapeEngine.execShell('man ' + shapeId) || '';
      if (!text) text = window.shapeEngine.execShell('info ' + shapeId) || '';
    }
    el.textContent = text || 'No help available for ' + shapeId;
    helpPanel.style.display = 'flex';
  }

  // Listen for postMessage from help iframe (see_also navigation).
  window.addEventListener('message', function(e) {
    if (e.data && e.data.type === 'help' && e.data.topic) {
      showHelp(e.data.topic);
    }
  });

  // --- Window geometry persistence (shape-backed, survives reboot) ---
  function saveWindowGeometry(win) {
    if (!win || !win.dataset.id) return;
    fetch('/desktop/window/geometry', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        id: win.dataset.id,
        left: win.style.left || '', top: win.style.top || '',
        width: win.style.width || '', height: win.style.height || '',
        maximized: win.classList.contains('maximized')
      })
    });
  }
  // Debounced save: coalesce rapid moves/resizes into one write per window.
  var geoTimers = {};
  function saveWindowGeometryDebounced(win) {
    if (!win || !win.dataset.id) return;
    var id = win.dataset.id;
    if (geoTimers[id]) clearTimeout(geoTimers[id]);
    geoTimers[id] = setTimeout(function() { saveWindowGeometry(win); }, 300);
  }
})();
"""
}
