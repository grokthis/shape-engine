// Command shape is the shape engine.
// One binary. One shape file. Native window. Instant startup.
// Every interaction saved. You never lose anything.
//
// Usage:
//
//	shape                        # desktop mode, native window
//	shape my.shape               # load existing shape file
//	shape -demo                  # demo shapes
//	shape -web                   # serve as HTTP only (no window)
//	shape -shell                 # terminal-only mode (no window)
//	shape -desktop               # desktop mode (default with window)
package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"io/fs"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"sync"
	"syscall"
	"time"

	"github.com/ashbuilds/shape-engine/pkg/engine"
	"github.com/ashbuilds/shape-engine/pkg/lang"
	"github.com/ashbuilds/shape-engine/pkg/llm"
	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/store"
	"github.com/ashbuilds/shape-engine/pkg/transform"
	"github.com/ashbuilds/shape-engine/pkg/window"
	"github.com/ashbuilds/shape-engine/shapes"
)

// eventHub broadcasts shape mutations to connected WebSocket clients.
type eventHub struct {
	mu      sync.RWMutex
	clients map[*eventClient]bool
}

type eventClient struct {
	bufrw  *bufio.ReadWriter
	filter string
	done   chan struct{}
}

func newEventHub() *eventHub {
	return &eventHub{clients: make(map[*eventClient]bool)}
}

func (h *eventHub) add(c *eventClient) {
	h.mu.Lock()
	h.clients[c] = true
	h.mu.Unlock()
}

func (h *eventHub) remove(c *eventClient) {
	h.mu.Lock()
	delete(h.clients, c)
	h.mu.Unlock()
}

func (h *eventHub) broadcast(evt map[string]interface{}) {
	data, err := json.Marshal(evt)
	if err != nil {
		return
	}
	msg := string(data)

	h.mu.RLock()
	defer h.mu.RUnlock()

	for c := range h.clients {
		filter := c.filter
		shapeID, _ := evt["shape"].(string)
		if filter != "" && !strings.HasPrefix(shapeID, filter) {
			continue
		}
		go func(client *eventClient) {
			select {
			case <-client.done:
				return
			default:
				sendWSText(client.bufrw, msg)
			}
		}(c)
	}
}

