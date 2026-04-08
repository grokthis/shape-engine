shape os.render.doc.editor.script {
  type: script
  layer: 4
  """
(function() {
  var root = document.getElementById('doc');
  var docId = root.dataset.id;
  var blocks = [];

  // Page container.
  var page = document.createElement('div');
  page.className = 'doc-page';
  page.id = 'doc-page';
  root.appendChild(page);

  // Status bar.
  var status = document.createElement('div');
  status.className = 'doc-status';
  status.innerHTML = '<span id="doc-status-left">Ready</span><span id="doc-status-right"></span>';
  root.appendChild(status);

  // Undo stack.
  var undoStack = [], redoStack = [];

  function addBlock(type, level, content) {
    var el = document.createElement('div');
    el.className = 'doc-block';
    el.contentEditable = true;
    el.dataset.type = type || 'paragraph';
    if (level) el.dataset.level = level;
    el.innerHTML = content || '<br>';
    el.addEventListener('input', onBlockInput);
    el.addEventListener('keydown', onBlockKeydown);
    el.addEventListener('focus', onBlockFocus);
    page.appendChild(el);
    blocks.push(el);
    return el;
  }

  function onBlockInput(e) {
    updateStatus();
    saveBlock(e.target);
  }

  function onBlockFocus(e) {
    updateStatus();
  }

  function onBlockKeydown(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      var newBlock = addBlock('paragraph', 0, '');
      newBlock.focus();
    }
  }

  function saveBlock(el) {
    if (!docId) return;
    var idx = blocks.indexOf(el);
    var order = String(idx + 1).padStart(3, '0');
    fetch('/office/doc/' + docId + '/block', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        block_type: el.dataset.type,
        order: order,
        content: el.innerHTML
      })
    });
  }

  function updateStatus() {
    var words = page.textContent.trim().split(/\s+/).filter(function(w) { return w; }).length;
    var chars = page.textContent.length;
    document.getElementById('doc-status-left').textContent = words + ' words, ' + chars + ' characters';
    document.getElementById('doc-status-right').textContent = blocks.length + ' blocks';
  }

  // Formatting commands.
  window.execCmd = function(cmd) { document.execCommand(cmd); };
  window.execFormat = function(prop, val) {
    var sel = window.getSelection();
    if (sel.rangeCount > 0) {
      document.execCommand('styleWithCSS', false, true);
      if (prop === 'fontFamily') document.execCommand('fontName', false, val);
      if (prop === 'fontSize') document.execCommand('fontSize', false, '7');
    }
  };

  window.setHeading = function(level) {
    var sel = window.getSelection();
    if (!sel.rangeCount) return;
    var block = sel.anchorNode;
    while (block && !block.classList) block = block.parentNode;
    if (!block || !block.classList.contains('doc-block')) return;
    if (level === 0) {
      block.dataset.type = 'paragraph';
      delete block.dataset.level;
    } else {
      block.dataset.type = 'heading';
      block.dataset.level = level;
    }
    saveBlock(block);
  };

  window.insertTable = function() {
    var rowCount = parseInt(prompt('Rows:', '3')) || 3;
    var colCount = parseInt(prompt('Columns:', '3')) || 3;
    var html = '<table>';
    for (var r = 0; r < rowCount; r++) {
      html += '<tr>';
      for (var c = 0; c < colCount; c++) {
        html += '<td contenteditable="true">&nbsp;</td>';
      }
      html += '</tr>';
    }
    html += '</table>';
    var block = addBlock('table', 0, html);
    block.contentEditable = false;
  };

  window.exportDoc = function() {
    var html = '<!DOCTYPE html><html><head><style>body{font-family:sans-serif;max-width:700px;margin:40px auto;line-height:1.5;}</style></head><body>';
    blocks.forEach(function(b) { html += b.outerHTML; });
    html += '</body></html>';
    var blob = new Blob([html], { type: 'text/html' });
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = (docId || 'document') + '.html';
    a.click();
  };

  // Keyboard shortcuts.
  document.addEventListener('keydown', function(e) {
    if (e.metaKey || e.ctrlKey) {
      if (e.key === 'b') { e.preventDefault(); execCmd('bold'); }
      if (e.key === 'i') { e.preventDefault(); execCmd('italic'); }
      if (e.key === 'u') { e.preventDefault(); execCmd('underline'); }
      if (e.key === 'z') { e.preventDefault(); document.execCommand('undo'); }
      if (e.key === 'y') { e.preventDefault(); document.execCommand('redo'); }
      if (e.key >= '1' && e.key <= '6') { e.preventDefault(); setHeading(parseInt(e.key)); }
    }
  });

  // Load from server.
  function loadData() {
    if (!docId) { addBlock('paragraph', 0, ''); return; }
    fetch('/office/doc/' + docId + '/data')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (data.blocks && data.blocks.length > 0) {
          data.blocks.forEach(function(b) {
            var content = '';
            if (b.runs && b.runs.length > 0) {
              b.runs.forEach(function(r) { content += r.content; });
            } else {
              content = b.dims ? b.dims.content || '' : '';
            }
            addBlock(b.type || 'paragraph', b.dims ? b.dims.level : 0, content || '<br>');
          });
        } else {
          addBlock('paragraph', 0, '');
        }
        updateStatus();
      })
      .catch(function() { addBlock('paragraph', 0, ''); });
  }

  loadData();
})();
"""
}
