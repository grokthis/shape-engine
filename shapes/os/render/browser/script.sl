shape os.render.browser.script {
  type: script
  layer: 4
  """
(function() {
  var tree = document.getElementById('browser-tree');
  var detail = document.getElementById('browser-detail');
  var pathInput = document.getElementById('browser-path');
  var goBtn = document.getElementById('browser-go');
  var currentPrefix = '';

  function loadTree(prefix) {
    // Normalize: strip trailing dots/slashes, convert slashes to dots.
    currentPrefix = (prefix || '').replace(/\/+/g, '.').replace(/\.+$/, '').replace(/^\.+/, '');
    pathInput.value = 'shape://' + currentPrefix;
    fetch('/api/shapes?prefix=' + encodeURIComponent(currentPrefix))
      .then(function(r) { return r.json(); })
      .then(function(shapes) {
        tree.innerHTML = '';
        // Group by immediate children
        var seen = {};
        shapes.forEach(function(s) {
          var id = s.id || '';
          var rest = prefix ? id.substring(prefix.length + 1) : id;
          var dot = rest.indexOf('.');
          var seg = dot >= 0 ? rest.substring(0, dot) : rest;
          if (seg && !seen[seg]) {
            seen[seg] = true;
            var full = prefix ? prefix + '.' + seg : seg;
            var item = document.createElement('div');
            item.className = 'tree-item';
            item.textContent = seg;
            var typ = s.character && s.character.dimensions ? s.character.dimensions.type : '';
            if (dot >= 0) {
              var sp = document.createElement('span');
              sp.className = 'tree-type';
              sp.textContent = '/';
              item.appendChild(sp);
            } else if (typ) {
              var sp = document.createElement('span');
              sp.className = 'tree-type';
              sp.textContent = typ;
              item.appendChild(sp);
            }
            item.addEventListener('click', function() {
              if (dot >= 0) {
                loadTree(full);
              } else {
                loadDetail(full);
                document.querySelectorAll('.tree-item').forEach(function(i) { i.classList.remove('active'); });
                item.classList.add('active');
              }
            });
            tree.appendChild(item);
          }
        });
      });
  }

  function loadDetail(id) {
    fetch('/api/shape/' + encodeURIComponent(id))
      .then(function(r) { return r.json(); })
      .then(function(s) {
        var html = '<div class="detail-id">' + (s.id || id) + '</div>';
        var dims = s.character && s.character.dimensions ? s.character.dimensions : {};
        html += '<div class="detail-type">' + (dims.type || 'shape') + '</div>';
        if (s.character && s.character.content) {
          html += '<div class="detail-content">' + escapeHtml(s.character.content) + '</div>';
        }
        if (Object.keys(dims).length > 0) {
          html += '<dl class="detail-dims">';
          Object.keys(dims).sort().forEach(function(k) {
            html += '<dt>' + k + '</dt><dd>' + escapeHtml(dims[k]) + '</dd>';
          });
          html += '</dl>';
        }
        var depList = s.structure && s.structure.transformation && s.structure.transformation.deps ? s.structure.transformation.deps : [];
        if (depList.length > 0) {
          html += '<div class="detail-deps"><strong>deps:</strong> ';
          depList.forEach(function(d, i) {
            if (i > 0) html += ', ';
            html += '<a href="#" data-id="' + d + '">' + d + '</a>';
          });
          html += '</div>';
        }
        detail.innerHTML = html;
        detail.querySelectorAll('.detail-deps a').forEach(function(a) {
          a.addEventListener('click', function(e) {
            e.preventDefault();
            loadDetail(this.dataset.id);
          });
        });
      });
  }

  function escapeHtml(s) {
    var d = document.createElement('div');
    d.textContent = s;
    return d.innerHTML;
  }

  goBtn.addEventListener('click', function() {
    var val = pathInput.value.replace(/^shape:\/\//, '').replace(/\/+$/, '').replace(/\//g, '.');
    loadTree(val);
  });

  pathInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') goBtn.click();
  });

  // Load root
  loadTree('');
})();
"""
}