func main() {
	web := flag.Bool("web", false, "HTTP server only, no native window")
	shellMode := flag.Bool("shell", false, "interactive shell, no window")
	addr := flag.String("addr", ":0", "listen address (default: random port)")
	flag.Parse()

	// Determine shape file path.
	shapePath := defaultShapePath()
	if flag.NArg() > 0 {
		shapePath = flag.Arg(0)
	}

	// Boot engine.
	eng := engine.New()

	// Register agent transform: shapes with fn=agent.exec fire their
	// content as shape-lang when a dependency changes.
	agentTx := &transform.AgentTransform{
		Eval: func(source string, content string, _ interface{}) (string, error) {
			prog, err := lang.Parse(content)
			if err != nil {
				return "", err
			}
			scope := map[string]string{"source": source}
			return lang.EvalWithScope(prog, eng, "", scope)
		},
	}
	eng.RegisterTransform(agentTx)

	// Register test transform: shapes with fn=shape.Test auto-run their
	// content as shape-lang when a dependency changes. Test results are
	// recorded as constraints on the shape itself.
	testTx := &transform.TestTransform{
		Eval: func(source string, content string) (string, error) {
			prog, err := lang.Parse(content)
			if err != nil {
				return "", err
			}
			return lang.Eval(prog, eng, "")
		},
	}
	eng.RegisterTransform(testTx)

	shapeStore := store.NewBinaryStore(shapePath)

	// Load existing state.
	tick, loadedShapes, err := shapeStore.Load()
	if err != nil {
		log.Fatalf("loading %s: %v", shapePath, err)
	}
	if len(loadedShapes) > 0 {
		for _, s := range loadedShapes {
			eng.AddShape(s)
		}
		eng.SetTick(tick)
		fmt.Printf("%d shapes loaded (tick %d)\n", len(loadedShapes), tick)
	}

	// Bootstrap: load os/ shapes if the graph doesn't have the system yet.
	if _, ok := eng.GetShape("law"); !ok {
		bootOS(eng)
	}

	// Wire LLM client. Reads API key from shape config, then env var.
	// The adapter reads live config on every call so Settings changes
	// take effect immediately without restart.
	llmAPIKey := ""
	if s, ok := eng.GetShape("os.config.llm.api_key"); ok && s.Character.Content != "" {
		llmAPIKey = s.Character.Content
	}
	llmModel := ""
	if s, ok := eng.GetShape("os.config.llm.model"); ok && s.Character.Content != "" {
		llmModel = s.Character.Content
	}
	llmClient := llm.NewClient(llmAPIKey, llmModel)
	eng.SetExt("llm", llm.NewAdapter(llmClient, func() (string, string, int) {
		key := ""
		if s, ok := eng.GetShape("os.config.llm.api_key"); ok {
			key = s.Character.Content
		}
		model := ""
		if s, ok := eng.GetShape("os.config.llm.model"); ok {
			model = s.Character.Content
		}
		maxToks := 0
		if s, ok := eng.GetShape("os.config.llm.max_tokens"); ok && s.Character.Content != "" {
			fmt.Sscanf(s.Character.Content, "%d", &maxToks)
		}
		return key, model, maxToks
	}))

	// Auto-persist: every mutation saves to disk.
	// Debounced: coalesces rapid mutations (e.g. desktop bootstrap)
	// into a single write. At most one save per 50ms.
	saver := newDebouncedSaver(shapeStore, eng, 50*time.Millisecond)
	eng.OnMutate(saver.trigger)

	// Flush on shutdown so nothing is lost.
	go func() {
		sigCh := make(chan os.Signal, 1)
		signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
		<-sigCh
		saver.sync()
		signal.Reset()
		syscall.Kill(syscall.Getpid(), syscall.SIGINT)
	}()

	// Save initial state.
	saveState(shapeStore, eng)

	// Shell mode: interactive REPL, no GUI.
	if *shellMode {
		fmt.Printf("shape shell (%d shapes, tick %d)\n", len(eng.Shapes()), eng.Tick())
		fmt.Println("type 'help' for commands")

		scanner := bufio.NewScanner(os.Stdin)
		fmt.Print(shellPrompt(eng))
		for scanner.Scan() {
			line := scanner.Text()
			output := execShellLine(eng, line)
			if output != "" {
				output = handleNavMarkers(output)
				if output != "" {
					fmt.Print(output)
				}
			}
			fmt.Print(shellPrompt(eng))
		}
		saver.sync()
		return
	}

	// Start HTTP server.
	if *addr == ":0" {
		*addr = ":0"
	}
	listener, err := net.Listen("tcp", *addr)
	if err != nil {
		log.Fatalf("listen: %v", err)
	}
	port := listener.Addr().(*net.TCPAddr).Port
	url := fmt.Sprintf("http://localhost:%d", port)

	hub := newEventHub()

	// Wire event broadcast: engine mutations push to connected browser clients.
	origMutate := saver.trigger
	eng.OnMutate(func() {
		origMutate()
		hub.broadcast(map[string]interface{}{
			"type":  "mutate",
			"shape": "",
			"actor": eng.Actor(),
			"tick":  eng.Tick(),
		})
	})

	mux := http.NewServeMux()

	// WebSocket endpoints (raw TCP — substrate).
	mux.HandleFunc("/ws/terminal", func(w http.ResponseWriter, r *http.Request) {
		handleWSTerminal(eng, w, r)
	})
	mux.HandleFunc("/ws/events", func(w http.ResponseWriter, r *http.Request) {
		handleWSEvents(eng, hub, w, r)
	})
	mux.HandleFunc("/ws/chat", func(w http.ResponseWriter, r *http.Request) {
		handleWSChat(eng, w, r)
	})

	// All other requests dispatched through shape-lang route handlers.
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		handleHTTP(eng, w, r)
	})

	fmt.Printf("shape %s\n", url)
	fmt.Printf("  file:   %s\n", shapePath)
	fmt.Printf("  shapes: %d\n", len(eng.Shapes()))

	if *web {
		fmt.Println("  mode:   web (no native window)")
		if err := http.Serve(listener, mux); err != nil {
			log.Fatal(err)
		}
		return
	}

	// Start server in background.
	go func() {
		if err := http.Serve(listener, mux); err != nil {
			log.Printf("server: %v", err)
		}
	}()

	// Read window config from shapes.
	windowTitle := "Shape OS"
	windowWidth := 1400
	windowHeight := 900
	fullscreen := true
	if sh, ok := eng.GetShape("os.config.window.title"); ok && sh.Character.Content != "" {
		windowTitle = sh.Character.Content
	}
	if sh, ok := eng.GetShape("os.config.window.fullscreen"); ok {
		fullscreen = sh.Character.Content != "off"
	}

	desktopRoute := "/desktop"
	if sh, ok := eng.GetShape("os.config.desktop.route"); ok && sh.Character.Content != "" {
		desktopRoute = sh.Character.Content
	}

	window.Open(url+desktopRoute, windowTitle, windowWidth, windowHeight, fullscreen)
}

// handleHTTP dispatches HTTP requests to shape-lang route handlers.
func handleHTTP(eng *engine.Engine, w http.ResponseWriter, r *http.Request) {
	route := findRoute(eng, r.Method, r.URL.Path)
	if route == nil {
		http.NotFound(w, r)
		return
	}

	// Build scope from route dims + request.
	scope := make(map[string]string)
	for k, v := range route.Character.Dimensions {
		scope[k] = v
	}
	scope["method"] = r.Method
	scope["path"] = r.URL.Path
	scope["query"] = r.URL.RawQuery
	for k, v := range r.URL.Query() {
		if len(v) > 0 {
			scope["q_"+k] = v[0]
		}
	}
	extractPathParams(route.Character.Dimensions["path"], r.URL.Path, scope)
	if r.Method == "POST" || r.Method == "PUT" || r.Method == "DELETE" {
		body, _ := io.ReadAll(io.LimitReader(r.Body, 1<<20))
		scope["body"] = string(body)
	}

	handlerID := route.Character.Dimensions["handler"]
	if handlerID == "" {
		http.Error(w, "route has no handler", 500)
		return
	}
	handler, ok := eng.GetShape(shape.ID(handlerID))
	if !ok {
		http.Error(w, "handler not found: "+handlerID, 500)
		return
	}

	prog, err := lang.Parse(handler.Character.Content)
	if err != nil {
		http.Error(w, "handler parse error: "+err.Error(), 500)
		return
	}

	out, err := lang.EvalWithScope(prog, eng, "", scope)
	if err != nil {
		http.Error(w, "handler error: "+err.Error(), 500)
		return
	}

	ct := route.Character.Dimensions["content_type"]
	if ct == "" {
		ct = "text/html; charset=utf-8"
	}
	w.Header().Set("Content-Type", ct)
	w.Write([]byte(out))
}

