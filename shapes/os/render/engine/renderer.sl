shape os.render.engine.renderer {
  type: script
  layer: 4
  """
// Structural renderer: shapes -> DOM. No HTML strings, no innerHTML for structure.
// Each shape type maps to a DOM pattern. Children render recursively.
//
// Types handled:
//   style  — <style> element with content
//   script — <script> element with content (executes)
//   body   — temporary: innerHTML for HTML blob content (migrate to typed trees)
//   app    — div.app-root, renders children
//   page   — div.page with h1 title
//   section — <section> with h2 title and text content
//   table  — <table> with columns + row data from content
//   callout — div.callout
//   formula — div.formula
//   graph  — <canvas> deferred to requestAnimationFrame
//   html   — div with innerHTML (raw HTML fragment, not a full app body)
//
// Any unrecognized type with children is treated as a transparent container.

function renderShapeToDOM(shapeId, parent) {
  if (!window.shapeClient) return;
  var s = window.shapeClient.getShape(shapeId);
  var type = s ? (s.character.dimensions && s.character.dimensions.type) || '' : '';
  var content = s ? (s.character.content || '') : '';
  var dims = s ? (s.character.dimensions || {}) : {};

  var children = window.shapeClient.getDirectChildren(shapeId);

  switch (type) {
    case 'style': {
      if (!content) return;
      var el = document.createElement('style');
      el.textContent = content;
      parent.appendChild(el);
      return;
    }

    case 'script': {
      if (!content) return;
      var el = document.createElement('script');
      el.textContent = content;
      parent.appendChild(el);
      return;
    }

    case 'body': {
      // Transitional: app body shapes still contain raw HTML.
      // Use <template> to parse without executing scripts, then append
      // nodes directly into parent — no wrapper div that would break CSS layouts.
      if (!content) return;
      var tmpl = document.createElement('template');
      tmpl.innerHTML = content;
      parent.appendChild(tmpl.content.cloneNode(true));
      return;
    }

    case 'html': {
      if (!content) return;
      var el = document.createElement('div');
      el.innerHTML = content;
      parent.appendChild(el);
      return;
    }

    case 'menubar': {
      var el = document.createElement('div');
      el.className = 'menubar';
      parent.appendChild(el);
      var ordered = (content || '').trim().split('\n').map(function(l){return l.trim();}).filter(Boolean);
      (ordered.length > 0 ? ordered.map(function(id){return{id:id};}) : children)
        .forEach(function(cs){ renderShapeToDOM(cs.id, el); });
      return;
    }

    case 'menu': {
      var el = document.createElement('div');
      el.className = 'menu';
      var lbl = document.createElement('span');
      lbl.className = 'menu-label';
      lbl.textContent = dims.label || '';
      el.appendChild(lbl);
      var drop = document.createElement('div');
      drop.className = 'menu-dropdown';
      el.appendChild(drop);
      parent.appendChild(el);
      var ordered = (content || '').trim().split('\n').map(function(l){return l.trim();}).filter(Boolean);
      (ordered.length > 0 ? ordered.map(function(id){return{id:id};}) : children)
        .forEach(function(cs){ renderShapeToDOM(cs.id, drop); });
      return;
    }

    case 'menuitem': {
      var el = document.createElement('div');
      el.className = 'menuitem';
      if (dims.action) el.setAttribute('onclick', dims.action);
      var lbl = document.createElement('span');
      lbl.className = 'menuitem-label';
      lbl.textContent = dims.label || content || '';
      el.appendChild(lbl);
      if (dims.shortcut) {
        var kbd = document.createElement('kbd');
        kbd.className = 'shortcut';
        kbd.textContent = dims.shortcut;
        el.appendChild(kbd);
      }
      parent.appendChild(el);
      return;
    }

    case 'menuseparator': {
      var el = document.createElement('hr');
      el.className = 'menu-sep';
      parent.appendChild(el);
      return;
    }

    case 'toolbar': {
      var el = document.createElement('div');
      el.className = 'doc-toolbar';
      parent.appendChild(el);
      // Content may list ordered child IDs (one per line); otherwise use topo-sorted children.
      var ordered = (content || '').trim().split('\n').map(function(l){return l.trim();}).filter(Boolean);
      if (ordered.length > 0) {
        ordered.forEach(function(id) { renderShapeToDOM(id, el); });
      } else {
        children.forEach(function(cs) { renderShapeToDOM(cs.id, el); });
      }
      return;
    }

    case 'button': {
      var el = document.createElement('button');
      el.textContent = dims.label || content || '';
      if (dims.title) el.title = dims.title;
      if (dims.action) el.setAttribute('onclick', dims.action);
      if (dims.id) el.id = dims.id;
      if (dims.class) el.className = dims.class;
      parent.appendChild(el);
      return;
    }

    case 'select': {
      var el = document.createElement('select');
      if (dims.action) el.setAttribute('onchange', dims.action);
      if (dims.id) el.id = dims.id;
      if (dims.class) el.className = dims.class;
      var defVal = dims.default_value || '';
      var currentGroup = null;
      (content || '').trim().split('\n').forEach(function(line) {
        line = line.trim(); if (!line) return;
        // Lines starting with --- are optgroup headers.
        if (line.slice(0, 3) === '---') {
          currentGroup = document.createElement('optgroup');
          currentGroup.label = line.replace(/^-+\s*|\s*-+$/g, '').trim();
          el.appendChild(currentGroup);
          return;
        }
        var colon = line.indexOf(':');
        var label = colon >= 0 ? line.slice(0, colon).trim() : line;
        var value = colon >= 0 ? line.slice(colon + 1).trim() : line;
        var opt = document.createElement('option');
        opt.value = value; opt.textContent = label;
        if (value === defVal || label === defVal) opt.selected = true;
        (currentGroup || el).appendChild(opt);
      });
      parent.appendChild(el);
      return;
    }

    case 'separator': {
      var el = document.createElement('div');
      el.className = dims.class ? 'separator ' + dims.class : 'separator';
      if (dims.id) el.id = dims.id;
      parent.appendChild(el);
      return;
    }

    case 'editable': {
      var el = document.createElement('div');
      el.className = dims.class || 'doc-page';
      if (dims.id) el.id = dims.id;
      parent.appendChild(el);
      return;
    }

    case 'statusbar': {
      var el = document.createElement('div');
      el.className = 'doc-status';
      var prefix = dims.id || 'doc';
      var left = document.createElement('span');
      left.id = prefix + '-status-left';
      left.textContent = 'Ready';
      var right = document.createElement('span');
      right.id = prefix + '-status-right';
      el.appendChild(left);
      el.appendChild(right);
      parent.appendChild(el);
      return;
    }

    case 'container': {
      var el = document.createElement('div');
      el.className = dims.class || '';
      if (dims.id) el.id = dims.id;
      parent.appendChild(el);
      children.forEach(function(cs) { renderShapeToDOM(cs.id, el); });
      return;
    }

    case 'app': {
      var el = document.createElement('div');
      el.className = dims.class ? 'app-root ' + dims.class : 'app-root';
      if (dims.id) el.id = dims.id;
      parent.appendChild(el);
      children.forEach(function(cs) { renderShapeToDOM(cs.id, el); });
      return;
    }

    case 'page': {
      var el = document.createElement('div');
      el.className = 'page';
      if (dims.title) {
        var h1 = document.createElement('h1');
        h1.textContent = dims.title;
        el.appendChild(h1);
      }
      if (dims.subtitle) {
        var sub = document.createElement('div');
        sub.className = 'subtitle';
        sub.textContent = dims.subtitle;
        el.appendChild(sub);
      }
      parent.appendChild(el);
      children.forEach(function(cs) { renderShapeToDOM(cs.id, el); });
      return;
    }

    case 'section': {
      var el = document.createElement('section');
      if (dims.title) {
        var h2 = document.createElement('h2');
        h2.textContent = dims.title;
        el.appendChild(h2);
      }
      if (content) {
        var p = document.createElement('p');
        p.textContent = content.trim();
        el.appendChild(p);
      }
      parent.appendChild(el);
      children.forEach(function(cs) { renderShapeToDOM(cs.id, el); });
      return;
    }

    case 'table': {
      var el = document.createElement('table');
      var cols = (dims.columns || '').split(',').map(function(c) { return c.trim(); });
      var thead = document.createElement('thead');
      var hr = document.createElement('tr');
      cols.forEach(function(c) {
        var th = document.createElement('th');
        th.textContent = c;
        hr.appendChild(th);
      });
      thead.appendChild(hr);
      el.appendChild(thead);
      var tbody = document.createElement('tbody');
      (content || '').trim().split('\n').forEach(function(line) {
        line = line.trim();
        if (!line) return;
        var tr = document.createElement('tr');
        line.split(',').forEach(function(cell, i) {
          var td = document.createElement('td');
          td.textContent = cell.trim();
          if (i > 0) td.className = 'num';
          tr.appendChild(td);
        });
        tbody.appendChild(tr);
      });
      el.appendChild(tbody);
      parent.appendChild(el);
      return;
    }

    case 'callout': {
      var el = document.createElement('div');
      el.className = 'callout';
      el.textContent = content.trim();
      parent.appendChild(el);
      return;
    }

    case 'formula': {
      var el = document.createElement('div');
      el.className = 'formula';
      el.textContent = content.trim();
      parent.appendChild(el);
      return;
    }

    case 'graph': {
      var el = document.createElement('div');
      el.className = 'graph-container';
      var canvas = document.createElement('canvas');
      canvas.id = 'graph-' + shapeId.split('.').pop();
      canvas.style.width = '100%';
      canvas.style.height = '400px';
      el.appendChild(canvas);
      parent.appendChild(el);
      // Deferred graph render
      if (typeof renderGraph === 'function') {
        requestAnimationFrame(function() { renderGraph(canvas, s); });
      }
      return;
    }

    default: {
      // Unknown type: if shape has no content and has children,
      // treat as transparent container and render children into parent.
      if (children.length > 0) {
        children.forEach(function(cs) { renderShapeToDOM(cs.id, parent); });
      }
      return;
    }
  }
}

// Render all [data-shape] containers on the page.
// Called after shape data is loaded.
function renderAllShapes() {
  document.querySelectorAll('[data-shape]').forEach(function(el) {
    var shapeId = el.dataset.shape;
    if (shapeId) renderShapeToDOM(shapeId, el);
  });
}
"""
}
