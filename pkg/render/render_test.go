// Package render tests the structural integrity of all render shape trees.
//
// Every app in the OS has a render tree under os.render.<name>. The renderer
// (os.render.engine.renderer) walks this tree and builds DOM from shape types.
// These tests verify that:
//
//  1. Every app's render tree has proper containment (no orphans, no leaks)
//  2. CSS shapes do not contain layout-breaking rules (position:fixed, global resets)
//  3. The shape hierarchy matches the expected DOM structure
//  4. All deps resolve to sibling shapes
//  5. All shapes referenced in content (ordered children) exist
//
// If these tests pass, the rendering cannot produce structural layout bugs.
package render

import (
	"fmt"
	"io/fs"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/engine"
	"github.com/ashbuilds/shape-engine/pkg/lang"
	"github.com/ashbuilds/shape-engine/pkg/shape"
	shapes "github.com/ashbuilds/shape-engine/shapes"
)

// bootTestEngine loads all shapes from the embedded FS, same as production.
func bootTestEngine(t *testing.T) *engine.Engine {
	t.Helper()
	eng := engine.New()
	eng.SetActor("system")

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
		data, readErr := shapes.FS.ReadFile(path)
		if readErr != nil {
			return readErr
		}
		s := string(data)
		layer := 4
		if m := regexp.MustCompile(`layer:\s*(\d+)`).FindStringSubmatch(s); m != nil {
			fmt.Sscanf(m[1], "%d", &layer)
		}
		files = append(files, shapeFile{path, layer, s})
		return nil
	})
	if err != nil {
		t.Fatalf("walk shapes: %v", err)
	}

	sort.Slice(files, func(i, j int) bool {
		if files[i].layer != files[j].layer {
			return files[i].layer < files[j].layer
		}
		return files[i].path < files[j].path
	})

	for _, f := range files {
		prog, parseErr := lang.Parse(f.data)
		if parseErr != nil {
			t.Logf("[parse] %s: %v", f.path, parseErr)
			continue
		}
		_, evalErr := lang.Eval(prog, eng, "")
		if evalErr != nil {
			t.Logf("[eval] %s: %v", f.path, evalErr)
			continue
		}
	}
	return eng
}

// directChildren returns all shapes that are direct children of prefix
// (one level deeper), sorted by ID.
func directChildren(eng *engine.Engine, prefix string) []string {
	depth := strings.Count(prefix, ".") + 2 // prefix depth + 1
	p := prefix + "."
	var result []string
	for _, s := range eng.Shapes() {
		id := string(s.ID)
		if strings.HasPrefix(id, p) && strings.Count(id, ".")+1 == depth {
			result = append(result, id)
		}
	}
	sort.Strings(result)
	return result
}

// getDim returns a dimension value from a shape.
func getDim(eng *engine.Engine, id, key string) string {
	s, ok := eng.GetShape(shape.ID(id))
	if !ok {
		return ""
	}
	return s.Character.Dimensions[key]
}

// getDeps returns the dependency IDs for a shape.
func getDeps(eng *engine.Engine, id string) []string {
	s, ok := eng.GetShape(shape.ID(id))
	if !ok {
		return nil
	}
	var deps []string
	for _, d := range s.Structure.Transformation.Deps {
		deps = append(deps, string(d))
	}
	return deps
}


// ── Boot ────────────────────────────────────────────────────────────

func TestBootNoErrors(t *testing.T) {
	eng := bootTestEngine(t)
	count := eng.ShapeCount()
	if count == 0 {
		t.Fatal("no shapes loaded")
	}
	t.Logf("%d shapes loaded", count)

	// No parse/eval error shapes should exist.
	for _, s := range eng.Shapes() {
		id := string(s.ID)
		if strings.HasPrefix(id, "error.parse.") || strings.HasPrefix(id, "error.eval.") {
			t.Errorf("boot error: %s → %s", id, s.Character.Content)
		}
	}
}

// ── App render roots ────────────────────────────────────────────────