// findRoute finds the best matching route shape for the given method and path.
// Exact matches take priority; pattern matches are ranked by specificity.
func findRoute(eng *engine.Engine, method, path string) *shape.Shape {
	var bestRoute *shape.Shape
	var bestLen int

	for _, s := range eng.Shapes() {
		if s.Character.Dimensions["type"] != "route" {
			continue
		}
		routeMethod := s.Character.Dimensions["method"]
		if routeMethod != "" && !strings.EqualFold(routeMethod, method) {
			continue
		}
		routePath := s.Character.Dimensions["path"]
		if routePath == path {
			return s // exact match wins immediately
		}
		if matchPattern(routePath, path) {
			patternLen := len(strings.Split(routePath, "/"))
			if patternLen > bestLen {
				bestRoute = s
				bestLen = patternLen
			}
		}
	}
	return bestRoute
}

// matchPattern returns true if path matches the URL pattern.
// Patterns use {param} for single segments and {param...} for catch-all.
func matchPattern(pattern, path string) bool {
	if pattern == "" {
		return false
	}
	patParts := strings.Split(pattern, "/")
	pathParts := strings.Split(path, "/")

	for i, pp := range patParts {
		isCatchAll := strings.HasPrefix(pp, "{") && strings.HasSuffix(pp, "...}") ||
			strings.HasPrefix(pp, "{") && strings.HasSuffix(pp, "...}")
		if isCatchAll {
			// Matches everything remaining.
			return i < len(pathParts)
		}
		if i >= len(pathParts) {
			return false
		}
		isParam := strings.HasPrefix(pp, "{") && strings.HasSuffix(pp, "}")
		if !isParam && pp != pathParts[i] {
			return false
		}
	}
	return len(patParts) == len(pathParts)
}

// extractPathParams extracts named path parameters from a URL pattern into scope.
// /api/shape/{id} + /api/shape/law.persistence -> scope["path_id"] = "law.persistence"
// /office/{rest...} + /office/a/b -> scope["path_rest"] = "a/b"
func extractPathParams(pattern, path string, scope map[string]string) {
	if pattern == "" {
		return
	}
	patParts := strings.Split(pattern, "/")
	pathParts := strings.Split(path, "/")

	for i, pp := range patParts {
		if i >= len(pathParts) {
			break
		}
		if strings.HasPrefix(pp, "{") && strings.HasSuffix(pp, "...}") {
			name := pp[1 : len(pp)-4] // strip { and ...}
			if i < len(pathParts) {
				scope["path_"+name] = strings.Join(pathParts[i:], "/")
			}
			return
		}
		if strings.HasPrefix(pp, "{") && strings.HasSuffix(pp, "}") {
			name := pp[1 : len(pp)-1] // strip { and }
			scope["path_"+name] = pathParts[i]
		}
	}
}

// execShellLine executes a shell line via shape-lang.
// First word = command; looks for os.shell.cmd.{command} shape with type=exec.
// Falls back to raw shape-lang eval.
func execShellLine(eng *engine.Engine, line string) string {
	line = strings.TrimSpace(line)
	if line == "" {
		return ""
	}

	// Handle pipes: cmd1 | cmd2 | cmd3
	if strings.Contains(line, " | ") {
		segments := strings.Split(line, " | ")
		var output string
		for _, seg := range segments {
			seg = strings.TrimSpace(seg)
			if output != "" {
				// Pipe: prepend previous output as piped_input.
				seg = seg + " " + output
			}
			output = execShellLine(eng, seg)
		}
		return output
	}

	parts := strings.Fields(line)
	cmd := parts[0]
	argList := parts[1:]

	// Shell prefix (working directory).
	prefix := ""
	if sh, ok := eng.GetShape("os.session.shell.prefix"); ok {
		prefix = sh.Character.Content
	}
	home := ""
	if sh, ok := eng.GetShape("os.config.shell.home"); ok {
		home = sh.Character.Content
	}

	cmdShape, ok := eng.GetShape(shape.ID("os.shell.cmd." + cmd))
	if ok && cmdShape.Character.Dimensions["type"] == "exec" {
		scope := map[string]string{
			"args":   strings.Join(argList, " "),
			"line":   line,
			"cmd":    cmd,
			"prefix": prefix,
			"home":   home,
		}
		for i, a := range argList {
			scope[fmt.Sprintf("arg%d", i)] = a
		}
		prog, err := lang.Parse(cmdShape.Character.Content)
		if err != nil {
			return "parse error: " + err.Error() + "\n"
		}
		out, err := lang.EvalWithScope(prog, eng, "", scope)
		if err != nil {
			return "error: " + err.Error() + "\n"
		}
		return out
	}

	// Fall back to raw shape-lang eval.
	prog, err := lang.Parse(line)
	if err != nil {
		return "error: " + err.Error() + "\n"
	}
	out, err := lang.Eval(prog, eng, "")
	if err != nil {
		return "error: " + err.Error() + "\n"
	}
	return out
}

