shape os.render.docs.script {
  type: script
  layer: 4
  """
(function() {
  var search = document.getElementById('docs-search');
  if (!search) return;
  search.addEventListener('input', function() {
    var q = this.value.toLowerCase();
    document.querySelectorAll('.sidebar-item').forEach(function(item) {
      var text = item.textContent.toLowerCase();
      if (q === '' || text.indexOf(q) >= 0) {
        item.classList.remove('hidden');
      } else {
        item.classList.add('hidden');
      }
    });
  });
})();
"""
}
