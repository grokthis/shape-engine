//go:build js && wasm

// Command shape-wasm is the browser entry point for Shape OS.
// Compiles to WebAssembly. The browser IS the operating system.
//
// Build:
//   GOOS=js GOARCH=wasm go build -o web/shape.wasm ./cmd/shape-wasm/
package main

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"regexp"
	"sort"
	"strings"
	"syscall/js"

	"github.com/ashbuilds/shape-engine/pkg/engine"
	"github.com/ashbuilds/shape-engine/pkg/lang"
	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/transform"
	"github.com/ashbuilds/shape-engine/shapes"
)

var eng *engine.Engine

func main() {
	eng = engine.New()

	// Register agent transform.
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

	// Register test transform: auto-run tests when deps change.
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

	// Boot OS from embedded shapes (system mode for unrestricted writes).
	eng.SetActor("system")
	bootOS(eng)
	eng.SetActor("") // locked until login

	// Expose API to JavaScript.
	js.Global().Set("shapeEngine", js.ValueOf(map[string]interface{}{
		"handleRequest": js.FuncOf(handleRequestJS),
		"execShell":     js.FuncOf(execShellJS),
		"getShape":      js.FuncOf(getShapeJS),
		"shapeCount":    js.FuncOf(func(this js.Value, args []js.Value) interface{} { return eng.ShapeCount() }),
		"ready":         true,
	}))

	fmt.Printf("Shape OS ready (%d shapes)\n", eng.ShapeCount())

	// Block forever. The browser event loop drives execution.
	select {}
}

// handleRequestJS: (method, path, body) -> JSON {status, contentType, body}
func handleRequestJS(this js.Value, args []js.Value) interface{} {
	if len(args) < 3 {
		return js.ValueOf(`{"status":400,"contentType":"text/plain","body":"need (method, path, body)"}`)
	}
	method := args[0].String()
	path := args[1].String()
	body := args[2].String()

	// Parse query string from path.
	queryStr := ""
	if i := strings.Index(path, "?"); i >= 0 {
		queryStr = path[i+1:]
		path = path[:i]
	}

	route := findRoute(eng, method, path)
	if route == nil {
		return js.ValueOf(`{"status":404,"contentType":"text/plain","body":"not found"}`)
	}

	// Build scope from route dims + request.
	scope := make(map[string]string)
	for k, v := range route.Character.Dimensions {
		scope[k] = v
	}
	scope["method"] = method
	scope["path"] = path
	scope["query"] = queryStr
	scope["body"] = body

	// Parse query params.
	for _, param := range strings.Split(queryStr, "&") {
		if param == "" {
			continue
		}
		kv := strings.SplitN(param, "=", 2)
		if len(kv) == 2 {
			scope["q_"+kv[0]] = kv[1]
		} else {
			scope["q_"+kv[0]] = ""
		}
	}

	extractPathParams(route.Character.Dimensions["path"], path, scope)

	handlerID := route.Character.Dimensions["handler"]
	if handlerID == "" {
		return js.ValueOf(`{"status":500,"contentType":"text/plain","body":"route has no handler"}`)
	}
	handler, ok := eng.GetShape(shape.ID(handlerID))
	if !ok {
		return js.ValueOf(fmt.Sprintf(`{"status":500,"contentType":"text/plain","body":"handler not found: %s"}`, handlerID))
	}

	prog, err := lang.Parse(handler.Character.Content)
	if err != nil {
		return js.ValueOf(fmt.Sprintf(`{"status":500,"contentType":"text/plain","body":"parse error: %s"}`, err))
	}

	// Page handlers (GET) run as system — they render the OS.
	// API handlers (POST) run as the logged-in user — engine enforces namespace.
	prevActor := eng.Actor()
	if method == "GET" {
		eng.SetActor("system")
	}
	out, err := lang.EvalWithScope(prog, eng, "", scope)
	// Restore actor only for GET (system mode was temporary).
	// POST handlers may legitimately change the actor (lock/unlock).
	if method == "GET" {
		eng.SetActor(prevActor)
	}
	if err != nil {
		return js.ValueOf(fmt.Sprintf(`{"status":500,"contentType":"text/plain","body":"eval error: %s"}`, err))
	}

	ct := route.Character.Dimensions["content_type"]
	if ct == "" {
		ct = "text/html; charset=utf-8"
	}

	result := map[string]interface{}{
		"status":      200,
		"contentType": ct,
		"body":        out,
	}
	data, _ := json.Marshal(result)
	return js.ValueOf(string(data))
}

// execShellJS: (line) -> output string
func execShellJS(this js.Value, args []js.Value) interface{} {
	if len(args) < 1 {
		return js.ValueOf("")
	}
	return js.ValueOf(execShellLine(eng, args[0].String()))
}

// getShapeJS: (id) -> JSON shape or null
func getShapeJS(this js.Value, args []js.Value) interface{} {
	if len(args) < 1 {
		return js.Null()
	}
	s, ok := eng.GetShape(shape.ID(args[0].String()))
	if !ok {
		return js.Null()
	}
	data, _ := json.Marshal(s)
	return js.ValueOf(string(data))
}

// --- Shared logic (from cmd/shape/main.go) ---

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
			return s
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

func matchPattern(pattern, path string) bool {
	if pattern == "" {
		return false
	}
	patParts := strings.Split(pattern, "/")
	pathParts := strings.Split(path, "/")

	for i, pp := range patParts {
		isCatchAll := strings.HasPrefix(pp, "{") && strings.HasSuffix(pp, "...}")
		if isCatchAll {
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
			name := pp[1 : len(pp)-4]
			if i < len(pathParts) {
				scope["path_"+name] = strings.Join(pathParts[i:], "/")
			}
			return
		}
		if strings.HasPrefix(pp, "{") && strings.HasSuffix(pp, "}") {
			name := pp[1 : len(pp)-1]
			scope["path_"+name] = pathParts[i]
		}
	}
}

func execShellLine(eng *engine.Engine, line string) string {
	line = strings.TrimSpace(line)
	if line == "" {
		return ""
	}

	if strings.Contains(line, " | ") {
		segments := strings.Split(line, " | ")
		var output string
		for _, seg := range segments {
			seg = strings.TrimSpace(seg)
			if output != "" {
				seg = seg + " " + output
			}
			output = execShellLine(eng, seg)
		}
		return output
	}

	parts := strings.Fields(line)
	cmd := parts[0]
	argList := parts[1:]

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

func bootOS(eng *engine.Engine) {
	type shapeFile struct {
		path  string
		layer int
		data  string
	}

	var files []shapeFile
	fs.WalkDir(shapes.FS, ".", func(path string, d fs.DirEntry, err error) error {
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
		layer := 4
		if m := regexp.MustCompile(`layer:\s*(\d+)`).FindStringSubmatch(s); m != nil {
			fmt.Sscanf(m[1], "%d", &layer)
		}
		files = append(files, shapeFile{path, layer, s})
		return nil
	})

	sort.Slice(files, func(i, j int) bool {
		if files[i].layer != files[j].layer {
			return files[i].layer < files[j].layer
		}
		return files[i].path < files[j].path
	})

	for _, f := range files {
		prog, err := lang.Parse(f.data)
		if err != nil {
			fmt.Printf("%s: parse error: %v\n", f.path, err)
			continue
		}
		_, err = lang.Eval(prog, eng, "")
		if err != nil {
			fmt.Printf("%s: eval error: %v\n", f.path, err)
		}
	}
}