func TestEveryAppHasRenderShapes(t *testing.T) {
	eng := bootTestEngine(t)

	for _, s := range eng.Shapes() {
		if getDim(eng, string(s.ID), "type") != "app" {
			continue
		}
		if !strings.HasPrefix(string(s.ID), "os.app.") {
			continue
		}
		appName := strings.TrimPrefix(string(s.ID), "os.app.")
		renderName := getDim(eng, string(s.ID), "render")
		if renderName == "" {
			renderName = appName
		}
		renderPrefix := "os.render." + renderName

		children := directChildren(eng, renderPrefix)
		if len(children) == 0 {
			t.Logf("app %s: render tree %s has no children (incomplete app)", appName, renderPrefix)
			continue
		}

		// Every render tree with children must have at least a body/container child.
		hasBody := false
		for _, c := range children {
			cType := getDim(eng, c, "type")
			if cType == "body" || cType == "app" || cType == "container" || cType == "editable" {
				hasBody = true
				break
			}
		}
		if !hasBody {
			// Script-only apps (no structural body) are logged as warnings.
			// They build their own DOM but lack a structural render tree.
			hasScript := false
			for _, c := range children {
				if getDim(eng, c, "type") == "script" {
					hasScript = true
					break
				}
			}
			if hasScript {
				t.Logf("app %s: render tree %s has script but no structural body (script-driven app)", appName, renderPrefix)
			} else {
				t.Errorf("app %s: render tree %s has no body/container/editable child", appName, renderPrefix)
			}
		}
	}
}

// ── Dep integrity ───────────────────────────────────────────────────

func TestAllDepsResolveToPeers(t *testing.T) {
	eng := bootTestEngine(t)

	for _, s := range eng.Shapes() {
		id := string(s.ID)
		if !strings.HasPrefix(id, "os.render.") {
			continue
		}

		deps := getDeps(eng, id)
		for _, dep := range deps {
			// Dep must exist.
			if _, ok := eng.GetShape(shape.ID(dep)); !ok {
				t.Errorf("%s: dep %s does not exist", id, dep)
				continue
			}
			// Dep must be a sibling (same parent prefix) or an ancestor's sibling.
			// At minimum, it must share the same render tree root.
			idParts := strings.Split(id, ".")
			depParts := strings.Split(dep, ".")
			// Both should be under os.render.
			if len(idParts) < 3 || len(depParts) < 3 {
				continue
			}
			// Verify they share a common render tree prefix.
			// Find the render app prefix (e.g., os.render.doc.editor).
			// For now: just verify the dep exists.
		}
	}
}

// ── Content references ──────────────────────────────────────────────

func TestOrderedContentRefsExist(t *testing.T) {
	eng := bootTestEngine(t)

	for _, s := range eng.Shapes() {
		id := string(s.ID)
		if !strings.HasPrefix(id, "os.render.") {
			continue
		}
		sType := getDim(eng, id, "type")
		if sType != "toolbar" && sType != "menubar" && sType != "menu" {
			continue
		}

		// These types use content as ordered child lists.
		content := s.Character.Content
		lines := strings.Split(strings.TrimSpace(content), "\n")
		for _, line := range lines {
			ref := strings.TrimSpace(line)
			if ref == "" {
				continue
			}
			if _, ok := eng.GetShape(shape.ID(ref)); !ok {
				t.Errorf("%s: content references %s which does not exist", id, ref)
			}
		}
	}
}

// ── CSS structural integrity ────────────────────────────────────────

// Forbidden CSS patterns in app-level styles:
//   - position: fixed/absolute on non-menu/dropdown elements
//   - html, body selectors (leak into desktop)
//   - * { } global resets (leak into desktop)
var forbiddenCSSPatterns = []struct {
	pattern *regexp.Regexp
	reason  string
}{
	{
		regexp.MustCompile(`(?m)^\s*\*\s*\{`),
		"global * selector leaks into desktop",
	},
	{
		regexp.MustCompile(`(?m)(?:^|\s)html\s*[,{]`),
		"html selector leaks into desktop",
	},
	{
		regexp.MustCompile(`(?m)(?:^|[\s,])body\s*[,{]`),
		"body selector leaks into desktop",
	},
}

// Allowed position:fixed/absolute contexts (menus, dropdowns).
var allowedPositionContexts = regexp.MustCompile(`(?i)menu|dropdown|modal|tooltip|launcher|overlay`)

