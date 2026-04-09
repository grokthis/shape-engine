shape os.render.terminal.script {
  type: script
  layer: 4
  """
(function() {
  var output = document.getElementById('output');
  var input = document.getElementById('input');
  var promptEl = document.getElementById('prompt');
  var statusLeft = document.getElementById('status-left');
  var history = [];
  var historyIdx = -1;
  var ws = null;
  var currentPrompt = 'shape$ ';
  var firstMessage = true;

  function connect() {
    var proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
    ws = new WebSocket(proto + '//' + location.host + '/ws/terminal');
    firstMessage = true;

    ws.onopen = function() {
      statusLeft.textContent = 'connected';
    };

    ws.onmessage = function(e) {
      var text = e.data;

      if (text.indexOf('__NAV__') === 0) {
        var url = text.substring(7).trim();
        if (url.indexOf('/') === 0) url = location.origin + url;
        window.open(url, '_blank');
        return;
      }

      if (firstMessage && text.length > 100) {
        firstMessage = false;
        appendOutput(text);
        output.scrollTop = output.scrollHeight;
        return;
      }
      firstMessage = false;

      var lines = text.split('\n');
      var last = lines[lines.length - 1];
      if (last.match(/^shape(:.+)?\$ $/)) {
        currentPrompt = last;
        promptEl.textContent = currentPrompt;
        var rest = lines.slice(0, -1).join('\n');
        if (rest) appendOutput(rest + '\n');
      } else if (text.match(/^shape(:.+)?\$ $/)) {
        currentPrompt = text;
        promptEl.textContent = currentPrompt;
      } else {
        appendOutput(text);
      }
      output.scrollTop = output.scrollHeight;
    };

    ws.onclose = function() {
      statusLeft.textContent = 'disconnected';
      appendOutput('\n[disconnected]\n');
    };

    ws.onerror = function() {
      statusLeft.textContent = 'error';
    };
  }

  function appendOutput(text) {
    if (text.indexOf('error:') >= 0) {
      var span = document.createElement('span');
      span.className = 'error';
      span.textContent = text;
      output.appendChild(span);
    } else {
      output.appendChild(document.createTextNode(text));
    }
  }

  input.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      var cmd = input.value;
      input.value = '';
      historyIdx = -1;

      var cmdLine = document.createElement('div');
      var promptSpan = document.createElement('span');
      promptSpan.className = 'prompt';
      promptSpan.textContent = currentPrompt;
      cmdLine.appendChild(promptSpan);
      cmdLine.appendChild(document.createTextNode(cmd));
      output.appendChild(cmdLine);
      output.scrollTop = output.scrollHeight;

      if (cmd.trim()) {
        history.push(cmd);
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(JSON.stringify({type: 'input', data: cmd + '\n'}));
        } else if (window.execShell) {
          // No WebSocket (static/file mode): use the JS engine directly
          var result = window.execShell(cmd);
          if (result) appendOutput(result);
          output.scrollTop = output.scrollHeight;
        }
      } else {
        promptEl.textContent = currentPrompt;
      }

      e.preventDefault();
    } else if (e.key === 'ArrowUp') {
      if (history.length > 0) {
        if (historyIdx < 0) historyIdx = history.length;
        historyIdx--;
        if (historyIdx >= 0) input.value = history[historyIdx];
      }
      e.preventDefault();
    } else if (e.key === 'ArrowDown') {
      if (historyIdx >= 0) {
        historyIdx++;
        if (historyIdx < history.length) {
          input.value = history[historyIdx];
        } else {
          input.value = '';
          historyIdx = -1;
        }
      }
      e.preventDefault();
    } else if (e.key === 'l' && e.ctrlKey) {
      output.innerHTML = '';
      e.preventDefault();
    }
  });

  // Focus terminal input only when clicking inside the terminal's own window.
  var termWin = input.closest('.window') || input.closest('#terminal');
  if (termWin) {
    termWin.addEventListener('click', function(e) {
      // Don't steal focus if clicking another input inside the terminal.
      if (e.target.tagName !== 'INPUT' && e.target.tagName !== 'TEXTAREA') {
        input.focus();
      }
    });
  }

  fetch('/api/shape/os.session.shell.history')
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(sh) {
      if (sh && sh.character && sh.character.content) {
        history = sh.character.content.split('\n').filter(function(l) { return l; });
      }
    })
    .catch(function() {});

  // Only connect WebSocket if there's a server. In static/file mode,
  // use the JS shape engine directly via window.execShell.
  if (window.execShell) {
    statusLeft.textContent = 'local';
  } else {
    connect();
  }
})();
"""
}
