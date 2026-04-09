shape os.render.doc.editor.script {
  type: script
  layer: 4
  deps: os.render.doc.editor.body
  """
(function() {
  var page = document.getElementById('doc-page');
  if (!page) return;

  // Find our window-content container — it carries data-doc and data-app.
  var container = page.closest('.window-content') || page.closest('[data-doc]') || page.parentElement;
  var docId = (container && container.dataset.doc) || '';
  var APP = 'document';

  var statusLeft = document.getElementById('doc-status-left');
  var statusRight = document.getElementById('doc-status-right');

  var blocks = [];
  var savedSel = null;
  var saveTimer = null;
  var dirty = false;

  // --- Selection management (toolbar focus loss) ---

  function saveSelection() {
    var sel = window.getSelection();
    if (sel && sel.rangeCount > 0) savedSel = sel.getRangeAt(0).cloneRange();
  }

  function restoreSelection() {
    if (!savedSel) return;
    var sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(savedSel);
  }

  function refocusAfterToolbar() {
    restoreSelection();
    if (savedSel) {
      var node = savedSel.commonAncestorContainer;
      var block = node.nodeType === 1 ? node : node.parentElement;
      while (block && !block.classList.contains('doc-block')) block = block.parentElement;
      if (block) block.focus();
    }
  }

  var toolbar = document.querySelector('.doc-toolbar');
  if (toolbar) toolbar.addEventListener('mousedown', saveSelection);

  // --- Block management ---

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

  function onBlockInput() {
    dirty = true;
    scheduleAutoSave();
    updateStatus();
  }

  function onBlockFocus(e) {
    updateStatus();
    var sel = document.getElementById('heading-select');
    if (sel) {
      var level = e.target.dataset.type === 'heading' ? (e.target.dataset.level || '1') : '0';
      sel.value = level;
    }
  }

  function onBlockKeydown(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      addBlock('paragraph', 0, '').focus();
    }
    // Shortcut combos are handled by the global dispatcher (os.render.engine.shortcuts).
    // Actions are registered below via window.shapeActions.
  }

  // --- Persistence ---

  function blocksToJSON() {
    return JSON.stringify(blocks.map(function(b) {
      return { type: b.dataset.type || 'paragraph', level: b.dataset.level || '', html: b.innerHTML };
    }));
  }

  function scheduleAutoSave() {
    if (saveTimer) clearTimeout(saveTimer);
    saveTimer = setTimeout(autoSave, 800);
  }

  function autoSave() {
    if (!docId || !dirty) return;
    dirty = false;
    fetch('/api/shape/' + docId, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({id: docId, type: 'document', content: blocksToJSON()})
    });
  }

  // Save: if session doc, prompt for name. If permanent, auto-save.
  window.saveDoc = function() {
    if (!docId || docId.indexOf('os.session.doc.') === 0) {
      saveDocAs();
      return;
    }
    autoSave();
    flashStatus('Saved');
  };

  window.saveDocAs = function() {
    var name = prompt('Save as (e.g. "notes" or "projects/meeting"):');
    if (!name) return;
    // Sanitize: / → . for sub-namespaces, strip dangerous chars.
    name = name.trim().replace(/\s+/g, '-').replace(/[^a-zA-Z0-9./_-]/g, '').replace(/\/+/g, '/');
    if (!name) return;

    fetch('/api/doc/save', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({name: name, app: APP, content: blocksToJSON(), src_id: docId})
    })
    .then(function(r) { return r.json(); })
    .then(function(result) {
      if (result.error) { alert('Save failed: ' + result.error); return; }
      docId = result.id;
      if (container) container.dataset.doc = docId;
      dirty = false;
      flashStatus('Saved as ' + name);
      updateDocTitle(name);
    });
  };

  window.openDoc = function() {
    // List documents saved for this app under all user.* namespaces.
    fetch('/api/shapes?prefix=user')
      .then(function(r) { return r.json(); })
      .then(function(shapes) {
        var docs = (shapes || []).filter(function(s) {
          return s.character && s.character.dimensions &&
                 s.character.dimensions.type === 'document' &&
                 s.id.indexOf('.documents.' + APP + '.') >= 0;
        });
        if (docs.length === 0) {
          alert('No saved documents yet.\nUse File > Save As to save this document.');
          return;
        }
        var list = docs.map(function(s) {
          return (s.character.dimensions.name || s.id);
        });
        var choice = prompt('Open document:\n\n' + list.join('\n'));
        if (!choice) return;
        var target = docs.find(function(s) {
          return s.id === choice ||
                 (s.character.dimensions.name || '') === choice ||
                 s.id.endsWith('.' + choice.replace(/\//g, '.'));
        });
        if (!target) { alert('Document not found: ' + choice); return; }
        loadFromShape(target.id, target.character ? target.character.content : '');
      });
  };

  window.newDoc = function() {
    if (dirty && !confirm('Unsaved changes will be lost. Continue?')) return;
    // Create a fresh session doc shape and switch to it.
    fetch('/api/shape', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({id: 'os.session.doc.new.' + Date.now(), type: 'document', content: '[]'})
    })
    .then(function(r) { return r.json(); })
    .then(function(result) {
      docId = result.shape || '';
      if (container) container.dataset.doc = docId;
      clearPage();
      addBlock('paragraph', 0, '').focus();
      dirty = false;
      updateDocTitle('Untitled');
      updateStatus();
    });
  };

  function loadFromShape(id, content) {
    docId = id;
    if (container) container.dataset.doc = docId;
    clearPage();
    try {
      var bls = JSON.parse(content || '[]');
      if (bls.length > 0) {
        bls.forEach(function(b) { addBlock(b.type, b.level, b.html); });
        blocks[0].focus();
        return;
      }
    } catch(e) {}
    addBlock('paragraph', 0, '').focus();
    dirty = false;
    updateStatus();
  }

  function clearPage() {
    while (page.firstChild) page.removeChild(page.firstChild);
    blocks = [];
  }

  // --- Status / title ---

  function updateStatus() {
    var words = page.textContent.trim().split(/\s+/).filter(function(w) { return w; }).length;
    var chars = page.textContent.length;
    if (statusLeft) statusLeft.textContent = words + ' words, ' + chars + ' chars';
    if (statusRight) {
      var label = docId && docId.indexOf('os.session.doc.') !== 0 ? docId.split('.').pop() : 'Untitled';
      statusRight.textContent = (dirty ? '● ' : '') + label;
    }
  }

  function flashStatus(msg) {
    if (!statusLeft) return;
    var prev = statusLeft.textContent;
    statusLeft.textContent = msg;
    setTimeout(function() { statusLeft.textContent = prev; }, 1800);
  }

  function updateDocTitle(name) {
    if (statusRight) statusRight.textContent = name;
  }

  // --- Formatting commands ---

  window.execCmd = function(cmd) { refocusAfterToolbar(); document.execCommand(cmd); };
  window.execFormat = function(prop, val) {
    refocusAfterToolbar();
    document.execCommand('styleWithCSS', false, true);
    if (prop === 'fontFamily') document.execCommand('fontName', false, val);
    if (prop === 'fontSize') document.execCommand('fontSize', false, '7');
  };

  window.setHeading = function(level) {
    var block = null;
    if (savedSel) {
      var node = savedSel.commonAncestorContainer;
      block = node.nodeType === 1 ? node : node.parentElement;
      while (block && !block.classList.contains('doc-block')) block = block.parentElement;
    }
    if (!block) return;
    if (level === 0) { block.dataset.type = 'paragraph'; delete block.dataset.level; }
    else { block.dataset.type = 'heading'; block.dataset.level = level; }
    var sel = document.getElementById('heading-select');
    if (sel) sel.value = String(level);
    refocusAfterToolbar();
  };

  // --- Table management ---

  var activeCell = null;

  function makeCell() {
    var td = document.createElement('td');
    td.contentEditable = 'true';
    td.innerHTML = '&nbsp;';
    td.addEventListener('focus', onCellFocus);
    td.addEventListener('blur', onCellBlur);
    return td;
  }

  function onCellFocus(e) {
    activeCell = e.target;
    saveSelection();
    setTableFmt(true);
  }

  function onCellBlur() {
    setTimeout(function() {
      var focused = document.activeElement;
      var fmtEl = document.getElementById('table-fmt');
      if (focused === fmtEl) return;
      if (!activeCell || !focused || !activeCell.closest('table').contains(focused)) {
        activeCell = null;
        setTableFmt(false);
      }
    }, 100);
  }

  function setTableFmt(visible) {
    var el = document.getElementById('table-fmt');
    if (el) el.classList.toggle('visible', visible);
  }

  window.insertTable = function(size) {
    var rowCount, colCount;
    if (!size || size === 'custom') {
      rowCount = parseInt(prompt('Rows:', '3')) || 3;
      colCount = parseInt(prompt('Columns:', '3')) || 3;
    } else {
      var parts = size.split('x');
      rowCount = parseInt(parts[0]) || 3;
      colCount = parseInt(parts[1]) || 3;
    }
    var table = document.createElement('table');
    for (var r = 0; r < rowCount; r++) {
      var tr = table.insertRow();
      for (var c = 0; c < colCount; c++) tr.appendChild(makeCell());
    }
    var block = addBlock('table', 0, '');
    block.contentEditable = false;
    block.innerHTML = '';
    block.appendChild(table);
    table.rows[0].cells[0].focus();
    dirty = true;
    scheduleAutoSave();
  };

  window.tableCmd = function(cmd) {
    if (!activeCell) return;
    activeCell.focus();
    var tr = activeCell.closest('tr');
    var table = activeCell.closest('table');
    var rowIdx = tr.rowIndex;
    var colIdx = activeCell.cellIndex;
    var colCount = tr.cells.length;

    if (cmd === 'add_row') {
      var nr = table.insertRow(rowIdx + 1);
      for (var c = 0; c < colCount; c++) nr.appendChild(makeCell());
      nr.cells[0].focus();
    } else if (cmd === 'add_row_above') {
      var nr = table.insertRow(rowIdx);
      for (var c = 0; c < colCount; c++) nr.appendChild(makeCell());
      nr.cells[0].focus();
    } else if (cmd === 'del_row') {
      if (table.rows.length <= 1) return;
      table.deleteRow(rowIdx);
      var r = table.rows[Math.min(rowIdx, table.rows.length - 1)];
      if (r) r.cells[0].focus();
    } else if (cmd === 'add_col') {
      var ins = colIdx + 1;
      Array.from(table.rows).forEach(function(r) { r.insertBefore(makeCell(), r.cells[ins] || null); });
      table.rows[rowIdx].cells[ins].focus();
    } else if (cmd === 'add_col_left') {
      Array.from(table.rows).forEach(function(r) { r.insertBefore(makeCell(), r.cells[colIdx]); });
      table.rows[rowIdx].cells[colIdx].focus();
    } else if (cmd === 'del_col') {
      if (table.rows[0].cells.length <= 1) return;
      Array.from(table.rows).forEach(function(r) { r.deleteCell(colIdx); });
      table.rows[rowIdx].cells[Math.min(colIdx, table.rows[0].cells.length - 1)].focus();
    } else if (cmd === 'merge') {
      var selected = Array.from(table.querySelectorAll('.selected-cell'));
      if (selected.length < 2) return;
      selected[0].innerHTML = selected.map(function(td) { return td.innerHTML; }).join(' ');
      selected[0].colSpan = selected.length;
      selected[0].classList.remove('selected-cell');
      for (var i = 1; i < selected.length; i++) selected[i].remove();
    } else if (cmd === 'split') {
      if (activeCell.colSpan <= 1) return;
      var span = activeCell.colSpan;
      activeCell.colSpan = 1;
      for (var i = 1; i < span; i++) activeCell.parentNode.insertBefore(makeCell(), activeCell.nextSibling);
    }

    dirty = true;
    scheduleAutoSave();
  };

  // --- Insert helpers ---

  window.insertHR = function() {
    refocusAfterToolbar();
    document.execCommand('insertHorizontalRule');
    dirty = true;
    scheduleAutoSave();
  };

  // --- Export / utility ---

  window.exportDoc = function(format) {
    if (format === 'pdf') { window.print(); return; }
    var html = '<!DOCTYPE html><html><head><meta charset="utf-8"><style>body{font-family:sans-serif;max-width:700px;margin:40px auto;line-height:1.6;color:#111;}</style></head><body>';
    blocks.forEach(function(b) { html += b.outerHTML; });
    html += '</body></html>';
    var blob = new Blob([html], {type: 'text/html'});
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = (docId ? docId.split('.').pop() : 'document') + '.html';
    a.click();
  };

  window.docFind = function() {
    var q = prompt('Find:');
    if (!q) return;
    var re = new RegExp('(' + q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
    page.innerHTML = page.innerHTML.replace(re, '<mark>$1</mark>');
  };

  window.showShortcuts = function() {
    alert('Cmd+S  Save\nCmd+Shift+S  Save As\nCmd+O  Open\nCmd+N  New\nCmd+B  Bold\nCmd+I  Italic\nCmd+U  Underline\nCmd+Z  Undo\nCmd+P  Print');
  };

  window.showAbout = function() {
    alert('Shape OS Document Editor\nDocuments live at <user>.documents.document.*');
  };

  // --- Clicking the page margin focuses last block ---

  page.addEventListener('click', function(e) {
    if (e.target === page) {
      if (blocks.length === 0) { addBlock('paragraph', 0, '').focus(); }
      else {
        var last = blocks[blocks.length - 1];
        last.focus();
        var range = document.createRange();
        range.selectNodeContents(last);
        range.collapse(false);
        var sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
      }
    }
  });

  // --- Load ---

  function loadData() {
    if (!docId) { addBlock('paragraph', 0, '').focus(); return; }
    fetch('/api/shape/' + docId)
      .then(function(r) { return r.json(); })
      .then(function(s) {
        var content = s.character ? s.character.content : '';
        loadFromShape(docId, content);
      })
      .catch(function() { addBlock('paragraph', 0, '').focus(); });
  }

  loadData();
  updateStatus();

  // Register actions with the global shortcut dispatcher.
  // The dispatcher (os.render.engine.shortcuts) maps symbolic action names → these functions.
  window.shapeActions = window.shapeActions || {};
  window.shapeActions['document_save']    = function() { saveDoc(); };
  window.shapeActions['document_save_as'] = function() { saveDocAs(); };
  window.shapeActions['document_open']    = function() { openDoc(); };
  window.shapeActions['document_new']     = function() { newDoc(); };
  window.shapeActions['doc_print']        = function() { window.print(); };
  window.shapeActions['format_bold']      = function() { refocusAfterToolbar(); document.execCommand('bold'); };
  window.shapeActions['format_italic']    = function() { refocusAfterToolbar(); document.execCommand('italic'); };
  window.shapeActions['format_underline'] = function() { refocusAfterToolbar(); document.execCommand('underline'); };
  window.shapeActions['format_strike']    = function() { refocusAfterToolbar(); document.execCommand('strikeThrough'); };
  window.shapeActions['format_clear']     = function() { refocusAfterToolbar(); document.execCommand('removeFormat'); };
  window.shapeActions['edit_undo']        = function() { document.execCommand('undo'); };
  window.shapeActions['edit_redo']        = function() { document.execCommand('redo'); };
  window.shapeActions['edit_cut']         = function() { document.execCommand('cut'); };
  window.shapeActions['edit_copy']        = function() { document.execCommand('copy'); };
  window.shapeActions['edit_paste']       = function() { document.execCommand('paste'); };
  window.shapeActions['edit_select_all']  = function() { document.execCommand('selectAll'); };
  window.shapeActions['edit_find']        = function() { docFind(); };
  window.shapeActions['insert_table']     = function() { insertTable('custom'); };
  window.shapeActions['insert_hr']        = function() { insertHR(); };
})();
"""
}