// shellPrompt returns the shell prompt string.
func shellPrompt(eng *engine.Engine) string {
	if sh, ok := eng.GetShape("os.shell.prompt"); ok && sh.Character.Content != "" {
		return sh.Character.Content
	}
	return "shape$ "
}

// handleWSTerminal serves the WebSocket terminal connection.
func handleWSTerminal(eng *engine.Engine, w http.ResponseWriter, r *http.Request) {
	if !strings.EqualFold(r.Header.Get("Upgrade"), "websocket") {
		http.Error(w, "expected websocket upgrade", http.StatusBadRequest)
		return
	}

	hj, ok := w.(http.Hijacker)
	if !ok {
		http.Error(w, "server doesn't support hijacking", http.StatusInternalServerError)
		return
	}

	key := r.Header.Get("Sec-WebSocket-Key")
	if key == "" {
		http.Error(w, "missing Sec-WebSocket-Key", http.StatusBadRequest)
		return
	}
	acceptKey := computeAcceptKey(key)

	conn, bufrw, err := hj.Hijack()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer conn.Close()

	bufrw.WriteString("HTTP/1.1 101 Switching Protocols\r\n")
	bufrw.WriteString("Upgrade: websocket\r\n")
	bufrw.WriteString("Connection: Upgrade\r\n")
	bufrw.WriteString("Sec-WebSocket-Accept: " + acceptKey + "\r\n")
	bufrw.WriteString("\r\n")
	bufrw.Flush()

	// Restore scrollback from session shape.
	if sb, ok := eng.GetShape("os.session.shell.scrollback"); ok && sb.Character.Content != "" {
		sendWSText(bufrw, sb.Character.Content)
	}

	// Send initial prompt.
	sendWSText(bufrw, shellPrompt(eng))

	// Scrollback buffer for persistence.
	var scrollback strings.Builder
	if sb, ok := eng.GetShape("os.session.shell.scrollback"); ok && sb.Character.Content != "" {
		scrollback.WriteString(sb.Character.Content)
	}
	const maxScrollback = 64 * 1024

	saveScrollback := func() {
		content := scrollback.String()
		if len(content) > maxScrollback {
			content = content[len(content)-maxScrollback:]
			if i := strings.Index(content, "\n"); i >= 0 {
				content = content[i+1:]
			}
		}
		eng.AddShape(&shape.Shape{
			ID: "os.session.shell.scrollback",
			Character: shape.Character{
				Dimensions: map[string]string{"type": "session"},
				Content:    content,
			},
		})
	}

	// Read loop.
	for {
		payload, err := readWSFrame(bufrw.Reader)
		if err != nil {
			saveScrollback()
			return
		}

		var msg struct {
			Type string `json:"type"`
			Data string `json:"data"`
		}
		if err := json.Unmarshal(payload, &msg); err != nil {
			msg.Type = "input"
			msg.Data = string(payload)
		}

		if msg.Type != "input" {
			continue
		}

		input := strings.TrimRight(msg.Data, "\r\n")
		lines := strings.Split(input, "\n")

		for _, line := range lines {
			line = strings.TrimSpace(line)
			if line == "" {
				sendWSText(bufrw, shellPrompt(eng))
				continue
			}

			// Record command in scrollback.
			scrollback.WriteString(shellPrompt(eng))
			scrollback.WriteString(line)
			scrollback.WriteByte('\n')

			output := execShellLine(eng, line)
			if output != "" {
				clean, navURLs := extractNavMarkers(output)
				for _, u := range navURLs {
					sendWSText(bufrw, "__NAV__"+u)
				}
				if clean != "" {
					sendWSText(bufrw, clean)
					scrollback.WriteString(clean)
				}
			}

			sendWSText(bufrw, shellPrompt(eng))
			saveScrollback()
		}
	}
}

// handleWSEvents serves the WebSocket event stream.
func handleWSEvents(eng *engine.Engine, hub *eventHub, w http.ResponseWriter, r *http.Request) {
	if !strings.EqualFold(r.Header.Get("Upgrade"), "websocket") {
		http.Error(w, "expected websocket upgrade", http.StatusBadRequest)
		return
	}

	hj, ok := w.(http.Hijacker)
	if !ok {
		http.Error(w, "server doesn't support hijacking", http.StatusInternalServerError)
		return
	}

	key := r.Header.Get("Sec-WebSocket-Key")
	if key == "" {
		http.Error(w, "missing Sec-WebSocket-Key", http.StatusBadRequest)
		return
	}
	acceptKey := computeAcceptKey(key)

	conn, bufrw, err := hj.Hijack()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer conn.Close()

	bufrw.WriteString("HTTP/1.1 101 Switching Protocols\r\n")
	bufrw.WriteString("Upgrade: websocket\r\n")
	bufrw.WriteString("Connection: Upgrade\r\n")
	bufrw.WriteString("Sec-WebSocket-Accept: " + acceptKey + "\r\n")
	bufrw.WriteString("\r\n")
	bufrw.Flush()

	filter := r.URL.Query().Get("filter")

	client := &eventClient{
		bufrw:  bufrw,
		filter: filter,
		done:   make(chan struct{}),
	}

	hub.add(client)
	defer func() {
		close(client.done)
		hub.remove(client)
	}()

	// Send initial connected event.
	hello := fmt.Sprintf(`{"type":"connected","shape":"","tick":%d}`, eng.Tick())
	sendWSText(bufrw, hello)

	// Keep connection alive: read frames (client can send filter updates).
	for {
		payload, err := readWSFrame(bufrw.Reader)
		if err != nil {
			return
		}

		var msg struct {
			Filter string `json:"filter"`
		}
		if json.Unmarshal(payload, &msg) == nil && msg.Filter != "" {
			client.filter = msg.Filter
		}
	}
}

