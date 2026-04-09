package engine

import (
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/shape"
)

// --- Namespace helpers ---

func TestNamespaceForActor(t *testing.T) {
	tests := []struct {
		actor string
		want  string
	}{
		{"system", ""},
		{"ash", "user.ash."},
		{"agent:copilot", "agent.copilot."},
		{"user.alice", "user.alice."},
		{"agent.bot", "agent.bot."},
	}
	for _, tt := range tests {
		got := namespaceForActor(tt.actor)
		if got != tt.want {
			t.Errorf("namespaceForActor(%q) = %q, want %q", tt.actor, got, tt.want)
		}
	}
}

func TestNamespaceForActor_Locked(t *testing.T) {
	// Empty actor = locked, should match nothing.
	prefix := namespaceForActor("")
	if prefix == "" {
		t.Error("empty actor should not return empty prefix (that's system mode)")
	}
}

func TestParseNamespace(t *testing.T) {
	tests := []struct {
		id     string
		wantNS string
		wantSx string
	}{
		{"os.render.foo", "os", "render.foo"},
		{"user.ash.render.foo", "user.ash", "render.foo"},
		{"agent.copilot.draft", "agent.copilot", "draft"},
		{"world.theme.dark", "world", "theme.dark"},
		{"os", "os", ""},
		{"user.ash", "user.ash", ""},
		{"law", "law", ""},
	}
	for _, tt := range tests {
		ns, sx := ParseNamespace(shape.ID(tt.id))
		if ns != tt.wantNS || sx != tt.wantSx {
			t.Errorf("ParseNamespace(%q) = (%q, %q), want (%q, %q)", tt.id, ns, sx, tt.wantNS, tt.wantSx)
		}
	}
}

// --- Write enforcement ---

func TestNamespaceEnforcement_UserCanWriteOwnNamespace(t *testing.T) {
	eng := New()
	eng.SetActor("ash")
	err := eng.AddShape(&shape.Shape{ID: "user.ash.settings.theme"})
	if err != nil {
		t.Fatalf("user should write own namespace: %v", err)
	}
}

func TestNamespaceEnforcement_UserCannotWriteOtherUser(t *testing.T) {
	eng := New()
	eng.SetActor("ash")
	err := eng.AddShape(&shape.Shape{ID: "user.bob.settings.theme"})
	if err == nil {
		t.Fatal("user should not write to another user's namespace")
	}
}

func TestNamespaceEnforcement_UserCannotWriteOS(t *testing.T) {
	eng := New()
	eng.SetActor("ash")
	err := eng.AddShape(&shape.Shape{ID: "os.config.foo"})
	if err == nil {
		t.Fatal("user should not write to os namespace")
	}
}

func TestNamespaceEnforcement_AgentSandbox(t *testing.T) {
	eng := New()
	eng.SetActor("agent:copilot")

	err := eng.AddShape(&shape.Shape{ID: "agent.copilot.draft.response"})
	if err != nil {
		t.Fatalf("agent should write own namespace: %v", err)
	}

	err = eng.AddShape(&shape.Shape{ID: "user.ash.foo"})
	if err == nil {
		t.Fatal("agent should not write to user namespace")
	}

	err = eng.AddShape(&shape.Shape{ID: "os.foo"})
	if err == nil {
		t.Fatal("agent should not write to os namespace")
	}
}

func TestNamespaceEnforcement_SystemMode(t *testing.T) {
	eng := New()
	eng.SetActor("system")
	err := eng.AddShape(&shape.Shape{ID: "os.config.foo"})
	if err != nil {
		t.Fatalf("system should write to os: %v", err)
	}
}

func TestNamespaceEnforcement_LockedMode(t *testing.T) {
	eng := New()
	// No actor set = locked. All writes should fail.
	err := eng.AddShape(&shape.Shape{ID: "os.config.foo"})
	if err == nil {
		t.Fatal("locked mode should reject all writes")
	}
	err = eng.AddShape(&shape.Shape{ID: "user.ash.foo"})
	if err == nil {
		t.Fatal("locked mode should reject all writes")
	}
}