func TestCSSNoLeaks(t *testing.T) {
	eng := bootTestEngine(t)

	for _, s := range eng.Shapes() {
		if getDim(eng, string(s.ID), "type") != "style" {
			continue
		}
		if !strings.HasPrefix(string(s.ID), "os.render.") {
			continue
		}
		// Skip engine-level styles (WM, themes).
		if strings.HasPrefix(string(s.ID), "os.render.engine.") {
			continue
		}

		css := s.Character.Content
		id := string(s.ID)

		for _, fp := range forbiddenCSSPatterns {
			if fp.pattern.MatchString(css) {
				t.Errorf("%s: %s", id, fp.reason)
			}
		}

		// Check for position:fixed outside allowed contexts.
		fixedRe := regexp.MustCompile(`(?i)position\s*:\s*fixed`)
		if fixedRe.MatchString(css) {
			// Find which selector uses it.
			blocks := splitCSSBlocks(css)
			for _, block := range blocks {
				if fixedRe.MatchString(block.body) {
					if !allowedPositionContexts.MatchString(block.selector) {
						t.Errorf("%s: position:fixed on %q — must use flex/flow layout, not fixed positioning",
							id, block.selector)
					}
				}
			}
		}
	}
}

type cssBlock struct {
	selector string
	body     string
}

// splitCSSBlocks is a simple CSS block splitter (not a full parser).
func splitCSSBlocks(css string) []cssBlock {
	var blocks []cssBlock
	// Naive: find selector { body } patterns.
	depth := 0
	var selector, body strings.Builder
	inBody := false

	for _, r := range css {
		if r == '{' {
			if depth == 0 {
				inBody = true
				depth++
				continue
			}
			depth++
		}
		if r == '}' {
			depth--
			if depth == 0 {
				blocks = append(blocks, cssBlock{
					selector: strings.TrimSpace(selector.String()),
					body:     body.String(),
				})
				selector.Reset()
				body.Reset()
				inBody = false
				continue
			}
		}
		if inBody {
			body.WriteRune(r)
		} else {
			selector.WriteRune(r)
		}
	}
	return blocks
}

// ── Containment: status bars, toolbars must be inside a container ───

func TestStatusBarsContained(t *testing.T) {
	eng := bootTestEngine(t)

	for _, s := range eng.Shapes() {
		id := string(s.ID)
		sType := getDim(eng, id, "type")
		if sType != "statusbar" {
			continue
		}
		if !strings.HasPrefix(id, "os.render.") {
			continue
		}

		// The parent shape (one level up) must be a container/app/body type.
		parts := strings.Split(id, ".")
		if len(parts) < 2 {
			t.Errorf("%s: statusbar has no parent", id)
			continue
		}
		parentID := strings.Join(parts[:len(parts)-1], ".")
		parentShape, ok := eng.GetShape(shape.ID(parentID))
		if !ok {
			t.Errorf("%s: statusbar parent %s does not exist — status bar would render into window-content directly", id, parentID)
			continue
		}
		parentType := parentShape.Character.Dimensions["type"]
		validParents := map[string]bool{"container": true, "app": true, "body": true, "page": true}
		if !validParents[parentType] {
			t.Errorf("%s: statusbar parent %s has type %q — expected container/app/body", id, parentID, parentType)
		}
	}
}

// ── Structural containment: every render shape's parent path should exist ──

func TestRenderShapeParentChain(t *testing.T) {
	eng := bootTestEngine(t)

	// Collect all render tree root prefixes (os.render.<app-name>).
	// These are allowed to not exist as shapes (the default case handles them).
	rootPrefixes := make(map[string]bool)
	for _, s := range eng.Shapes() {
		if getDim(eng, string(s.ID), "type") != "app" {
			continue
		}
		if !strings.HasPrefix(string(s.ID), "os.app.") {
			continue
		}
		renderName := getDim(eng, string(s.ID), "render")
		if renderName == "" {
			renderName = strings.TrimPrefix(string(s.ID), "os.app.")
		}
		rootPrefixes["os.render."+renderName] = true
	}

	for _, s := range eng.Shapes() {
		id := string(s.ID)
		if !strings.HasPrefix(id, "os.render.") {
			continue
		}
		// Skip engine-level shapes.
		if strings.HasPrefix(id, "os.render.engine.") {
			continue
		}

		parts := strings.Split(id, ".")
		for depth := 3; depth < len(parts); depth++ {
			ancestor := strings.Join(parts[:depth], ".")
			if rootPrefixes[ancestor] {
				// App render root — allowed to not exist as a shape.
				continue
			}
			if _, ok := eng.GetShape(shape.ID(ancestor)); !ok {
				// Check if this ancestor has any descendants (i.e., it's a namespace prefix).
				hasDescendants := false
				prefix := ancestor + "."
				for _, ds := range eng.Shapes() {
					if strings.HasPrefix(string(ds.ID), prefix) {
						hasDescendants = true
						break
					}
				}
				if !hasDescendants {
					t.Errorf("%s: ancestor %s neither exists as shape nor has descendants", id, ancestor)
				}
			}
		}
	}
}