// handleWSChat serves the WebSocket chat/LLM agent connection.
func handleWSChat(eng *engine.Engine, w http.ResponseWriter, r *http.Request) {
	if !strings.EqualFold(r.Header.Get("Upgrade"), "websocket") {
		http.Error(w, "expected websocket upgrade", http.StatusBadRequest)
		return
	}

	hj, ok := w.(http.Hijacker)
	if !ok {
		http.Error(w, "server doesn't support hijacking", http.StatusInternalServerError)
		return
	}

	key := r.Header.Get("Sec-WebSocket-Key")
	if key == "" {
		http.Error(w, "missing Sec-WebSocket-Key", http.StatusBadRequest)
		return
	}
	acceptKey := computeAcceptKey(key)

	conn, bufrw, err := hj.Hijack()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer conn.Close()

	bufrw.WriteString("HTTP/1.1 101 Switching Protocols\r\n")
	bufrw.WriteString("Upgrade: websocket\r\n")
	bufrw.WriteString("Connection: Upgrade\r\n")
	bufrw.WriteString("Sec-WebSocket-Accept: " + acceptKey + "\r\n")
	bufrw.WriteString("\r\n")
	bufrw.Flush()

	sendWSJSON(bufrw, map[string]string{"type": "status", "content": "connected"})

	// Restore chat history.
	if hist, ok := eng.GetShape("os.session.chat.history"); ok && hist.Character.Content != "" {
		sendWSJSON(bufrw, map[string]string{"type": "history", "content": hist.Character.Content})
	}

	for {
		payload, err := readWSFrame(bufrw.Reader)
		if err != nil {
			return
		}

		var msg struct {
			Type    string `json:"type"`
			Content string `json:"content"`
		}
		if err := json.Unmarshal(payload, &msg); err != nil {
			msg.Type = "message"
			msg.Content = string(payload)
		}

		if msg.Type != "message" || strings.TrimSpace(msg.Content) == "" {
			continue
		}

		goal := strings.TrimSpace(msg.Content)

		ext, hasLLM := eng.GetExt("llm")
		type readyChecker interface{ Ready() bool }
		if !hasLLM {
			sendWSJSON(bufrw, map[string]string{"type": "error", "content": "LLM not configured. Go to Settings to add your API key."})
			continue
		}
		if rc, ok := ext.(readyChecker); ok && !rc.Ready() {
			sendWSJSON(bufrw, map[string]string{"type": "error", "content": "No API key. Go to Settings > LLM Agent to configure."})
			continue
		}

		runChatAgent(eng, bufrw, goal)
	}
}

