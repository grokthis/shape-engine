shape os.render.engine.shortcuts {
  type: script
  layer: 4
  """
// Global keyboard shortcut dispatcher.
// Loads os.shortcuts.** (system defaults) and user.shortcuts.** (user overrides)
// then registers a single keydown listener. Actions are symbolic names mapped
// to a registry of JS functions. Apps register their actions via
// window.shapeActions[name] = fn. The dispatcher calls the matching action.

(function() {
  // Action registry: symbolic name → function.
  // Apps register here on load; dispatcher calls by name.
  window.shapeActions = window.shapeActions || {};

  // Normalize a key combo from a shape dim into a canonical string.
  // "Cmd+Shift+S" → "meta+shift+s" (sorted: meta, ctrl, alt, shift, key)
  function normalizeKey(raw) {
    var parts = raw.replace(/\s+/g, '').split('+');
    var mods = { meta: false, ctrl: false, alt: false, shift: false };
    var key = '';
    parts.forEach(function(p) {
      var l = p.toLowerCase();
      if (l === 'cmd' || l === 'meta') { mods.meta = true; }
      else if (l === 'ctrl' || l === 'control') { mods.ctrl = true; }
      else if (l === 'alt' || l === 'option') { mods.alt = true; }
      else if (l === 'shift') { mods.shift = true; }
      else { key = l; }
    });
    var out = [];
    if (mods.meta) out.push('meta');
    if (mods.ctrl) out.push('ctrl');
    if (mods.alt) out.push('alt');
    if (mods.shift) out.push('shift');
    out.push(key);
    return out.join('+');
  }

  function normalizeEvent(e) {
    var mods = [];
    if (e.metaKey) mods.push('meta');
    if (e.ctrlKey) mods.push('ctrl');
    if (e.altKey) mods.push('alt');
    if (e.shiftKey) mods.push('shift');
    mods.push(e.key.toLowerCase());
    return mods.join('+');
  }

  // Shortcut map: canonical key string → action name
  var shortcutMap = {};

  function loadShortcuts(shapes) {
    if (!shapes) return;
    // Index by suffix so user overrides (same suffix under user.*) win over os.shortcuts.*
    var bySuffix = {};
    shapes.forEach(function(s) {
      var dims = s.character && s.character.dimensions;
      if (!dims || dims.type !== 'shortcut') return;
      var key = dims.key;
      var action = dims.action;
      if (!key || !action) return;
      // Extract suffix after os.shortcuts. or user.shortcuts.
      var id = s.id;
      var suffix = id;
      var osPfx = 'os.shortcuts.';
      var userPfx = 'user.shortcuts.';
      if (id.indexOf(osPfx) === 0) { suffix = id.slice(osPfx.length); }
      else if (id.indexOf(userPfx) === 0) { suffix = id.slice(userPfx.length); }
      // User overrides win (loaded second or marked with priority)
      if (!bySuffix[suffix] || id.indexOf('user.') === 0) {
        bySuffix[suffix] = { key: key, action: action };
      }
    });
    shortcutMap = {};
    Object.keys(bySuffix).forEach(function(suffix) {
      var entry = bySuffix[suffix];
      shortcutMap[normalizeKey(entry.key)] = entry.action;
    });
  }

  // Load shortcuts from both namespaces on startup, then refresh on tick.
  function fetchAndLoad() {
    Promise.all([
      window.shapeClient ? window.shapeClient.load('os.shortcuts').catch(function(){return[];}) : Promise.resolve([]),
      window.shapeClient ? window.shapeClient.load('user.shortcuts').catch(function(){return[];}) : Promise.resolve([])
    ]).then(function(results) {
      loadShortcuts((results[0] || []).concat(results[1] || []));
    });
  }

  fetchAndLoad();

  // Re-fetch when shapes change (engine tick).
  var lastRefresh = Date.now();
  document.addEventListener('visibilitychange', function() {
    if (!document.hidden && Date.now() - lastRefresh > 5000) {
      lastRefresh = Date.now();
      fetchAndLoad();
    }
  });

  // Global keydown handler — fires before app-specific handlers.
  document.addEventListener('keydown', function(e) {
    var combo = normalizeEvent(e);
    var action = shortcutMap[combo];
    if (!action) return;
    var fn = window.shapeActions[action];
    if (fn) {
      e.preventDefault();
      fn(e);
    }
  }, true); // capture phase so we can preventDefault before bubbling
})();
"""
}