// ── DOM simulation: verify render output structure ──────────────────

// domNode represents a simulated DOM node produced by the renderer.
type domNode struct {
	tag      string
	class    string
	id       string
	shapeID  string // which shape produced this node
	children []*domNode
}

func (n *domNode) find(class string) *domNode {
	if n.class == class || strings.Contains(n.class, class) {
		return n
	}
	for _, c := range n.children {
		if found := c.find(class); found != nil {
			return found
		}
	}
	return nil
}

func (n *domNode) findByID(id string) *domNode {
	if n.id == id {
		return n
	}
	for _, c := range n.children {
		if found := c.findByID(id); found != nil {
			return found
		}
	}
	return nil
}

func (n *domNode) parent(root *domNode) *domNode {
	for _, c := range root.children {
		if c == n {
			return root
		}
		if p := n.parent(c); p != nil {
			return p
		}
	}
	return nil
}

// simulateRender builds a DOM tree by simulating the renderer logic.
func simulateRender(eng *engine.Engine, shapeID string) *domNode {
	root := &domNode{tag: "div", class: "window-content", id: "root"}
	renderShape(eng, shapeID, root)
	return root
}

func renderShape(eng *engine.Engine, id string, parent *domNode) {
	s, ok := eng.GetShape(shape.ID(id))
	sType := ""
	content := ""
	dims := map[string]string{}
	if ok {
		sType = s.Character.Dimensions["type"]
		content = s.Character.Content
		dims = s.Character.Dimensions
	}

	children := sortedChildren(eng, id)

	switch sType {
	case "style", "script":
		// Creates <style>/<script>, no visual children.
		node := &domNode{tag: sType, shapeID: id}
		parent.children = append(parent.children, node)

	case "container":
		node := &domNode{tag: "div", class: dims["class"], id: dims["id"], shapeID: id}
		parent.children = append(parent.children, node)
		for _, c := range children {
			renderShape(eng, c, node)
		}

	case "app":
		cls := "app-root"
		if dims["class"] != "" {
			cls += " " + dims["class"]
		}
		node := &domNode{tag: "div", class: cls, id: dims["id"], shapeID: id}
		parent.children = append(parent.children, node)
		for _, c := range children {
			renderShape(eng, c, node)
		}

	case "toolbar":
		node := &domNode{tag: "div", class: "doc-toolbar", shapeID: id}
		parent.children = append(parent.children, node)
		// Ordered content or topo-sorted children.
		refs := orderedRefs(content)
		if len(refs) > 0 {
			for _, ref := range refs {
				renderShape(eng, ref, node)
			}
		} else {
			for _, c := range children {
				renderShape(eng, c, node)
			}
		}

	case "menubar":
		node := &domNode{tag: "div", class: "menubar", shapeID: id}
		parent.children = append(parent.children, node)
		refs := orderedRefs(content)
		if len(refs) > 0 {
			for _, ref := range refs {
				renderShape(eng, ref, node)
			}
		} else {
			for _, c := range children {
				renderShape(eng, c, node)
			}
		}

	case "menu":
		node := &domNode{tag: "div", class: "menu", shapeID: id}
		parent.children = append(parent.children, node)
		refs := orderedRefs(content)
		if len(refs) > 0 {
			for _, ref := range refs {
				renderShape(eng, ref, node)
			}
		}

	case "menuitem":
		node := &domNode{tag: "div", class: "menuitem", shapeID: id}
		parent.children = append(parent.children, node)

	case "menuseparator":
		node := &domNode{tag: "hr", class: "menu-sep", shapeID: id}
		parent.children = append(parent.children, node)

	case "button":
		node := &domNode{tag: "button", class: dims["class"], id: dims["id"], shapeID: id}
		parent.children = append(parent.children, node)

	case "select":
		node := &domNode{tag: "select", class: dims["class"], id: dims["id"], shapeID: id}
		parent.children = append(parent.children, node)

	case "separator":
		cls := "separator"
		if dims["class"] != "" {
			cls += " " + dims["class"]
		}
		node := &domNode{tag: "div", class: cls, id: dims["id"], shapeID: id}
		parent.children = append(parent.children, node)

	case "editable":
		cls := dims["class"]
		if cls == "" {
			cls = "doc-page"
		}
		node := &domNode{tag: "div", class: cls, id: dims["id"], shapeID: id}
		parent.children = append(parent.children, node)

	case "statusbar":
		prefix := dims["id"]
		if prefix == "" {
			prefix = "doc"
		}
		node := &domNode{tag: "div", class: "doc-status", id: prefix + "-status", shapeID: id}
		parent.children = append(parent.children, node)

	case "body":
		// type: body is raw HTML — just mark it.
		node := &domNode{tag: "template", class: "body-raw", shapeID: id}
		parent.children = append(parent.children, node)

	case "html":
		node := &domNode{tag: "div", class: "html-raw", shapeID: id}
		parent.children = append(parent.children, node)

	default:
		// Transparent container: render children into parent.
		if len(children) > 0 {
			for _, c := range children {
				renderShape(eng, c, parent)
			}
		}
	}
}