// runChatAgent runs the LLM agent loop, streaming step output to the client.
func runChatAgent(eng *engine.Engine, bufrw *bufio.ReadWriter, goal string) {
	tick := eng.Tick()
	taskID := fmt.Sprintf("os.agent.llm.task.%d", tick)

	eng.AddShape(&shape.Shape{
		ID: shape.ID(taskID),
		Character: shape.Character{
			Dimensions: map[string]string{
				"type":   "agent-task",
				"goal":   goal,
				"status": "running",
				"step":   "0",
			},
		},
		Structure: shape.Structure{
			Emergence: shape.Emergence{Layer: 4},
		},
	})

	sendWSJSON(bufrw, map[string]interface{}{"type": "status", "content": "thinking...", "task_id": taskID})

	systemPrompt := ""
	if p, ok := eng.GetShape("os.agent.llm.prompt"); ok {
		systemPrompt = p.Character.Content
	}
	if systemPrompt == "" {
		sendWSJSON(bufrw, map[string]interface{}{"type": "error", "content": "No agent prompt configured (os.agent.llm.prompt is empty)", "task_id": taskID})
		return
	}

	ext, _ := eng.GetExt("llm")
	type directCaller interface {
		Call(system, context string) (string, string, int, int, error)
	}
	dc, ok := ext.(directCaller)
	if !ok {
		sendWSJSON(bufrw, map[string]interface{}{"type": "error", "content": "LLM caller not available", "task_id": taskID})
		return
	}

	maxSteps := 10
	if cfg, ok := eng.GetShape("os.agent.llm.config"); ok {
		if ms := cfg.Character.Dimensions["max_steps"]; ms != "" {
			fmt.Sscanf(ms, "%d", &maxSteps)
		}
	}

	ctx := fmt.Sprintf("Task ID: %s\nGoal: %s\nEngine: %d shapes, tick %d\nBegin. This is step 1.",
		taskID, goal, len(eng.Shapes()), eng.Tick())

	eng.Edit(shape.ID(taskID), ctx)

	for step := 1; step <= maxSteps; step++ {
		sendWSJSON(bufrw, map[string]interface{}{
			"type":    "status",
			"content": fmt.Sprintf("step %d...", step),
			"task_id": taskID,
			"step":    step,
		})

		content, _, inToks, outToks, err := dc.Call(systemPrompt, ctx)
		if err != nil {
			sendWSJSON(bufrw, map[string]interface{}{
				"type":    "error",
				"content": fmt.Sprintf("LLM error: %s", err),
				"task_id": taskID,
				"step":    step,
			})
			chatSetDim(eng, taskID, "status", "error")
			return
		}

		code := extractShapeLang(content)

		stepID := fmt.Sprintf("%s.step.%d", taskID, step)
		eng.AddShape(&shape.Shape{
			ID: shape.ID(stepID),
			Character: shape.Character{
				Dimensions: map[string]string{
					"type":        "agent-step",
					"step":        fmt.Sprintf("%d", step),
					"input_toks":  fmt.Sprintf("%d", inToks),
					"output_toks": fmt.Sprintf("%d", outToks),
				},
				Content: code,
			},
			Structure: shape.Structure{
				Transformation: shape.Transformation{Deps: []shape.ID{shape.ID(taskID)}},
				Emergence:      shape.Emergence{Layer: 4},
			},
		})

		var evalOutput string
		prog, parseErr := lang.Parse(code)
		if parseErr != nil {
			evalOutput = "Parse error: " + parseErr.Error()
		} else {
			out, evalErr := lang.Eval(prog, eng, "")
			if evalErr != nil {
				evalOutput = "Eval error: " + evalErr.Error()
			} else {
				evalOutput = out
			}
		}

		chatSetDim(eng, taskID, "step", fmt.Sprintf("%d", step))

		sendWSJSON(bufrw, map[string]interface{}{
			"type":    "step",
			"content": evalOutput,
			"task_id": taskID,
			"step":    step,
		})

		task, ok := eng.GetShape(shape.ID(taskID))
		if !ok {
			break
		}
		status := task.Character.Dimensions["status"]
		if status == "complete" {
			sendWSJSON(bufrw, map[string]interface{}{
				"type":    "complete",
				"content": fmt.Sprintf("Done in %d steps.", step),
				"task_id": taskID,
				"step":    step,
			})
			return
		}
		if status == "blocked" || status == "error" {
			sendWSJSON(bufrw, map[string]interface{}{
				"type":    "error",
				"content": fmt.Sprintf("Task %s at step %d.", status, step),
				"task_id": taskID,
				"step":    step,
			})
			return
		}

		task, _ = eng.GetShape(shape.ID(taskID))
		ctx = task.Character.Content
		if ctx == "" {
			n := len(evalOutput)
			if n > 500 {
				n = 500
			}
			ctx = fmt.Sprintf("Step %d complete. Output: %s\nContinue.", step, evalOutput[:n])
		}

		time.Sleep(100 * time.Millisecond)
	}

	chatSetDim(eng, taskID, "status", "max-steps")
	sendWSJSON(bufrw, map[string]interface{}{
		"type":    "complete",
		"content": fmt.Sprintf("Reached max steps (%d).", maxSteps),
		"task_id": taskID,
	})
}

func chatSetDim(eng *engine.Engine, taskID, key, val string) {
	if s, ok := eng.GetShape(shape.ID(taskID)); ok {
		if s.Character.Dimensions == nil {
			s.Character.Dimensions = make(map[string]string)
		}
		s.Character.Dimensions[key] = val
		eng.AddShape(s)
	}
}

// extractShapeLang strips code fences from LLM output.
func extractShapeLang(s string) string {
	markers := []string{"```shape-lang", "```sl", "```shapelang", "```"}
	for _, marker := range markers {
		start := strings.Index(s, marker)
		if start < 0 {
			continue
		}
		after := s[start+len(marker):]
		nl := strings.Index(after, "\n")
		if nl < 0 {
			continue
		}
		after = after[nl+1:]
		end := strings.Index(after, "```")
		if end < 0 {
			return after
		}
		return after[:end]
	}
	return s
}

// sendWSJSON sends a JSON-encoded WebSocket text frame.
func sendWSJSON(bufrw *bufio.ReadWriter, v interface{}) {
	data, err := json.Marshal(v)
	if err != nil {
		return
	}
	sendWSText(bufrw, string(data))
}

// sendWSText sends a text WebSocket frame.
func sendWSText(bufrw *bufio.ReadWriter, text string) {
	data := []byte(text)
	bufrw.WriteByte(0x81) // FIN + text opcode
	length := len(data)
	if length < 126 {
		bufrw.WriteByte(byte(length))
	} else if length < 65536 {
		bufrw.WriteByte(126)
		bufrw.WriteByte(byte(length >> 8))
		bufrw.WriteByte(byte(length))
	} else {
		bufrw.WriteByte(127)
		for i := 7; i >= 0; i-- {
			bufrw.WriteByte(byte(length >> (i * 8)))
		}
	}
	bufrw.Write(data)
	bufrw.Flush()
}

