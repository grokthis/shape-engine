shape os.render.sheet.script {
  type: script
  layer: 4
  """
(function() {
  var root = document.getElementById('sheet');
  var sheetId = root.dataset.id;
  var cols = 26, rows = 50;
  var cells = {};
  var selectedCell = null;
  var editingCell = null;

  // Build toolbar.
  var toolbar = document.createElement('div');
  toolbar.className = 'sheet-toolbar';
  toolbar.innerHTML = '<button onclick="newSheet()">New</button>' +
    '<button id="btn-bold" onclick="toggleBold()">B</button>' +
    '<button id="btn-export" onclick="exportCSV()">Export CSV</button>' +
    '<span style="flex:1"></span>' +
    '<span id="sheet-title">' + (sheetId || 'Untitled') + '</span>';
  root.appendChild(toolbar);

  // Formula bar.
  var formulaBar = document.createElement('div');
  formulaBar.className = 'formula-bar';
  formulaBar.innerHTML = '<span class="cell-ref" id="cell-ref">A1</span>' +
    '<input id="formula-input" placeholder="Enter value or formula (=SUM(A1:A5))">';
  root.appendChild(formulaBar);
  var formulaInput = document.getElementById('formula-input');
  var cellRefDisplay = document.getElementById('cell-ref');

  // Grid container.
  var gridContainer = document.createElement('div');
  gridContainer.className = 'grid-container';
  root.appendChild(gridContainer);

  var grid = document.createElement('div');
  grid.className = 'grid';
  grid.style.gridTemplateColumns = '40px ' + Array(cols).fill('80px').join(' ');
  gridContainer.appendChild(grid);

  // Status bar.
  var statusBar = document.createElement('div');
  statusBar.className = 'sheet-status';
  statusBar.innerHTML = '<span id="status-left">Ready</span><span id="status-right"></span>';
  root.appendChild(statusBar);

  function colLetter(i) { return String.fromCharCode(65 + i); }
  function cellId(c, r) { return colLetter(c) + (r + 1); }

  // Build grid.
  function buildGrid() {
    grid.innerHTML = '';
    // Corner.
    var corner = document.createElement('div');
    corner.className = 'corner';
    grid.appendChild(corner);

    // Column headers.
    for (var c = 0; c < cols; c++) {
      var ch = document.createElement('div');
      ch.className = 'col-header';
      ch.textContent = colLetter(c);
      ch.dataset.col = c;
      grid.appendChild(ch);
    }

    // Rows.
    for (var r = 0; r < rows; r++) {
      // Row header.
      var rh = document.createElement('div');
      rh.className = 'row-header';
      rh.textContent = r + 1;
      grid.appendChild(rh);

      for (var c = 0; c < cols; c++) {
        var cell = document.createElement('div');
        cell.className = 'cell';
        cell.dataset.col = c;
        cell.dataset.row = r;
        cell.dataset.id = cellId(c, r);
        cell.tabIndex = 0;

        // Load existing value.
        var id = cellId(c, r);
        if (cells[id]) {
          cell.textContent = cells[id].value || '';
        }

        cell.addEventListener('click', onCellClick);
        cell.addEventListener('dblclick', onCellDblClick);
        cell.addEventListener('keydown', onCellKeydown);
        grid.appendChild(cell);
      }
    }
  }

  function onCellClick(e) {
    if (editingCell) commitEdit();
    selectCell(e.target);
  }

  function selectCell(el) {
    if (selectedCell) selectedCell.classList.remove('selected');
    selectedCell = el;
    el.classList.add('selected');
    el.focus();
    var id = el.dataset.id;
    cellRefDisplay.textContent = id;
    var data = cells[id];
    formulaInput.value = data ? (data.formula || data.value || '') : '';
  }

  function onCellDblClick(e) {
    startEdit(e.target);
  }

  function startEdit(el) {
    editingCell = el;
    el.classList.add('editing');
    el.contentEditable = true;
    el.focus();
    // Show formula if present.
    var id = el.dataset.id;
    if (cells[id] && cells[id].formula) {
      el.textContent = cells[id].formula;
    }
  }

  function commitEdit() {
    if (!editingCell) return;
    var el = editingCell;
    el.contentEditable = false;
    el.classList.remove('editing');
    var id = el.dataset.id;
    var val = el.textContent.trim();

    var cellData = { value: val, format: 'general' };
    if (val.startsWith('=')) {
      cellData.formula = val;
      cellData.format = 'formula';
      cellData.value = evalFormula(val, id);
      el.textContent = cellData.value;
    }
    cells[id] = cellData;
    editingCell = null;

    // POST to server.
    if (sheetId) {
      fetch('/office/sheet/' + sheetId + '/cell', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          cell: id,
          value: cellData.value,
          format: cellData.format,
          formula: cellData.formula || ''
        })
      });
    }

    updateStatus();
  }

  function evalFormula(formula, cellId) {
    // Simple formula evaluation.
    var expr = formula.substring(1).trim();

    // SUM(A1:A5) pattern.
    var sumMatch = expr.match(/^SUM\(([A-Z])(\d+):([A-Z])(\d+)\)$/i);
    if (sumMatch) {
      var c1 = sumMatch[1].toUpperCase().charCodeAt(0) - 65;
      var r1 = parseInt(sumMatch[2]) - 1;
      var c2 = sumMatch[3].toUpperCase().charCodeAt(0) - 65;
      var r2 = parseInt(sumMatch[4]) - 1;
      var total = 0;
      for (var r = r1; r <= r2; r++) {
        for (var c = c1; c <= c2; c++) {
          var ref = colLetter(c) + (r + 1);
          if (cells[ref]) total += parseFloat(cells[ref].value) || 0;
        }
      }
      return String(total);
    }

    // AVERAGE pattern.
    var avgMatch = expr.match(/^AVERAGE\(([A-Z])(\d+):([A-Z])(\d+)\)$/i);
    if (avgMatch) {
      var c1 = avgMatch[1].toUpperCase().charCodeAt(0) - 65;
      var r1 = parseInt(avgMatch[2]) - 1;
      var c2 = avgMatch[3].toUpperCase().charCodeAt(0) - 65;
      var r2 = parseInt(avgMatch[4]) - 1;
      var total = 0, count = 0;
      for (var r = r1; r <= r2; r++) {
        for (var c = c1; c <= c2; c++) {
          var ref = colLetter(c) + (r + 1);
          if (cells[ref]) { total += parseFloat(cells[ref].value) || 0; count++; }
        }
      }
      return count > 0 ? String(total / count) : '0';
    }

    // Simple cell references: =A1+B1.
    var resolved = expr.replace(/([A-Z])(\d+)/gi, function(m, col, row) {
      var ref = col.toUpperCase() + row;
      return cells[ref] ? (parseFloat(cells[ref].value) || 0) : 0;
    });
    try { return String(eval(resolved)); } catch(e) { return '#ERR'; }
  }

  function onCellKeydown(e) {
    var el = e.target;
    if (editingCell) {
      if (e.key === 'Enter') { e.preventDefault(); commitEdit(); moveDown(); }
      if (e.key === 'Tab') { e.preventDefault(); commitEdit(); moveRight(); }
      if (e.key === 'Escape') { cancelEdit(); }
      return;
    }

    // Navigation.
    var c = parseInt(el.dataset.col), r = parseInt(el.dataset.row);
    if (e.key === 'ArrowRight' || e.key === 'Tab') { e.preventDefault(); moveTo(c+1, r); }
    else if (e.key === 'ArrowLeft') { moveTo(c-1, r); }
    else if (e.key === 'ArrowDown' || e.key === 'Enter') { e.preventDefault(); moveTo(c, r+1); }
    else if (e.key === 'ArrowUp') { moveTo(c, r-1); }
    else if (e.key === 'Delete' || e.key === 'Backspace') {
      var id = el.dataset.id;
      delete cells[id];
      el.textContent = '';
    }
    else if (e.key.length === 1 && !e.ctrlKey && !e.metaKey) {
      // Start typing into cell.
      startEdit(el);
    }
  }

  function moveTo(c, r) {
    if (c < 0 || c >= cols || r < 0 || r >= rows) return;
    var id = cellId(c, r);
    var el = grid.querySelector('[data-id="' + id + '"]');
    if (el) selectCell(el);
  }
  function moveDown() { if (selectedCell) moveTo(parseInt(selectedCell.dataset.col), parseInt(selectedCell.dataset.row)+1); }
  function moveRight() { if (selectedCell) moveTo(parseInt(selectedCell.dataset.col)+1, parseInt(selectedCell.dataset.row)); }

  function cancelEdit() {
    if (!editingCell) return;
    var el = editingCell;
    el.contentEditable = false;
    el.classList.remove('editing');
    var id = el.dataset.id;
    el.textContent = cells[id] ? cells[id].value : '';
    editingCell = null;
  }

  function updateStatus() {
    var count = Object.keys(cells).length;
    document.getElementById('status-left').textContent = count + ' cells';
    // Sum of selected region (simplified: show selected cell value).
    if (selectedCell && cells[selectedCell.dataset.id]) {
      var v = parseFloat(cells[selectedCell.dataset.id].value);
      if (!isNaN(v)) {
        document.getElementById('status-right').textContent = 'Value: ' + v;
      }
    }
  }

  // Formula bar commit.
  formulaInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && selectedCell) {
      var val = formulaInput.value;
      var id = selectedCell.dataset.id;
      if (val.startsWith('=')) {
        cells[id] = { formula: val, value: evalFormula(val, id), format: 'formula' };
      } else {
        cells[id] = { value: val, format: 'general' };
      }
      selectedCell.textContent = cells[id].value;
      if (sheetId) {
        fetch('/office/sheet/' + sheetId + '/cell', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ cell: id, value: cells[id].value, format: cells[id].format, formula: cells[id].formula || '' })
        });
      }
    }
  });

  // Copy/paste support.
  document.addEventListener('copy', function(e) {
    if (selectedCell) {
      var id = selectedCell.dataset.id;
      e.clipboardData.setData('text/plain', cells[id] ? cells[id].value : '');
      e.preventDefault();
    }
  });

  // Load data from server.
  function loadData() {
    if (!sheetId) { buildGrid(); return; }
    fetch('/office/sheet/' + sheetId + '/data')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (data.cells) cells = data.cells;
        if (data.rows) rows = Math.max(rows, data.rows);
        if (data.cols) cols = Math.max(cols, data.cols);
        buildGrid();
      })
      .catch(function() { buildGrid(); });
  }

  // Export CSV.
  window.exportCSV = function() {
    var lines = [];
    for (var r = 0; r < rows; r++) {
      var row = [];
      for (var c = 0; c < cols; c++) {
        var id = cellId(c, r);
        row.push(cells[id] ? cells[id].value : '');
      }
      lines.push(row.join(','));
    }
    var blob = new Blob([lines.join('\n')], { type: 'text/csv' });
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = (sheetId || 'sheet') + '.csv';
    a.click();
  };

  window.newSheet = function() {
    var name = prompt('Sheet name:');
    if (name) window.location = '/office/sheet/user.sheet.' + name;
  };

  loadData();
})();
"""
}