func TestNamespaceEnforcement_UncheckedBypassesAll(t *testing.T) {
	eng := New()
	eng.SetActor("ash")
	eng.AddShapeUnchecked(&shape.Shape{ID: "os.config.bar"})
	if _, ok := eng.GetShape("os.config.bar"); !ok {
		t.Fatal("unchecked should bypass namespace check")
	}
}

func TestNamespaceEnforcement_Edit(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{ID: "os.config.foo", Character: shape.Character{Content: "v1"}})
	eng.SetActor("ash")
	_, err := eng.Edit("os.config.foo", "v2")
	if err == nil {
		t.Fatal("user should not edit os namespace")
	}
}

func TestNamespaceEnforcement_SetContent(t *testing.T) {
	eng := New()
	eng.SetActor("ash")
	err := eng.SetContent("os.config.foo", "bar")
	if err == nil {
		t.Fatal("user should not set_content in os namespace")
	}
}

func TestNamespaceEnforcement_EditDim(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{ID: "os.config.foo"})
	eng.SetActor("ash")
	err := eng.EditDim("os.config.foo", "key", "val")
	if err == nil {
		t.Fatal("user should not edit_dim in os namespace")
	}
}

func TestNamespaceEnforcement_RemoveShape(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{ID: "os.config.foo"})
	eng.SetActor("ash")
	err := eng.RemoveShape("os.config.foo")
	if err == nil {
		t.Fatal("user should not remove shapes from os namespace")
	}
}

// --- Overlay resolution ---

func TestOverlay_UserOverridesOS(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "os.config.theme",
		Character: shape.Character{Content: "dark"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "user.ash.config.theme",
		Character: shape.Character{Content: "solarized"},
	})
	eng.SetActor("ash")

	s, resolvedID, ok := eng.ResolveShape("os.config.theme")
	if !ok {
		t.Fatal("should resolve")
	}
	if resolvedID != "user.ash.config.theme" {
		t.Errorf("resolved to %s, want user.ash.config.theme", resolvedID)
	}
	if s.Character.Content != "solarized" {
		t.Errorf("content = %q, want solarized", s.Character.Content)
	}
}

func TestOverlay_FallsBackToOS(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "os.config.theme",
		Character: shape.Character{Content: "dark"},
	})
	eng.SetActor("ash")

	s, resolvedID, ok := eng.ResolveShape("os.config.theme")
	if !ok {
		t.Fatal("should resolve")
	}
	if resolvedID != "os.config.theme" {
		t.Errorf("resolved to %s, want os.config.theme", resolvedID)
	}
	if s.Character.Content != "dark" {
		t.Errorf("content = %q, want dark", s.Character.Content)
	}
}

func TestOverlay_UserNamespaceResolvesDirect(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "user.ash.my.thing",
		Character: shape.Character{Content: "mine"},
	})
	eng.SetActor("ash")

	s, resolvedID, ok := eng.ResolveShape("user.ash.my.thing")
	if !ok {
		t.Fatal("should resolve")
	}
	if resolvedID != "user.ash.my.thing" {
		t.Errorf("resolved to %s, want user.ash.my.thing", resolvedID)
	}
	if s.Character.Content != "mine" {
		t.Errorf("content = %q, want mine", s.Character.Content)
	}
}

func TestOverlay_NoActorDirectLookup(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "os.config.theme",
		Character: shape.Character{Content: "dark"},
	})
	// No actor set = locked, direct lookup only.
	_, resolvedID, ok := eng.ResolveShape("os.config.theme")
	if !ok {
		t.Fatal("should resolve")
	}
	if resolvedID != "os.config.theme" {
		t.Errorf("resolved to %s, want os.config.theme", resolvedID)
	}
}