// readWSFrame reads one WebSocket frame and returns the payload.
func readWSFrame(r *bufio.Reader) ([]byte, error) {
	b1, err := r.ReadByte()
	if err != nil {
		return nil, err
	}
	b2, err := r.ReadByte()
	if err != nil {
		return nil, err
	}

	opcode := b1 & 0x0F
	masked := b2&0x80 != 0
	length := int(b2 & 0x7F)

	if opcode == 0x08 {
		return nil, io.EOF
	}

	if length == 126 {
		buf := make([]byte, 2)
		if _, err := io.ReadFull(r, buf); err != nil {
			return nil, err
		}
		length = int(buf[0])<<8 | int(buf[1])
	} else if length == 127 {
		buf := make([]byte, 8)
		if _, err := io.ReadFull(r, buf); err != nil {
			return nil, err
		}
		length = 0
		for i := 0; i < 8; i++ {
			length = length<<8 | int(buf[i])
		}
	}

	var mask [4]byte
	if masked {
		if _, err := io.ReadFull(r, mask[:]); err != nil {
			return nil, err
		}
	}

	payload := make([]byte, length)
	if _, err := io.ReadFull(r, payload); err != nil {
		return nil, err
	}

	if masked {
		for i := range payload {
			payload[i] ^= mask[i%4]
		}
	}

	return payload, nil
}

// extractNavMarkers splits output into clean text and navigate URLs.
func extractNavMarkers(output string) (clean string, urls []string) {
	const marker = "\x00NAV:"
	for {
		i := strings.Index(output, marker)
		if i < 0 {
			break
		}
		clean += output[:i]
		rest := output[i+len(marker):]
		nl := strings.Index(rest, "\n")
		if nl < 0 {
			urls = append(urls, rest)
			output = ""
			break
		}
		urls = append(urls, rest[:nl])
		output = rest[nl+1:]
	}
	clean += output
	return clean, urls
}

// computeAcceptKey computes the Sec-WebSocket-Accept value.
func computeAcceptKey(key string) string {
	const magic = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
	h := sha1Sum([]byte(key + magic))
	return base64Encode(h[:])
}

// sha1Sum computes SHA-1 for the WebSocket handshake.
func sha1Sum(data []byte) [20]byte {
	var h0 uint32 = 0x67452301
	var h1 uint32 = 0xEFCDAB89
	var h2 uint32 = 0x98BADCFE
	var h3 uint32 = 0x10325476
	var h4 uint32 = 0xC3D2E1F0

	origLen := len(data)
	data = append(data, 0x80)
	for (len(data)+8)%64 != 0 {
		data = append(data, 0)
	}
	bitLen := uint64(origLen) * 8
	for i := 7; i >= 0; i-- {
		data = append(data, byte(bitLen>>(i*8)))
	}

	for offset := 0; offset < len(data); offset += 64 {
		var w [80]uint32
		for i := 0; i < 16; i++ {
			w[i] = uint32(data[offset+i*4])<<24 | uint32(data[offset+i*4+1])<<16 |
				uint32(data[offset+i*4+2])<<8 | uint32(data[offset+i*4+3])
		}
		for i := 16; i < 80; i++ {
			w[i] = leftRotate(w[i-3]^w[i-8]^w[i-14]^w[i-16], 1)
		}

		a, b, c, d, e := h0, h1, h2, h3, h4
		for i := 0; i < 80; i++ {
			var f, k uint32
			switch {
			case i < 20:
				f = (b & c) | ((^b) & d)
				k = 0x5A827999
			case i < 40:
				f = b ^ c ^ d
				k = 0x6ED9EBA1
			case i < 60:
				f = (b & c) | (b & d) | (c & d)
				k = 0x8F1BBCDC
			default:
				f = b ^ c ^ d
				k = 0xCA62C1D6
			}
			temp := leftRotate(a, 5) + f + e + k + w[i]
			e = d
			d = c
			c = leftRotate(b, 30)
			b = a
			a = temp
		}
		h0 += a
		h1 += b
		h2 += c
		h3 += d
		h4 += e
	}

	var result [20]byte
	for i, v := range [5]uint32{h0, h1, h2, h3, h4} {
		result[i*4] = byte(v >> 24)
		result[i*4+1] = byte(v >> 16)
		result[i*4+2] = byte(v >> 8)
		result[i*4+3] = byte(v)
	}
	return result
}

func leftRotate(x uint32, n uint) uint32 {
	return (x << n) | (x >> (32 - n))
}

// base64Encode encodes bytes to base64 (RFC 4648).
func base64Encode(data []byte) string {
	const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	var out strings.Builder
	for i := 0; i < len(data); i += 3 {
		var b0, b1, b2 byte
		b0 = data[i]
		if i+1 < len(data) {
			b1 = data[i+1]
		}
		if i+2 < len(data) {
			b2 = data[i+2]
		}

		out.WriteByte(alphabet[b0>>2])
		out.WriteByte(alphabet[((b0&3)<<4)|(b1>>4)])
		if i+1 < len(data) {
			out.WriteByte(alphabet[((b1&0x0F)<<2)|(b2>>6)])
		} else {
			out.WriteByte('=')
		}
		if i+2 < len(data) {
			out.WriteByte(alphabet[b2&0x3F])
		} else {
			out.WriteByte('=')
		}
	}
	return out.String()
}

// handleNavMarkers strips \x00NAV:url\n markers from output.
// In terminal mode, opens the URL with the system browser.
func handleNavMarkers(output string) string {
	const marker = "\x00NAV:"
	var clean strings.Builder
	for {
		i := strings.Index(output, marker)
		if i < 0 {
			break
		}
		clean.WriteString(output[:i])
		rest := output[i+len(marker):]
		nl := strings.Index(rest, "\n")
		var navURL string
		if nl < 0 {
			navURL = rest
			output = ""
		} else {
			navURL = rest[:nl]
			output = rest[nl+1:]
		}
		fmt.Fprintf(os.Stderr, "navigate: %s\n", navURL)
	}
	clean.WriteString(output)
	return clean.String()
}

