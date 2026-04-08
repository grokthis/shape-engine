shape os.render.settings.script {
  type: script
  layer: 4
  """
(function() {
  var root = document.getElementById('settings');
  var themes = {};
  var currentConfig = {};

  fetch('/shapes').then(function(r) { return r.json(); }).then(function(shapes) {
    shapes.forEach(function(s) {
      if (s.id.indexOf('os.theme.') === 0 && s.character && s.character.dimensions && s.character.dimensions.type === 'theme') {
        var name = s.id.replace('os.theme.', '');
        var bg = '#333', fg = '#ccc', accent = '#77f';
        var c = s.character ? s.character.content : '';
        if (c) {
          var m;
          m = c.match(/--bg:\s*([^;]+)/);
          if (m) bg = m[1].trim();
          m = c.match(/--fg:\s*([^;]+)/);
          if (m) fg = m[1].trim();
          m = c.match(/--accent:\s*([^;]+)/);
          if (m) accent = m[1].trim();
        }
        themes[name] = { id: s.id, bg: bg, fg: fg, accent: accent };
      }
      if (s.id.indexOf('os.config.') === 0) {
        currentConfig[s.id] = s.character ? (s.character.content || '') : '';
      }
    });
    render();
  });

  function saveConfig(id, value) {
    return fetch('/shape', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        id: id,
        character: {
          dimensions: {type: 'config'},
          content: value
        }
      })
    });
  }

  function flashStatus(el) {
    el.classList.add('show');
    setTimeout(function() { el.classList.remove('show'); }, 1500);
  }

  function render() {
    var activeTheme = currentConfig['os.config.desktop.theme'] || '';
    var activeWM = currentConfig['os.config.desktop.wm'] || '';
    var background = currentConfig['os.config.desktop.background'] || '';
    var headers = currentConfig['os.config.headers'] || 'on';
    var shellHome = currentConfig['os.config.shell.home'] || 'user';

    var html = '<h1>Settings</h1>';

    html += '<h2>Theme</h2>';
    html += '<div class="theme-grid">';
    var themeNames = Object.keys(themes).sort();
    themeNames.forEach(function(name) {
      var t = themes[name];
      var isActive = activeTheme === t.id ? ' active' : '';
      html += '<div class="theme-card' + isActive + '" data-theme="' + t.id + '">';
      html += '<div class="theme-preview" style="background: linear-gradient(135deg, ' + t.bg + ' 0%, ' + t.accent + ' 100%)"></div>';
      html += name;
      html += '</div>';
    });
    html += '</div>';

    html += '<h2>Window Manager</h2>';
    html += '<div class="setting-row">';
    html += '<div><div class="setting-label">Window Manager</div><div class="setting-desc">How windows are arranged</div></div>';
    html += '<div class="setting-value"><select id="wm-select">';
    html += '<option value="os.wm.floating"' + (activeWM === 'os.wm.floating' ? ' selected' : '') + '>Floating</option>';
    html += '<option value="os.wm.tiling"' + (activeWM === 'os.wm.tiling' ? ' selected' : '') + '>Tiling</option>';
    html += '</select><span class="status" id="wm-status">saved</span></div>';
    html += '</div>';

    html += '<h2>Desktop</h2>';
    html += '<div class="setting-row">';
    html += '<div><div class="setting-label">Background</div><div class="setting-desc">CSS value (color, gradient, or url())</div></div>';
    html += '<div class="setting-value"><input type="text" id="bg-input" value="' + background.replace(/"/g, '&quot;') + '" style="min-width:240px">';
    html += '<span class="status" id="bg-status">saved</span></div>';
    html += '</div>';

    html += '<h2>Shell</h2>';
    html += '<div class="setting-row">';
    html += '<div><div class="setting-label">Home directory</div><div class="setting-desc">Default prefix on login</div></div>';
    html += '<div class="setting-value"><input type="text" id="home-input" value="' + shellHome + '">';
    html += '<span class="status" id="home-status">saved</span></div>';
    html += '</div>';

    html += '<div class="setting-row">';
    html += '<div><div class="setting-label">Column headers</div><div class="setting-desc">Show headers in command output tables</div></div>';
    html += '<div class="setting-value"><select id="headers-select">';
    html += '<option value="on"' + (headers === 'on' ? ' selected' : '') + '>On</option>';
    html += '<option value="off"' + (headers === 'off' ? ' selected' : '') + '>Off</option>';
    html += '</select><span class="status" id="headers-status">saved</span></div>';
    html += '</div>';

    // LLM Agent section.
    var llmKey = currentConfig['os.config.llm.api_key'] || '';
    var llmModel = currentConfig['os.config.llm.model'] || 'claude-sonnet-4-20250514';
    var llmProvider = currentConfig['os.config.llm.provider'] || 'anthropic';
    var llmMaxTokens = currentConfig['os.config.llm.max_tokens'] || '4096';

    html += '<h2>LLM Agent</h2>';
    html += '<div class="setting-row">';
    html += '<div><div class="setting-label">API Key</div><div class="setting-desc">Anthropic API key (or set ANTHROPIC_API_KEY env var)</div></div>';
    html += '<div class="setting-value"><input type="password" id="llm-key-input" value="' + llmKey.replace(/"/g, '&quot;') + '" placeholder="sk-ant-..." style="min-width:240px">';
    html += '<span class="status" id="llm-key-status">saved</span></div>';
    html += '</div>';

    html += '<div class="setting-row">';
    html += '<div><div class="setting-label">Model</div><div class="setting-desc">LLM model identifier</div></div>';
    html += '<div class="setting-value"><input type="text" id="llm-model-input" value="' + llmModel + '" style="min-width:240px">';
    html += '<span class="status" id="llm-model-status">saved</span></div>';
    html += '</div>';

    html += '<div class="setting-row">';
    html += '<div><div class="setting-label">Max tokens</div><div class="setting-desc">Maximum response tokens per step</div></div>';
    html += '<div class="setting-value"><input type="text" id="llm-tokens-input" value="' + llmMaxTokens + '" style="min-width:100px">';
    html += '<span class="status" id="llm-tokens-status">saved</span></div>';
    html += '</div>';

    root.innerHTML = html;

    root.querySelectorAll('.theme-card').forEach(function(card) {
      card.addEventListener('click', function() {
        var themeId = this.dataset.theme;
        saveConfig('os.config.desktop.theme', themeId).then(function() {
          currentConfig['os.config.desktop.theme'] = themeId;
          render();
          if (window.parent !== window) window.parent.location.reload();
        });
      });
    });

    document.getElementById('wm-select').addEventListener('change', function() {
      var val = this.value;
      saveConfig('os.config.desktop.wm', val).then(function() {
        currentConfig['os.config.desktop.wm'] = val;
        flashStatus(document.getElementById('wm-status'));
        if (window.parent !== window) window.parent.location.reload();
      });
    });

    // Debounced save for text inputs — fires on paste/type, not just blur.
    var saveTimers = {};
    function debouncedSave(id, configKey, statusEl, delay) {
      var el = document.getElementById(id);
      if (!el) return;
      el.addEventListener('input', function() {
        var val = el.value;
        if (saveTimers[id]) clearTimeout(saveTimers[id]);
        saveTimers[id] = setTimeout(function() {
          saveConfig(configKey, val).then(function() {
            currentConfig[configKey] = val;
            flashStatus(statusEl);
          });
        }, delay || 500);
      });
    }

    debouncedSave('bg-input', 'os.config.desktop.background', document.getElementById('bg-status'));
    debouncedSave('home-input', 'os.config.shell.home', document.getElementById('home-status'));

    document.getElementById('headers-select').addEventListener('change', function() {
      var val = this.value;
      saveConfig('os.config.headers', val).then(function() {
        currentConfig['os.config.headers'] = val;
        flashStatus(document.getElementById('headers-status'));
      });
    });

    // LLM settings.
    debouncedSave('llm-key-input', 'os.config.llm.api_key', document.getElementById('llm-key-status'));
    debouncedSave('llm-model-input', 'os.config.llm.model', document.getElementById('llm-model-status'));
    debouncedSave('llm-tokens-input', 'os.config.llm.max_tokens', document.getElementById('llm-tokens-status'));
  }
})();
"""
}
