shape os.render.engine.client {
  type: script
  layer: 4
  """
(function() {
  var _cache = {};

  // In WASM mode: index all shapes from the local engine immediately.
  if (window.shapeEngine) {
    window.shapeEngine.engine.allShapes().forEach(function(s) {
      _cache[s.id] = s;
    });
  }

  function getShape(id) {
    return _cache[id] || null;
  }

  // Returns all shapes whose IDs are direct children of prefix,
  // sorted by topological dep order. A child that lists another sibling
  // in its deps renders after it. This is structural ordering: deps encode
  // the propagation sequence, not arbitrary numbers.
  function getDirectChildren(prefix) {
    var depth = prefix.split('.').length + 1;
    var p = prefix + '.';
    var byId = {};
    for (var id in _cache) {
      if (id.startsWith(p) && id.split('.').length === depth) {
        byId[id] = _cache[id];
      }
    }

    // Topological sort: shapes with no sibling-deps first.
    var ids = Object.keys(byId);
    var sorted = [];
    var visited = {};

    function visit(id) {
      if (visited[id]) return;
      visited[id] = true;
      var s = byId[id];
      var deps = (s && s.structure && s.structure.transformation && s.structure.transformation.deps) || [];
      deps.forEach(function(dep) {
        if (byId[dep]) visit(dep);
      });
      sorted.push(byId[id]);
    }

    ids.forEach(visit);
    return sorted;
  }

  // Returns all shapes under a prefix (any depth).
  function getShapesUnder(prefix) {
    var p = prefix + '.';
    var result = [];
    for (var id in _cache) {
      if (id.startsWith(p)) result.push(_cache[id]);
    }
    return result;
  }

  // Load shapes from the server (native mode only; WASM already indexed above).
  function load(prefix) {
    if (window.shapeEngine) return Promise.resolve();
    var url = '/api/shapes' + (prefix ? '?prefix=' + encodeURIComponent(prefix) : '');
    return fetch(url)
      .then(function(r) { return r.json(); })
      .then(function(shapes) {
        if (Array.isArray(shapes)) {
          shapes.forEach(function(s) { if (s && s.id) _cache[s.id] = s; });
        }
      });
  }

  window.shapeClient = {
    getShape: getShape,
    getDirectChildren: getDirectChildren,
    getShapesUnder: getShapesUnder,
    load: load
  };

  // Global debounce utility. Returns a function that delays invoking fn
  // until after delay ms have elapsed since the last call.
  // Usage: var save = debounce(fn, 500);
  window.debounce = function(fn, delay) {
    var timer;
    return function() {
      var args = arguments;
      var ctx = this;
      clearTimeout(timer);
      timer = setTimeout(function() { fn.apply(ctx, args); }, delay);
    };
  };
})();
"""
}