func defaultShapePath() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return "shapes.dat"
	}
	dir := filepath.Join(home, ".shape")
	os.MkdirAll(dir, 0755)
	return filepath.Join(dir, "local.shape")
}

func saveState(bs *store.BinaryStore, eng *engine.Engine) {
	allShapes := eng.Shapes()
	shapeMap := make(map[shape.ID]*shape.Shape, len(allShapes))
	for _, s := range allShapes {
		shapeMap[s.ID] = s
	}
	if err := bs.Save(eng.Tick(), shapeMap); err != nil {
		log.Printf("save: %v", err)
	}
}

// debouncedSaver coalesces rapid mutations into a single disk write.
// Every trigger marks dirty; a background goroutine flushes after the delay.
type debouncedSaver struct {
	bs    *store.BinaryStore
	eng   *engine.Engine
	delay time.Duration
	mu    sync.Mutex
	dirty bool
	timer *time.Timer
}

func newDebouncedSaver(bs *store.BinaryStore, eng *engine.Engine, delay time.Duration) *debouncedSaver {
	return &debouncedSaver{bs: bs, eng: eng, delay: delay}
}

func (d *debouncedSaver) trigger() {
	d.mu.Lock()
	d.dirty = true
	if d.timer == nil {
		d.timer = time.AfterFunc(d.delay, d.flush)
	}
	d.mu.Unlock()
}

func (d *debouncedSaver) flush() {
	d.mu.Lock()
	d.dirty = false
	if d.timer != nil {
		d.timer.Stop()
		d.timer = nil
	}
	d.mu.Unlock()
	saveState(d.bs, d.eng)
}

// sync flushes if dirty. Call before exit.
func (d *debouncedSaver) sync() {
	d.mu.Lock()
	dirty := d.dirty
	if d.timer != nil {
		d.timer.Stop()
		d.timer = nil
	}
	d.dirty = false
	d.mu.Unlock()
	if dirty {
		saveState(d.bs, d.eng)
	}
}

// bootOS loads the system from the embedded os/ directory tree.
// Directory structure mirrors the shape namespace: os.office.handler.sheet.data
// lives at os/os/office/handler/sheet/data.sl.
//
// Two-pass loading: first scan all files and extract layer numbers from
// shape declarations, then evaluate in layer order (0, 1, 2, 3, 4, 5).
// Runs once on first boot. After that, shapes persist in the binary file.
func bootOS(eng *engine.Engine) {
	type shapeFile struct {
		path  string
		layer int
		data  string
	}

	var files []shapeFile
	err := fs.WalkDir(shapes.FS, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() || !strings.HasSuffix(path, ".sl") {
			return nil
		}
		data, err := shapes.FS.ReadFile(path)
		if err != nil {
			return err
		}
		s := string(data)
		// Extract layer from "layer: N" in shape declaration.
		layer := 4 // default
		if m := regexp.MustCompile(`layer:\s*(\d+)`).FindStringSubmatch(s); m != nil {
			fmt.Sscanf(m[1], "%d", &layer)
		}
		files = append(files, shapeFile{path, layer, s})
		return nil
	})
	if err != nil {
		log.Printf("os dir walk: %v", err)
		return
	}

	// Sort by layer, then path within each layer.
	sort.Slice(files, func(i, j int) bool {
		if files[i].layer != files[j].layer {
			return files[i].layer < files[j].layer
		}
		return files[i].path < files[j].path
	})

	var parseErrors, evalErrors int
	for _, f := range files {
		prog, err := lang.Parse(f.data)
		if err != nil {
			parseErrors++
			// Create error shape
			errID := shape.ID("error.parse." + strings.ReplaceAll(f.path, "/", "."))
			errShape := &shape.Shape{ID: errID}
			errShape.Character.Dimensions = map[string]string{
				"type":    "error",
				"phase":   "parse",
				"source":  f.path,
				"message": err.Error(),
			}
			errShape.Character.Content = fmt.Sprintf("[parse] %s: %v", f.path, err)
			errShape.Structure.Emergence.Layer = 0
			eng.AddShape(errShape)
			fmt.Fprintf(os.Stderr, "[parse] %s: %v\n", f.path, err)
			continue
		}
		out, err := lang.Eval(prog, eng, "")
		if err != nil {
			evalErrors++
			errID := shape.ID("error.eval." + strings.ReplaceAll(f.path, "/", "."))
			errShape := &shape.Shape{ID: errID}
			errShape.Character.Dimensions = map[string]string{
				"type":    "error",
				"phase":   "eval",
				"source":  f.path,
				"message": err.Error(),
			}
			errShape.Character.Content = fmt.Sprintf("[eval] %s: %v", f.path, err)
			errShape.Structure.Emergence.Layer = 0
			eng.AddShape(errShape)
			fmt.Fprintf(os.Stderr, "[eval] %s: %v\n", f.path, err)
			continue
		}
		if out != "" {
			fmt.Print(out)
		}
	}
	loaded := len(eng.Shapes())
	if parseErrors > 0 || evalErrors > 0 {
		fmt.Fprintf(os.Stderr, "%d shapes loaded, %d parse errors, %d eval errors\n", loaded, parseErrors, evalErrors)
	}
	fmt.Printf("%d shapes loaded from shapes/\n", loaded)
}
