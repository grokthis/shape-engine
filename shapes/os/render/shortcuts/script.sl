shape os.render.shortcuts.script {
  type: script
  layer: 5
  deps: os.render.shortcuts.body
  """
(function() {
  var root = document.getElementById('shortcuts-root');
  if (!root) return;

  // Build the toolbar
  var toolbar = document.createElement('div');
  toolbar.className = 'shortcuts-toolbar';

  var search = document.createElement('input');
  search.type = 'text';
  search.placeholder = 'Search shortcuts...';
  search.id = 'sc-search';
  toolbar.appendChild(search);

  var filterWrap = document.createElement('div');
  filterWrap.className = 'shortcuts-filter';

  var allBtn = document.createElement('button');
  allBtn.className = 'filter-btn active';
  allBtn.textContent = 'All';
  allBtn.dataset.filter = '';

  filterWrap.appendChild(allBtn);
  toolbar.appendChild(filterWrap);
  root.appendChild(toolbar);

  var body = document.createElement('div');
  body.className = 'shortcuts-body';
  root.appendChild(body);

  // State
  var systemShortcuts = [];  // [{id, key, action, app, category, description}]
  var userOverrides = {};    // suffix → {id, key}

  function shortcutSuffix(id) {
    var osPfx = 'os.shortcuts.';
    var userPfx = 'user.shortcuts.';
    if (id.indexOf(osPfx) === 0) return id.slice(osPfx.length);
    if (id.indexOf(userPfx) === 0) return id.slice(userPfx.length);
    return id;
  }

  function loadData() {
    Promise.all([
      window.shapeClient ? window.shapeClient.load('os.shortcuts') : Promise.resolve([]),
      window.shapeClient ? window.shapeClient.load('user.shortcuts').catch(function(){return[];}) : Promise.resolve([])
    ]).then(function(results) {
      var sysRaw = results[0] || [];
      var userRaw = results[1] || [];

      systemShortcuts = sysRaw
        .filter(function(s) {
          var d = s.character && s.character.dimensions;
          return d && d.type === 'shortcut';
        })
        .map(function(s) {
          var d = s.character.dimensions;
          return {
            id: s.id,
            suffix: shortcutSuffix(s.id),
            key: d.key || '',
            action: d.action || '',
            app: d.app || '',
            category: d.category || 'General',
            description: d.description || d.action || ''
          };
        });

      userOverrides = {};
      userRaw.forEach(function(s) {
        var d = s.character && s.character.dimensions;
        if (d && d.type === 'shortcut' && d.key) {
          userOverrides[shortcutSuffix(s.id)] = { id: s.id, key: d.key };
        }
      });

      // Build app filter buttons (dedupe)
      filterWrap.querySelectorAll('.filter-btn:not([data-filter=""])').forEach(function(b) { b.remove(); });
      var apps = [];
      systemShortcuts.forEach(function(sc) { if (sc.app && apps.indexOf(sc.app) < 0) apps.push(sc.app); });
      apps.sort().forEach(function(app) {
        var btn = document.createElement('button');
        btn.className = 'filter-btn';
        btn.textContent = app.charAt(0).toUpperCase() + app.slice(1);
        btn.dataset.filter = app;
        btn.addEventListener('click', function() { setFilter(app); });
        filterWrap.appendChild(btn);
      });

      render();
    });
  }

  var currentFilter = '';
  var currentSearch = '';

  function setFilter(f) {
    currentFilter = f;
    filterWrap.querySelectorAll('.filter-btn').forEach(function(b) {
      b.classList.toggle('active', b.dataset.filter === f);
    });
    render();
  }

  allBtn.addEventListener('click', function() { setFilter(''); });

  search.addEventListener('input', function() {
    currentSearch = search.value.toLowerCase();
    render();
  });

  function formatKey(keyStr) {
    // Split "Cmd+Shift+S" into individual key parts
    var parts = keyStr.replace(/\s+/g, '').split('+');
    var span = document.createElement('span');
    span.className = 'shortcut-key';
    parts.forEach(function(p, i) {
      var k = document.createElement('span');
      k.className = 'key-part';
      // Pretty-print modifiers
      var map = { Cmd: '⌘', Ctrl: '⌃', Alt: '⌥', Shift: '⇧', Meta: '⌘' };
      k.textContent = map[p] || p;
      span.appendChild(k);
      if (i < parts.length - 1) {
        var plus = document.createTextNode(' ');
        span.appendChild(plus);
      }
    });
    return span;
  }

  // Recording state
  var recordingRow = null;
  var recordingSuffix = null;

  function startRecording(row, suffix) {
    if (recordingRow) stopRecording(true);
    recordingRow = row;
    recordingSuffix = suffix;
    row.classList.add('recording');
    var keyWrap = row.querySelector('.shortcut-key-wrap');
    keyWrap.innerHTML = '';
    var hint = document.createElement('span');
    hint.className = 'key-part';
    hint.textContent = 'Press shortcut…';
    keyWrap.appendChild(hint);
    document.addEventListener('keydown', captureKey, true);
    document.addEventListener('click', cancelOnClickOutside, true);
  }

  function stopRecording(cancel) {
    if (!recordingRow) return;
    recordingRow.classList.remove('recording');
    document.removeEventListener('keydown', captureKey, true);
    document.removeEventListener('click', cancelOnClickOutside, true);
    if (cancel) render();
    recordingRow = null;
    recordingSuffix = null;
  }

  function cancelOnClickOutside(e) {
    if (!recordingRow || recordingRow.contains(e.target)) return;
    stopRecording(true);
  }

  function captureKey(e) {
    // Ignore bare modifiers
    if (['Meta','Control','Alt','Shift','OS'].indexOf(e.key) >= 0) return;
    e.preventDefault();
    e.stopPropagation();

    var parts = [];
    if (e.metaKey) parts.push('Cmd');
    if (e.ctrlKey) parts.push('Ctrl');
    if (e.altKey) parts.push('Alt');
    if (e.shiftKey) parts.push('Shift');
    parts.push(e.key.length === 1 ? e.key.toUpperCase() : e.key);
    var newKey = parts.join('+');

    // Escape = cancel
    if (e.key === 'Escape') { stopRecording(true); return; }

    var suffix = recordingSuffix;
    stopRecording(false);
    saveOverride(suffix, newKey);
  }

  function saveOverride(suffix, newKey) {
    fetch('/api/shortcut/save', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({ suffix: suffix, key: newKey })
    })
    .then(function(r) { return r.json(); })
    .then(function(result) {
      if (result.error) { alert('Failed to save: ' + result.error); }
      // Reload
      loadData();
      // Also tell the dispatcher to refresh
      if (window.shapeClient) {
        window.shapeClient.load('os.shortcuts').catch(function(){});
        window.shapeClient.load('user.shortcuts').catch(function(){});
      }
    });
  }

  function resetOverride(suffix) {
    if (!confirm('Reset this shortcut to system default?')) return;
    fetch('/api/shortcut/reset', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({ suffix: suffix })
    })
    .then(function() { loadData(); });
  }

  function render() {
    body.innerHTML = '';

    var filtered = systemShortcuts.filter(function(sc) {
      if (currentFilter && sc.app !== currentFilter) return false;
      if (currentSearch) {
        var haystack = (sc.description + ' ' + sc.key + ' ' + sc.action + ' ' + sc.category).toLowerCase();
        if (haystack.indexOf(currentSearch) < 0) return false;
      }
      return true;
    });

    if (filtered.length === 0) {
      var empty = document.createElement('div');
      empty.className = 'shortcuts-empty';
      empty.textContent = 'No shortcuts match.';
      body.appendChild(empty);
      return;
    }

    // Group by category
    var groups = {};
    filtered.forEach(function(sc) {
      var cat = sc.category || 'General';
      if (!groups[cat]) groups[cat] = [];
      groups[cat].push(sc);
    });

    Object.keys(groups).sort().forEach(function(cat) {
      var groupEl = document.createElement('div');
      groupEl.className = 'shortcut-group';

      var title = document.createElement('div');
      title.className = 'shortcut-group-title';
      title.textContent = cat;
      groupEl.appendChild(title);

      groups[cat].forEach(function(sc) {
        var override = userOverrides[sc.suffix];
        var currentKey = override ? override.key : sc.key;
        var isOverridden = !!override;

        var row = document.createElement('div');
        row.className = 'shortcut-row';
        row.dataset.suffix = sc.suffix;

        var desc = document.createElement('span');
        desc.className = 'shortcut-desc';
        desc.textContent = sc.description;
        row.appendChild(desc);

        var app = document.createElement('span');
        app.className = 'shortcut-app';
        app.textContent = sc.app || '';
        row.appendChild(app);

        var keyWrap = document.createElement('div');
        keyWrap.className = 'shortcut-key-wrap';
        keyWrap.appendChild(formatKey(currentKey));
        if (isOverridden) {
          var badge = document.createElement('span');
          badge.className = 'shortcut-user-badge';
          badge.textContent = 'custom';
          keyWrap.appendChild(badge);
        }
        row.appendChild(keyWrap);

        var editBtn = document.createElement('button');
        editBtn.className = 'shortcut-edit-btn';
        editBtn.textContent = 'Edit';
        editBtn.addEventListener('click', function(e) {
          e.stopPropagation();
          startRecording(row, sc.suffix);
        });
        row.appendChild(editBtn);

        if (isOverridden) {
          var resetBtn = document.createElement('button');
          resetBtn.className = 'shortcuts-reset-btn';
          resetBtn.textContent = 'Reset';
          resetBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            resetOverride(sc.suffix);
          });
          row.appendChild(resetBtn);
        }

        groupEl.appendChild(row);
      });

      body.appendChild(groupEl);
    });
  }

  loadData();
})();
"""
}