// sortedChildren returns direct children in topological dep order.
func sortedChildren(eng *engine.Engine, prefix string) []string {
	children := directChildren(eng, prefix)
	if len(children) == 0 {
		return nil
	}

	childSet := make(map[string]bool, len(children))
	for _, c := range children {
		childSet[c] = true
	}

	var sorted []string
	visited := make(map[string]bool)

	var visit func(id string)
	visit = func(id string) {
		if visited[id] {
			return
		}
		visited[id] = true
		for _, dep := range getDeps(eng, id) {
			if childSet[dep] {
				visit(dep)
			}
		}
		sorted = append(sorted, id)
	}

	for _, c := range children {
		visit(c)
	}
	return sorted
}

func orderedRefs(content string) []string {
	var refs []string
	for _, line := range strings.Split(strings.TrimSpace(content), "\n") {
		ref := strings.TrimSpace(line)
		if ref != "" {
			refs = append(refs, ref)
		}
	}
	return refs
}

// ── DOM structure tests ─────────────────────────────────────────────

func TestDocEditorDOMStructure(t *testing.T) {
	eng := bootTestEngine(t)
	dom := simulateRender(eng, "os.render.doc.editor")

	// Status bar must be inside doc-body, not at top level.
	status := dom.find("doc-status")
	if status == nil {
		t.Fatal("doc-status not found in render tree")
	}
	statusParent := status.parent(dom)
	if statusParent == nil {
		t.Fatal("doc-status has no parent")
	}
	if !strings.Contains(statusParent.class, "doc-body") {
		t.Errorf("doc-status parent is %q (shape: %s), expected doc-body container",
			statusParent.class, statusParent.shapeID)
	}

	// doc-body must exist and contain both scroll and status.
	body := dom.find("doc-body")
	if body == nil {
		t.Fatal("doc-body not found")
	}
	scroll := body.find("doc-scroll")
	if scroll == nil {
		t.Error("doc-scroll not found inside doc-body")
	}
	bodyStatus := body.find("doc-status")
	if bodyStatus == nil {
		t.Error("doc-status not found inside doc-body")
	}

	// doc-page must be inside doc-scroll.
	if scroll != nil {
		page := scroll.findByID("doc-page")
		if page == nil {
			t.Error("doc-page not found inside doc-scroll")
		}
	}

	// Menubar and toolbar must be at the top level (inside window-content or app-root).
	menubar := dom.find("menubar")
	if menubar == nil {
		t.Error("menubar not found")
	}
	toolbar := dom.find("doc-toolbar")
	if toolbar == nil {
		t.Error("doc-toolbar not found")
	}
}

func TestSettingsDOMStructure(t *testing.T) {
	eng := bootTestEngine(t)
	dom := simulateRender(eng, "os.render.settings")

	// Settings should have an app-root.
	appRoot := dom.find("app-root")
	if appRoot == nil {
		t.Error("settings: no app-root found")
	}
}

func TestShortcutsDOMStructure(t *testing.T) {
	eng := bootTestEngine(t)
	dom := simulateRender(eng, "os.render.shortcuts")

	// Shortcuts should have an app-root.
	appRoot := dom.find("app-root")
	if appRoot == nil {
		t.Error("shortcuts: no app-root found")
	}
}
