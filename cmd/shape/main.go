// Command shape is the native CLI for Shape OS.
// Boots the engine, loads shapes, serves HTTP, and provides a REPL.
//
// Usage:
//
//	shape                    # Boot OS, serve HTTP, open REPL
//	shape -port 8080         # Custom port (default 3000)
//	shape -no-serve          # REPL only, no HTTP
//
// The engine is the same one that runs in WASM. This is the native substrate.
package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"io/fs"
	"net/http"
	"os"
	"regexp"
	"sort"
	"strings"

	"github.com/ashbuilds/shape-engine/pkg/engine"
	"github.com/ashbuilds/shape-engine/pkg/lang"
	"github.com/ashbuilds/shape-engine/pkg/shape"
	"github.com/ashbuilds/shape-engine/pkg/transform"
	"github.com/ashbuilds/shape-engine/shapes"
)

var eng *engine.Engine

func main() {
	port := flag.Int("port", 3000, "HTTP port")
	noServe := flag.Bool("no-serve", false, "skip HTTP server")
	flag.Parse()

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

	// Register test transform.
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

	// Boot OS from embedded shapes.
	eng.SetActor("system")
	bootOS(eng)
	eng.SetActor("")

	fmt.Printf("Shape OS ready (%d shapes)\n", eng.ShapeCount())

	if !*noServe {
		go serve(*port)
		fmt.Printf("http://localhost:%d\n", *port)
	}

	repl()
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
			fmt.Fprintf(os.Stderr, "%s: parse error: %v\n", f.path, err)
			continue
		}
		_, err = lang.Eval(prog, eng, "")
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s: eval error: %v\n", f.path, err)
		}
	}
}

// --- HTTP ---

func serve(port int) {
	http.HandleFunc("/", handleHTTP)
	if err := http.ListenAndServe(fmt.Sprintf(":%d", port), nil); err != nil {
		fmt.Fprintf(os.Stderr, "http: %v\n", err)
	}
}

func handleHTTP(w http.ResponseWriter, r *http.Request) {
	method := r.Method
	path := r.URL.Path
	queryStr := r.URL.RawQuery

	// Read body for POST.
	var body string
	if r.Body != nil {
		buf := make([]byte, 1<<20) // 1MB max
		n, _ := r.Body.Read(buf)
		body = string(buf[:n])
	}

	route := findRoute(eng, method, path)
	if route == nil {
		http.NotFound(w, r)
		return
	}

	// Build scope.
	scope := make(map[string]string)
	for k, v := range route.Character.Dimensions {
		scope[k] = v
	}
	scope["method"] = method
	scope["path"] = path
	scope["query"] = queryStr
	scope["body"] = body

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
		http.Error(w, "parse error: "+err.Error(), 500)
		return
	}

	prevActor := eng.Actor()
	if method == "GET" {
		eng.SetActor("system")
	}
	out, err := lang.EvalWithScope(prog, eng, "", scope)
	if method == "GET" {
		eng.SetActor(prevActor)
	}
	if err != nil {
		http.Error(w, "eval error: "+err.Error(), 500)
		return
	}

	ct := route.Character.Dimensions["content_type"]
	if ct == "" {
		ct = "text/html; charset=utf-8"
	}
	w.Header().Set("Content-Type", ct)
	fmt.Fprint(w, out)
}

// --- REPL ---

func repl() {
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Buffer(make([]byte, 1<<20), 1<<20)

	for {
		fmt.Print("> ")
		if !scanner.Scan() {
			break
		}
		line := scanner.Text()
		if line == "" {
			continue
		}
		out := execShellLine(eng, line)
		if out != "" {
			fmt.Print(out)
			if !strings.HasSuffix(out, "\n") {
				fmt.Println()
			}
		}
	}
}

// --- Shell execution ---

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

// --- Routing ---

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

// --- API helpers ---

func getShapeJSON(id string) string {
	s, ok := eng.GetShape(shape.ID(id))
	if !ok {
		return "null"
	}
	data, _ := json.Marshal(s)
	return string(data)
}
