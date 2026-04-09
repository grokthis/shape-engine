shape os.render.settings.script {
  type: script
  layer: 4
  deps: os.render.settings.body
  """
(function() {
  var root = document.getElementById('settings-root');
  if (!root) return;

  var themes = {};
  var currentConfig = {};

  // --- DOM helpers ---

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text !== undefined) e.textContent = text;
    return e;
  }

  function settingRow(label, desc) {
    var row = el('div', 'setting-row');
    var info = el('div', 'setting-info');
    info.appendChild(el('div', 'setting-label', label));
    info.appendChild(el('div', 'setting-desc', desc));
    var value = el('div', 'setting-value');
    row.appendChild(info);
    row.appendChild(value);
    return { row: row, value: value };
  }

  function statusSpan(id) {
    var s = el('span', 'status', 'saved');
    s.id = id;
    return s;
  }

  function sectionTitle(text) {
    return el('h2', 'settings-section-title', text);
  }

  // --- Data ---

  function saveConfig(id, value) {
    return fetch('/shape', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({ id: id, character: { dimensions: { type: 'config' }, content: value } })
    });
  }

  function flashStatus(el) {
    el.classList.add('show');
    setTimeout(function() { el.classList.remove('show'); }, 1500);
  }

  fetch('/shapes').then(function(r) { return r.json(); }).then(function(shapes) {
    shapes.forEach(function(s) {
      if (s.id.indexOf('os.theme.') === 0 && s.character && s.character.dimensions && s.character.dimensions.type === 'theme') {
        var name = s.id.replace('os.theme.', '');
        var bg = '#333', fg = '#ccc', accent = '#77f';
        var c = s.character ? s.character.content : '';
        if (c) {
          var m;
          m = c.match(/--bg:\s*([^;]+)/); if (m) bg = m[1].trim();
          m = c.match(/--fg:\s*([^;]+)/); if (m) fg = m[1].trim();
          m = c.match(/--accent:\s*([^;]+)/); if (m) accent = m[1].trim();
        }
        themes[name] = { id: s.id, bg: bg, fg: fg, accent: accent };
      }
      if (s.id.indexOf('os.config.') === 0) {
        currentConfig[s.id] = s.character ? (s.character.content || '') : '';
      }
    });
    render();
  });

  // --- Render ---

  function render() {
    while (root.firstChild) root.removeChild(root.firstChild);

    var activeTheme = currentConfig['os.config.desktop.theme'] || '';
    var activeWM    = currentConfig['os.config.desktop.wm'] || '';
    var background  = currentConfig['os.config.desktop.background'] || '';
    var headers     = currentConfig['os.config.headers'] || 'on';
    var shellHome   = currentConfig['os.config.shell.home'] || 'user';
    var llmKey      = currentConfig['os.config.llm.api_key'] || '';
    var llmModel    = currentConfig['os.config.llm.model'] || 'claude-sonnet-4-20250514';
    var llmMaxTokens = currentConfig['os.config.llm.max_tokens'] || '4096';

    root.appendChild(el('h1', 'settings-title', 'Settings'));

    // --- Theme ---
    root.appendChild(sectionTitle('Theme'));
    var grid = el('div', 'theme-grid');
    Object.keys(themes).sort().forEach(function(name) {
      var t = themes[name];
      var card = el('div', 'theme-card' + (activeTheme === t.id ? ' active' : ''));
      card.dataset.theme = t.id;
      var preview = el('div', 'theme-preview');
      preview.style.background = 'linear-gradient(135deg, ' + t.bg + ' 0%, ' + t.accent + ' 100%)';
      card.appendChild(preview);
      card.appendChild(document.createTextNode(name));
      card.addEventListener('click', function() {
        saveConfig('os.config.desktop.theme', t.id).then(function() {
          currentConfig['os.config.desktop.theme'] = t.id;
          render();
          if (window.parent !== window) window.parent.location.reload();
        });
      });
      grid.appendChild(card);
    });
    root.appendChild(grid);

    // --- Window Manager ---
    root.appendChild(sectionTitle('Window Manager'));
    var wmRow = settingRow('Window Manager', 'How windows are arranged');
    var wmSelect = document.createElement('select');
    wmSelect.id = 'wm-select';
    [['Floating', 'os.wm.floating'], ['Tiling', 'os.wm.tiling']].forEach(function(pair) {
      var opt = document.createElement('option');
      opt.textContent = pair[0];
      opt.value = pair[1];
      if (activeWM === pair[1]) opt.selected = true;
      wmSelect.appendChild(opt);
    });
    var wmStatus = statusSpan('wm-status');
    wmSelect.addEventListener('change', function() {
      var val = wmSelect.value;
      saveConfig('os.config.desktop.wm', val).then(function() {
        currentConfig['os.config.desktop.wm'] = val;
        flashStatus(wmStatus);
        if (window.parent !== window) window.parent.location.reload();
      });
    });
    wmRow.value.appendChild(wmSelect);
    wmRow.value.appendChild(wmStatus);
    root.appendChild(wmRow.row);

    // --- Desktop ---
    root.appendChild(sectionTitle('Desktop'));
    var bgRow = settingRow('Background', 'CSS value (color, gradient, or url())');
    var bgInput = document.createElement('input');
    bgInput.type = 'text';
    bgInput.id = 'bg-input';
    bgInput.value = background;
    bgInput.style.minWidth = '240px';
    var bgStatus = statusSpan('bg-status');
    bgRow.value.appendChild(bgInput);
    bgRow.value.appendChild(bgStatus);
    root.appendChild(bgRow.row);

    // --- Shell ---
    root.appendChild(sectionTitle('Shell'));
    var homeRow = settingRow('Home directory', 'Default prefix on login');
    var homeInput = document.createElement('input');
    homeInput.type = 'text';
    homeInput.id = 'home-input';
    homeInput.value = shellHome;
    var homeStatus = statusSpan('home-status');
    homeRow.value.appendChild(homeInput);
    homeRow.value.appendChild(homeStatus);
    root.appendChild(homeRow.row);

    var headersRow = settingRow('Column headers', 'Show headers in command output tables');
    var headersSelect = document.createElement('select');
    headersSelect.id = 'headers-select';
    [['On', 'on'], ['Off', 'off']].forEach(function(pair) {
      var opt = document.createElement('option');
      opt.textContent = pair[0];
      opt.value = pair[1];
      if (headers === pair[1]) opt.selected = true;
      headersSelect.appendChild(opt);
    });
    var headersStatus = statusSpan('headers-status');
    headersSelect.addEventListener('change', function() {
      var val = headersSelect.value;
      saveConfig('os.config.headers', val).then(function() {
        currentConfig['os.config.headers'] = val;
        flashStatus(headersStatus);
      });
    });
    headersRow.value.appendChild(headersSelect);
    headersRow.value.appendChild(headersStatus);
    root.appendChild(headersRow.row);

    // --- LLM Agent ---
    root.appendChild(sectionTitle('LLM Agent'));

    var llmKeyRow = settingRow('API Key', 'Anthropic API key (or set ANTHROPIC_API_KEY env var)');
    var llmKeyInput = document.createElement('input');
    llmKeyInput.type = 'password';
    llmKeyInput.id = 'llm-key-input';
    llmKeyInput.value = llmKey;
    llmKeyInput.placeholder = 'sk-ant-...';
    llmKeyInput.style.minWidth = '240px';
    var llmKeyStatus = statusSpan('llm-key-status');
    llmKeyRow.value.appendChild(llmKeyInput);
    llmKeyRow.value.appendChild(llmKeyStatus);
    root.appendChild(llmKeyRow.row);

    var llmModelRow = settingRow('Model', 'LLM model identifier');
    var llmModelInput = document.createElement('input');
    llmModelInput.type = 'text';
    llmModelInput.id = 'llm-model-input';
    llmModelInput.value = llmModel;
    llmModelInput.style.minWidth = '240px';
    var llmModelStatus = statusSpan('llm-model-status');
    llmModelRow.value.appendChild(llmModelInput);
    llmModelRow.value.appendChild(llmModelStatus);
    root.appendChild(llmModelRow.row);

    var llmTokensRow = settingRow('Max tokens', 'Maximum response tokens per step');
    var llmTokensInput = document.createElement('input');
    llmTokensInput.type = 'text';
    llmTokensInput.id = 'llm-tokens-input';
    llmTokensInput.value = llmMaxTokens;
    llmTokensInput.style.minWidth = '100px';
    var llmTokensStatus = statusSpan('llm-tokens-status');
    llmTokensRow.value.appendChild(llmTokensInput);
    llmTokensRow.value.appendChild(llmTokensStatus);
    root.appendChild(llmTokensRow.row);

    // --- Keyboard Shortcuts ---
    root.appendChild(sectionTitle('Keyboard Shortcuts'));
    var scRow = settingRow('Shortcut Editor', 'View and remap all keyboard shortcuts');
    var scBtn = el('button', 'settings-btn', 'Open Shortcut Editor');
    scBtn.addEventListener('click', function() {
      if (window.openApp) window.openApp('shortcuts');
    });
    scRow.value.appendChild(scBtn);
    root.appendChild(scRow.row);

    // --- Debounced saves for text inputs ---
    function debouncedSave(input, configKey, status) {
      input.addEventListener('input', debounce(function() {
        saveConfig(configKey, input.value).then(function() {
          currentConfig[configKey] = input.value;
          flashStatus(status);
        });
      }, 500));
    }

    debouncedSave(bgInput,        'os.config.desktop.background', bgStatus);
    debouncedSave(homeInput,       'os.config.shell.home',         homeStatus);
    debouncedSave(llmKeyInput,     'os.config.llm.api_key',        llmKeyStatus);
    debouncedSave(llmModelInput,   'os.config.llm.model',          llmModelStatus);
    debouncedSave(llmTokensInput,  'os.config.llm.max_tokens',     llmTokensStatus);
  }
})();
"""
}