func TestOverlay_CacheInvalidation(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "os.config.theme",
		Character: shape.Character{Content: "dark"},
	})
	eng.SetActor("ash")

	_, id1, _ := eng.ResolveShape("os.config.theme")
	if id1 != "os.config.theme" {
		t.Fatalf("first resolve: %s, want os.config.theme", id1)
	}

	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "user.ash.config.theme",
		Character: shape.Character{Content: "solarized"},
	})

	_, id2, _ := eng.ResolveShape("os.config.theme")
	if id2 != "user.ash.config.theme" {
		t.Errorf("after override: resolved to %s, want user.ash.config.theme", id2)
	}
}

func TestOverlay_WorldFallbackChain(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "world.theme.neon",
		Character: shape.Character{Content: "neon-global"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "os.theme.neon",
		Character: shape.Character{Content: "neon-local"},
	})
	eng.SetActor("ash")

	s, resolvedID, ok := eng.ResolveShape("world.theme.neon")
	if !ok {
		t.Fatal("should resolve")
	}
	if resolvedID != "os.theme.neon" {
		t.Errorf("resolved to %s, want os.theme.neon", resolvedID)
	}
	if s.Character.Content != "neon-local" {
		t.Errorf("content = %q, want neon-local", s.Character.Content)
	}
}

// --- Promotion ---

func TestPromote_OwnerToLocal(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "user.ash.render.widget",
		Character: shape.Character{Content: "my widget"},
	})
	eng.AddShapeUnchecked(&shape.Shape{ID: "os.permissions.promote.ash"})
	eng.SetActor("ash")

	promoted, err := eng.Promote("user.ash.render.widget", "local")
	if err != nil {
		t.Fatalf("promote failed: %v", err)
	}
	if len(promoted) != 1 {
		t.Fatalf("promoted %d shapes, want 1", len(promoted))
	}
	if promoted[0] != "os.render.widget" {
		t.Errorf("promoted to %s, want os.render.widget", promoted[0])
	}
	s, ok := eng.GetShape("os.render.widget")
	if !ok {
		t.Fatal("promoted shape not found")
	}
	if s.Character.Content != "my widget" {
		t.Errorf("content = %q, want 'my widget'", s.Character.Content)
	}
}

func TestPromote_WithDepTree(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "user.ash.render.widget.style",
		Character: shape.Character{Content: "css"},
	})
	eng.AddShapeUnchecked(&shape.Shape{
		ID:        "user.ash.render.widget",
		Character: shape.Character{Content: "html"},
		Structure: shape.Structure{
			Transformation: shape.Transformation{
				Deps: []shape.ID{"user.ash.render.widget.style"},
			},
		},
	})
	eng.AddShapeUnchecked(&shape.Shape{ID: "os.permissions.promote.ash"})
	eng.SetActor("ash")

	promoted, err := eng.Promote("user.ash.render.widget", "local")
	if err != nil {
		t.Fatalf("promote failed: %v", err)
	}
	if len(promoted) != 2 {
		t.Fatalf("promoted %d shapes, want 2", len(promoted))
	}

	s, ok := eng.GetShape("os.render.widget")
	if !ok {
		t.Fatal("promoted parent not found")
	}
	if len(s.Structure.Transformation.Deps) != 1 || s.Structure.Transformation.Deps[0] != "os.render.widget.style" {
		t.Errorf("deps = %v, want [os.render.widget.style]", s.Structure.Transformation.Deps)
	}
}

func TestPromote_WithoutPermission(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{ID: "user.ash.foo"})
	eng.SetActor("ash")

	_, err := eng.Promote("user.ash.foo", "local")
	if err == nil {
		t.Fatal("promote without permission should fail")
	}
}

func TestPromote_AgentNeedsExplicitGrant(t *testing.T) {
	eng := New()
	eng.AddShapeUnchecked(&shape.Shape{ID: "agent.copilot.draft"})
	eng.SetActor("agent:copilot")

	_, err := eng.Promote("agent.copilot.draft", "local")
	if err == nil {
		t.Fatal("agent promote without permission should fail")
	}
}
