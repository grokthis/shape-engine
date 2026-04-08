shape os.render.font.picker.script {
  type: script
  layer: 4
  """
(function() {
  window.FontPicker = {
    show: function(anchor, callback) {
      var existing = document.querySelector('.font-picker');
      if (existing) existing.remove();

      var picker = document.createElement('div');
      picker.className = 'font-picker';

      var fonts = [
        { name: 'Sans Serif', family: 'sans-serif' },
        { name: 'Serif', family: 'serif' },
        { name: 'Monospace', family: 'monospace' },
        { name: 'System UI', family: 'system-ui' }
      ];

      // Load registered fonts from engine.
      fetch('/api/shapes?prefix=os.font.&type=font-family')
        .then(function(r) { return r.json(); })
        .then(function(shapes) {
          if (shapes && shapes.length) {
            shapes.forEach(function(s) {
              if (s.dims && s.dims.name) {
                fonts.push({ name: s.dims.name, family: s.dims.name });
              }
            });
          }
          render();
        })
        .catch(render);

      function render() {
        fonts.forEach(function(f) {
          var item = document.createElement('div');
          item.className = 'font-item';
          item.innerHTML = '<div class="name">' + f.name + '</div>' +
            '<div class="preview" style="font-family:' + f.family + '">The quick brown fox</div>';
          item.onclick = function() {
            callback(f.family);
            picker.remove();
          };
          picker.appendChild(item);
        });
      }

      var rect = anchor.getBoundingClientRect();
      picker.style.top = rect.bottom + 'px';
      picker.style.left = rect.left + 'px';
      document.body.appendChild(picker);

      setTimeout(function() {
        document.addEventListener('click', function remove(e) {
          if (!picker.contains(e.target)) {
            picker.remove();
            document.removeEventListener('click', remove);
          }
        });
      }, 0);
    }
  };
})();
"""
}
