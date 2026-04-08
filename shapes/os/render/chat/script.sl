shape os.render.chat.script {
  type: script
  layer: 4
  """
(function() {
  var messages = document.getElementById('chat-messages');
  var input = document.getElementById('chat-input');
  var sendBtn = document.getElementById('chat-send');
  var statusEl = document.getElementById('chat-status');
  var ws = null;
  var sending = false;

  function connect() {
    var proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
    ws = new WebSocket(proto + '//' + location.host + '/ws/chat');

    ws.onopen = function() {
      setStatus('ready', '');
    };

    ws.onmessage = function(e) {
      try {
        var msg = JSON.parse(e.data);
        handleMsg(msg);
      } catch(ex) {
        // Raw text.
        addMessage('agent', e.data);
      }
    };

    ws.onclose = function() {
      setStatus('disconnected', 'error');
      sending = false;
      updateSendBtn();
      setTimeout(connect, 2000);
    };

    ws.onerror = function() { ws.close(); };
  }

  function handleMsg(msg) {
    switch (msg.type) {
      case 'status':
        setStatus(msg.content, 'active');
        if (msg.content === 'connected') {
          // Don't show as message.
        } else {
          removeTyping();
          addTyping();
        }
        break;

      case 'step':
        removeTyping();
        if (msg.content && msg.content.trim()) {
          addStepMessage(msg.step, msg.content);
        }
        addTyping();
        break;

      case 'complete':
        removeTyping();
        sending = false;
        updateSendBtn();
        setStatus('ready', '');
        addMessage('system', msg.content);
        break;

      case 'error':
        removeTyping();
        sending = false;
        updateSendBtn();
        setStatus('error', 'error');
        addMessage('error', msg.content);
        break;

      case 'history':
        // Restore chat history.
        try {
          var hist = JSON.parse(msg.content);
          hist.forEach(function(h) {
            addMessage(h.role, h.text, true);
          });
        } catch(ex) {}
        break;
    }
  }

  function addMessage(role, text, noScroll) {
    var el = document.createElement('div');
    el.className = 'msg ' + role;
    el.textContent = text;
    messages.appendChild(el);
    if (!noScroll) scrollBottom();
  }

  function addStepMessage(step, text) {
    var el = document.createElement('div');
    el.className = 'msg agent';
    var label = document.createElement('div');
    label.className = 'step-label';
    label.textContent = 'Step ' + step;
    el.appendChild(label);
    // Check if text looks like code.
    if (text.indexOf('add_shape') >= 0 || text.indexOf('set_content') >= 0 || text.indexOf('VERIFY') >= 0) {
      var pre = document.createElement('pre');
      pre.textContent = text;
      el.appendChild(pre);
    } else {
      var span = document.createElement('span');
      span.textContent = text;
      el.appendChild(span);
    }
    messages.appendChild(el);
    scrollBottom();
  }

  function addTyping() {
    var el = document.createElement('div');
    el.className = 'typing';
    el.id = 'typing-indicator';
    el.textContent = 'thinking';
    messages.appendChild(el);
    scrollBottom();
  }

  function removeTyping() {
    var el = document.getElementById('typing-indicator');
    if (el) el.remove();
  }

  function setStatus(text, cls) {
    statusEl.textContent = text;
    statusEl.className = cls || '';
  }

  function scrollBottom() {
    messages.scrollTop = messages.scrollHeight;
  }

  function updateSendBtn() {
    sendBtn.disabled = sending;
    input.disabled = sending;
    if (!sending) input.focus();
  }

  function send() {
    var text = input.value.trim();
    if (!text || sending) return;

    addMessage('user', text);
    sending = true;
    updateSendBtn();

    // Save to chat history.
    saveHistory('user', text);

    ws.send(JSON.stringify({type: 'message', content: text}));
    input.value = '';
    autoResize();
  }

  function saveHistory(role, text) {
    // Append to session shape.
    fetch('/api/shape/os.session.chat.history').then(function(r) {
      return r.json();
    }).then(function(shape) {
      var hist = [];
      try { hist = JSON.parse(shape.character.content || '[]'); } catch(ex) {}
      hist.push({role: role, text: text, ts: Date.now()});
      // Keep last 100 messages.
      if (hist.length > 100) hist = hist.slice(-100);
      return fetch('/shape', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          id: 'os.session.chat.history',
          character: {dimensions: {type: 'session'}, content: JSON.stringify(hist)}
        })
      });
    }).catch(function() {});
  }

  // Auto-resize textarea.
  function autoResize() {
    input.style.height = 'auto';
    input.style.height = Math.min(input.scrollHeight, 120) + 'px';
  }

  sendBtn.addEventListener('click', send);
  input.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      send();
    }
  });
  input.addEventListener('input', autoResize);

  connect();
})();
"""
}
