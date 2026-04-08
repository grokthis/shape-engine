# The Shape Engine: Deriving a Self-Referential Structural Editor

*Ashley Butler, Independent Researcher*

*Date: April 2026*

---

> **Status: v1 (interactive draft)**
>
> This paper is part of a series deriving predictions from a single axiom (persistence is the capacity to change while maintaining continuity). The series is being published iteratively so the scope of the work is visible, then revised toward preprint quality before any paper enters formal publication.

---

## Abstract

We derive the architecture of a structural editor from a single axiom: persistence is the capacity to change while maintaining continuity [1]. The editor, called the shape engine, must satisfy the same four Laws of Coherence it enforces on the structures it manages. This self-referential requirement, that the engine is an instance of the shapes it processes, eliminates entire categories of software defects by making them structurally impossible. The derivation produces a concrete layered architecture, a modular transformation system, an append-only moment sequence with branching and locking, and a projection mechanism that generates outputs from dimensional slices of the structure. The resulting system is domain-agnostic: the same engine that produces academic papers produces constructed languages, fictional worlds, and programming languages, with different transformation libraries providing domain-specific behavior.

---

## 1. Introduction

The foundational paper [1] derives four structural requirements (the Laws of Coherence) that every persistent system must satisfy. It also derives the transformation law M' = f(C, S): every transformation takes a moment M with character C (what changes) and structure S (the geometry governing transformation), producing emergent moment M'.

This paper asks: what happens when you apply those requirements to the tool that manages structural content? The answer is the shape engine: a structural editor that is itself a shape.

The self-referential requirement is not optional. If the engine manages shapes but is not itself a shape, it cannot verify its own coherence. A tool that enforces structural integrity but lacks structural integrity is incoherent (Law 3 violation). The engine must include itself in its own context (S ∈ C) [1, §4].

**Central claim.** The shape engine's architecture is not designed. It is derived. Given the axiom and the four Laws, the architecture follows. Every design decision traces to a specific theorem or law in [1]. Where the derivation produces a choice (multiple coherent configurations), we identify the choice and the structural criteria for selecting between options. Where the derivation is forced (only one coherent configuration), we show why.

**Method.** Resolution dynamics [1, §11-12]. We identify the engine as a persistent shape, apply the four Laws, derive the coherent configuration.

---

## 2. The Engine as Shape

**Definition 2.1 (Shape Engine).** A shape engine is a persistent system E that:
1. Stores shapes with character C and structure S
2. Applies the transformation law M' = f(C, S) to those shapes
3. Tracks the moment sequence (development history) of each shape
4. Is itself a shape: E has its own character C_E, structure S_E, and moment sequence ∎

The self-referential property (4) is the key constraint. Without it, the engine is a conventional database with transformation rules. With it, the engine's own architecture must satisfy the Laws it enforces.

**Theorem 2.2 (Self-Inclusion).** The shape engine must include itself in its own context. That is, the engine E must be expressible as a shape within E.

*Derivation.* If E is not expressible as a shape within E, then there exists a persistent system (the engine) that the engine cannot represent. This means the engine's structural model is incomplete: it claims to manage all persistent structures but cannot manage itself. This is a Law 1 violation (the engine's reference to "all shapes" does not close, because it excludes itself). By [1, Theorem 4.1], any system that includes itself in its own context must have non-trivial structure. Therefore E must have its own S_E that is representable within E's shape model. ∎

**Corollary 2.3.** The engine's source code, module structure, dependency graph, and runtime state must all be expressible as shapes within the engine.

---

## 3. The Laws Applied to the Engine

### 3.1 Law 0: Persistence

**Theorem 3.1 (Engine Persistence).** The engine persists stably only if its structure S_E is coherent.

*Derivation.* Direct instantiation of [1, Law 0]. If S_E contains internal contradictions, dangling references, or structure from nothing, the engine will not persist stably. In software terms: the engine will have bugs that manifest as crashes, data corruption, or incorrect behavior. Structural incoherence in the engine IS software defects. ∎

**Corollary 3.2.** Every software defect in the engine is a Law violation. Conversely, if the engine satisfies all four Laws, it has no structural defects.

This is a strong claim. It does not mean the engine has no bugs in the conventional sense (typos in strings, off-by-one errors). It means that entire categories of architectural bugs, the ones that arise from structural incoherence, are eliminated.

### 3.2 Law 1: Stable Reference

**Theorem 3.3 (Reference Closure).** Every reference in the engine must close, point to an invariant, or be bounded [1, Law 1].

*Derivation.* In the engine's source code, references include:
- Import statements between modules
- Function calls across module boundaries
- Type references (one module using a type defined in another)
- Runtime references (one shape pointing to another via deps)

Each of these must close. An import that references a non-existent module is a dangling reference. A dep that points to a non-existent shape is a dangling reference. The engine must make dangling references structurally impossible where the type system permits, and detectable at load time where it does not. ∎

**Corollary 3.4 (Import Discipline).** The engine's module dependency graph must be a directed acyclic graph with no cycles. Cycles are mutual references that never close.

### 3.3 Law 2: Conservation

**Theorem 3.5 (No Structure from Nothing).** Every module in the engine must derive its structural content from modules below it in the emergence hierarchy. No module may claim capabilities that do not trace to its dependencies [1, Law 2].

*Derivation.* If a module at Layer N provides functionality that does not trace to any module at Layers 0 through N-1, that functionality appeared from nothing. This is a Law 2 violation. In software terms: every function, type, and behavior must trace to explicit dependencies. No "magic" modules that conjure capability without derivation. ∎

**Corollary 3.6.** The engine cannot have utility modules that "just work" without explicit placement in the emergence hierarchy. Every module has a layer. Every module's capabilities trace to its imports.

### 3.4 Law 3: Consistency

**Theorem 3.7 (No Contradictions in Contact).** When two modules in the engine are in contact (one imports the other, or both are imported by a third), they must not contradict each other [1, Law 3].

*Derivation.* Contradiction in code manifests as: two modules defining the same concept differently, two modules making incompatible assumptions about shared state, or two modules implementing conflicting transformation rules. The engine must make such contradictions detectable. The emergence layering (Theorem 4.1 below) is the primary mechanism: by restricting which modules can be in contact, the surface area for contradiction is minimized. ∎

---

## 4. The Emergence Structure

**Theorem 4.1 (Layered Architecture).** The engine's modules must form an emergence hierarchy where each layer emerges from the layer below and produces the layer above.

*Derivation.* By [1, Theorem 6.2], bilateral contact between shapes at the same layer produces emergent structure at a higher layer. The engine's modules are shapes in contact. Their composition must produce emergent capability at higher layers. By [1, Theorem 7.1], this emergence must be fractal: coherent at every layer.

The emergence hierarchy is not a style choice. It is forced by the Laws. If modules at the same layer depend on each other circularly, those references never close (Law 1 violation). If a module uses capability from a higher layer, structure flows downward, violating the direction of emergence (Law 2 violation: the higher layer's structure has not yet emerged at the lower layer). ∎

**Theorem 4.2 (Layer Identification).** The engine has exactly six emergence layers.

*Derivation.* We identify the layers by what emerges at each:

**Layer 0: The Axiom.** The shape type itself. Character, structure, identity. This is the irreducible primitive from which everything else emerges. Nothing below this layer exists in the engine. This layer corresponds to [1, §2-3].

**Layer 1: Self-Reference.** The moment sequence (trace) and dimensional structure emerge from the shape type. A shape that can track its own history requires the shape type (Layer 0) plus the capacity for self-reference [1, §4]. Dimensions (axes of expansion with canopy ranges) emerge here because they are shapes that describe other shapes.

**Layer 2: Transformation.** The transformation interface and persistence mechanism emerge from Layers 0-1. You cannot define how shapes transform until you have shapes (Layer 0) and their history (Layer 1). You cannot persist shapes to disk until you have shapes and their moment sequences. This layer corresponds to [1, §8-10].

**Layer 3: Composition.** The engine runtime emerges from Layers 0-2. It composes shapes, traces, transforms, and persistence into a functioning system. This is the emergence layer: the engine becomes more than the sum of its parts. Individual modules store, transform, and track shapes. The engine composes these into coherent structural management. This layer corresponds to [1, §11-12].

**Layer 4: Domain.** Domain-specific transformation libraries emerge from the engine runtime. The paper domain, conlang domain, worldbuilding domain. Each provides transformation functions that implement the TransformFn interface (Layer 2) and register with the engine (Layer 3). This layer corresponds to [1, §13-16]: the structural constants, landscape, and algebra specific to each domain.

**Layer 5: Application.** User-facing applications emerge from the domain layer. The CLI, the projection engine, the interactive editor. These compose domain transforms with the engine runtime to produce usable tools. This layer corresponds to the projections in [1, §16]: the observable outputs.

No layer can be removed without collapsing the layers above. No layer can be added between existing layers without violating the emergence ordering (the capability at each layer requires exactly the capabilities that emerged below it and no more). Therefore the layering is forced. ∎

**Corollary 4.3 (Import Rule).** A module at Layer N may only import modules at Layers 0 through N-1. No lateral imports within the same layer. No downward imports from higher layers.

This is the strictest form of the layering discipline. It eliminates:
- Circular dependencies (impossible: imports only flow upward)
- Hidden coupling between peer modules (no lateral imports)
- Abstraction violations (higher layers cannot be accessed from below)

---

## 5. The Concrete Architecture

From Theorem 4.2 and Corollary 4.3, the engine's directory structure follows:

```
layer0/         # Shape type, ID, Character, Structure, Emergence
layer1/         # Trace (moment sequence), Dimension (canopy ranges)
layer2/         # TransformFn interface, Store (persistence), Registry
layer3/         # Engine runtime (composition of layers 0-2)
layer4/         # Domain libraries (paper/, conlang/, world/, code/)
layer5/         # CLI, projection engine, interactive editor
```

### 5.1 Layer 0: Shape

**Definition 5.1 (Layer 0 Contents).** Layer 0 contains exactly:
- The Shape type (ID, Character, Structure)
- Character (map of dimension coordinates + content)
- Structure (Transformation + Emergence)
- Transformation (function reference + dependencies + constraints)
- Emergence (layer + from + produces)
- The Constraint type (law + status)

Layer 0 imports nothing. It is the axiom. Every other layer imports Layer 0. ∎

### 5.2 Layer 1: Self-Reference

**Definition 5.2 (Layer 1 Contents).** Layer 1 contains:
- Trace (append-only moment sequence with branching and locking)
- Moment (action + timestamp)
- Action types (edit, lock, unlock, branch, undo, propagate, run)
- Dimension (shape with canopy bottom and top)

Layer 1 imports only Layer 0. Traces reference shapes by ID (Layer 0 type). Dimensions are shapes (Layer 0) with additional canopy range fields. ∎

### 5.3 Layer 2: Transformation

**Definition 5.3 (Layer 2 Contents).** Layer 2 contains:
- TransformFn interface (Apply + Propagate)
- PropagationResult type (NoChange, AutoUpdate, FlagForReview)
- Registry (maps transform names to implementations)
- Store (YAML shape persistence, JSONL trace persistence)

Layer 2 imports Layers 0 and 1. The TransformFn interface takes Layer 0 types (Character, Structure) and returns Layer 0 types. The Store persists Layer 0 types (shapes) and Layer 1 types (traces). ∎

### 5.4 Layer 3: Composition

**Definition 5.4 (Layer 3 Contents).** Layer 3 contains:
- Engine (composes shapes, traces, transforms, store)
- Dependency indexing (reverse dep lookup for propagation)
- Staleness computation (which shapes need updating)
- Propagation logic (cascade changes through emergence)
- Coherence verification (check Laws along arcs)

Layer 3 imports Layers 0-2. It is the first layer where the full system behavior emerges: individual components from lower layers compose into structural management. ∎

### 5.5 Layer 4: Domain

**Definition 5.5 (Layer 4 Contents).** Layer 4 contains domain-specific transformation libraries:
- paper/ (FormalDerivation, TeachingDerivation, PractitionerTranslation, GeometryDerivation, MathDerivation, HistoryAnalysis, CoherenceCheck)
- conlang/ (SoundChange, MorphParadigm, SyntaxRule, LexiconDerivation)
- world/ (NarrativeConsistency, GeographyConstraint, CharacterArc, TimelineCheck)
- code/ (TypeCheck, Compile, Evaluate)

Each domain library imports Layer 2 (to implement TransformFn) and Layer 0 (to work with shapes). Domain libraries do not import each other unless one domain structurally depends on another (e.g., a worldbuilding project that includes conlangs would compose both at Layer 5, not couple them at Layer 4). ∎

### 5.6 Layer 5: Application

**Definition 5.6 (Layer 5 Contents).** Layer 5 contains:
- CLI (command-line interface to the engine)
- Projection engine (render outputs from dimensional slices)
- Loaders (convert external formats into shapes)
- Interactive editor (structural editing interface)

Layer 5 imports all lower layers. It is the user-facing surface. ∎

---

## 6. The Transformation System

**Theorem 6.1 (Structure Contains Functions).** The transformation function f in M' = f(C, S) must be part of the structure S, not external to it [1, §8].

*Derivation.* If f is external to S, then S does not fully describe the geometry governing transformation. The transformation depends on something outside the shape's own structure. This is a Law 1 violation: the shape references a transformation function that is not part of its own structural description.

Therefore each shape's structure must include a reference to its transformation function. The engine resolves this reference through the Registry (Layer 2). The function itself lives in a domain library (Layer 4). The shape stores the function's name; the engine resolves the name to an implementation at runtime. ∎

**Theorem 6.2 (Modular Transforms).** Transformation functions must be modular: implementing a fixed interface, registerable at runtime, composable across domains.

*Derivation.* Different shapes require different transformation behavior. A mathematical formula propagates automatically. A prose paragraph requires human review. A sound change rule applies deterministically. These are different functions implementing the same structural role: given C and S, produce M'.

The interface is forced by the transformation law. The modularity is forced by Law 2: if a single monolithic transform tried to handle all domains, it would contain structure that does not trace to its specific domain (it would "know" about domains it has never been given). Domain-specific transforms trace their capabilities to domain-specific knowledge. ∎

**Theorem 6.3 (Propagation Trichotomy).** When a dependency changes, exactly three outcomes are coherent: the dependent shape updates automatically, the dependent shape is flagged for review, or the change does not affect the dependent shape.

*Derivation.* Consider a shape X that depends on shape Y. Y changes. X must respond. The responses are:

1. **AutoUpdate**: X's transformation function can compute X's new state from Y's new state without external input. The transformation is deterministic and complete. Mathematical derivations, rule-based transformations.

2. **FlagForReview**: X's transformation function cannot compute X's new state automatically. The transformation requires judgment, creativity, or context that the function does not possess. The function marks X as stale. This is not failure. It is the function correctly identifying its own limitation.

3. **NoChange**: Y's change does not affect X. The dependency exists but the specific change is outside the scope of what X derives from Y.

No fourth option is coherent. X cannot "partially update" (that would leave X in an incoherent intermediate state, Law 0 violation). X cannot "ignore the change while remaining current" (that would mean X claims to derive from Y but does not reflect Y's state, Law 1 violation: the reference to Y does not close). ∎

---

## 7. The Moment Sequence

**Theorem 7.1 (Append-Only History).** The engine's development history must be append-only. No moment, once recorded, may be deleted or modified.

*Derivation.* By Law 2, no destruction into nothing. A moment that existed and is then deleted has been destroyed. The information it carried is gone. This violates conservation.

In practice: every edit, undo, branch, lock, and unlock is a new moment appended to the trace. Even undoing a change does not delete the original change. It appends a new moment that records the reversal. The full history is always recoverable. ∎

**Theorem 7.2 (Trace Per Layer).** Each emergence layer has its own trace, rooted in the layer below at a specific moment.

*Derivation.* By Theorem 4.1, the engine is layered. Each layer emerges from the layer below. The development history of each layer is its own moment sequence: the series of transformations that brought that layer to its current state.

A layer's trace is rooted in the layer below at a specific moment because the layer emerged from a specific state of the layer below. If the layer below changes after the emergence point, the upper layer's trace may or may not need updating (depending on whether the change affects the emergence).

This is the persistence fractal [1, Theorem 7.1]: the trace structure mirrors the emergence structure. Each layer has its own history. The system history emerges from the composition of layer histories. ∎

**Theorem 7.3 (Locking as Controlled Resolution).** Locking a moment freezes it against propagation. This is controlled resolution [1, Definition 14.2]: creating a bounded region where forcing can operate safely.

*Derivation.* When you lock a moment, you are saying: "this state is stable. Changes below should not propagate past this point." This creates a workbench:

1. Lock the top of a section (the output you trust)
2. Lock the bottom (the foundation you trust)
3. Work the internal layers freely
4. Unlock when the internal structure coheres
5. Resolution cascades through the unlocked boundaries

Without locking, every change propagates immediately through the entire structure. This is uncontrolled forcing: any edit anywhere potentially destabilizes everything. Locking provides the control that makes structural editing practical.

The lock is not suppression. It is temporary structural isolation. The locked moment remains in the trace. When unlocked, the full resolution occurs. Nothing is lost. ∎

**Theorem 7.4 (Branching as Canopy Exploration).** Branches in the trace tree are explorations of alternate canopy paths. Each branch is a trace through the canopy [1, §12.1] that may or may not become the active version.

*Derivation.* The canopy of a structure is the set of all coherent traces through it [1, Definition 12.1]. When you branch, you are exploring a different trace. The original trace persists (Law 2: no destruction). The new trace may converge to a better configuration or may be abandoned.

Abandoned branches are not deleted. They are alternate realities: coherent paths that were explored but not taken. They persist in the trace tree because everything that can persist, will [1, Law 0]. A branch that was abandoned may become valuable later (a design path that was premature at the time but becomes relevant as the structure evolves). ∎

---

## 8. Projections

**Theorem 8.1 (Projections as Emergent Shapes).** A projection is a shape that emerges from a collection of shapes. It is not a separate mechanism. It is emergence applied to output generation.

*Derivation.* A paper is a projection: it emerges from the composition of its sections. A dictionary is a projection: it emerges from the composition of its lexical entries. A compiled binary is a projection: it emerges from the composition of its source modules.

In each case, the projection has its own character (the rendered output), its own structure (the ordering, formatting, and selection rules), and its own emergence position (it sits above the shapes it aggregates). The projection IS a shape. It follows the same Laws. Its references must close (every shape it claims to include must exist). Its content must trace to its sources (no content from nothing). It must not contradict its sources. ∎

**Corollary 8.2.** The projection engine is not a special subsystem. It is the engine's standard emergence mechanism applied to output generation. Any shape that emerges from other shapes is, structurally, a projection.

---

## 9. Dimensions

**Theorem 9.1 (Dimensions as Shapes with Canopy Ranges).** A dimension is a shape whose character describes an axis of expansion and whose structure includes the emergence layers at which that axis is valid.

*Derivation.* A dimension (e.g., "part" with coordinates 1-6, or "topic" with coordinates 08a-08u) describes a structural axis. It has character (its name, its valid coordinates) and structure (where in the emergence hierarchy it becomes meaningful and where it stops being meaningful).

Not all dimensions are valid at all layers. The "social governance" dimension does not exist below the emergence of societies. The "phonological" dimension does not exist below the emergence of sound systems. Each dimension has a canopy bottom (emergence layer) and canopy top (de-emergence layer). Shapes are only created within a dimension's valid canopy range.

This is not a constraint imposed on the model. It is a derivation from the theory: a dimension that claims to be valid at a layer where its content has not emerged is making a reference to structure that does not yet exist (Law 1 violation). ∎

**Theorem 9.2 (Dimensional Expansion).** Adding a dimension to the structure creates new shapes at every valid intersection within the dimension's canopy range. Each new shape inherits transformation dependencies from the shapes it extends.

*Derivation.* When we added Part 4 (structural geometry) to Volume 8, this operation created 21 new shapes (one per topic) at the Part 4 coordinate. Each new shape inherited a dependency on its Part 3 counterpart (the formal derivation from which the geometry derives). The dimension "part" expanded from coordinates {1, 2, 3} to {1, 2, 3, 4}, and 21 new shapes appeared at the new coordinate.

This is the mechanism by which the structure grows: not by adding individual shapes, but by adding dimensions that create shapes systematically at all valid intersections. The dependencies between the new shapes and the existing shapes are determined by the dimension's structural specification, not by manual wiring. ∎

---

## 10. Programs

**Theorem 10.1 (Programs as Shapes).** A program is a shape whose structure S defines a transformation that, when applied to input character C, produces a collection of new shapes.

*Derivation.* The domain volume template is a program. Its structure specifies: given a domain (emergence layers, parallel systems, cross-cutting themes), produce 21 topics × 6 parts = 126 shapes with specified dependencies, transformation functions, and emergence positions.

The template is not instructions for a human. It is a shape whose transformation function, when applied to a domain description (character), produces the full structural specification of a volume (the emergent output). The same program applied to different character produces different volumes: Society, Physics, Biology.

A program is structure S that operates over character C to produce M'. This is the transformation law. A program IS a shape. ∎

**Corollary 10.2.** Running a program produces a trace. Each step of the program's execution is a moment in the trace. You can inspect intermediate states, branch from any point, lock moments, and re-run with different input. The program's execution history is fully recoverable.

---

## 11. What This Eliminates

**Theorem 11.1 (Structural Defect Elimination).** The layered architecture derived in §4-5 eliminates the following categories of defects:

1. **Circular dependencies.** Impossible. Imports flow strictly upward through emergence layers (Corollary 4.3). A cycle would require a downward import.

2. **Dangling references.** Detectable at load time. Every shape's deps must resolve to existing shapes. Every module's imports must resolve to existing modules. Law 1 is checked structurally.

3. **Hidden coupling.** Impossible between peer modules. No lateral imports within the same layer (Corollary 4.3). Modules at the same layer interact only through the layer above that composes them.

4. **Abstraction violations.** Impossible. A lower layer cannot access a higher layer's capabilities because the higher layer has not emerged yet at the lower layer's position in the hierarchy.

5. **Orphaned structure.** Detectable. A shape with no emergence links (not emerging from anything, not producing anything) is structurally isolated. Law 1 requires references to close. An orphan's references to the rest of the system do not close.

6. **Inconsistent propagation.** The propagation trichotomy (Theorem 6.3) forces every dependency change to be handled explicitly. There is no "ignore and hope" option. Every change is auto-updated, flagged, or explicitly marked as non-affecting.

7. **Lost history.** Impossible. The trace is append-only (Theorem 7.1). Every change is recorded. Undos are new moments, not deletions. The full development history is always recoverable. ∎

**Remark 11.2.** The engine does not eliminate all possible bugs. Logic errors within a transformation function, incorrect domain knowledge in a transform library, and typos in content are all possible. What the architecture eliminates is structural defects: the class of bugs that arise from incoherent composition of modules, circular dependencies, dangling references, inconsistent state propagation, and lost history. These are the bugs that the Laws specifically address.

---

## 12. Connection to the Shape Processor

The shape engine is software. The shape processor [2] is hardware. They are the same architecture at different emergence layers.

The shape processor implements M' = f(C, S) in silicon: mixing angles as physical geometry, persistence magnitudes as signal strengths, coherence checking as hardware verification. The shape engine implements M' = f(C, S) in code: transformation functions as modules, persistence as disk storage, coherence checking as Law verification.

The engine is the first software for the processor. When the processor exists, the engine runs on it natively: each shape maps to a hardware shape, each transformation maps to a hardware transformation, each coherence check maps to a hardware verification. The layered architecture of the engine maps to the layered architecture of the processor.

This paper derives the software. Paper [2] derives the hardware. Together they derive the complete computational stack for structural persistence.

---

## 13. Predictions

**Prediction 13.1 (Bug Category Elimination).** A codebase structured according to the layered architecture of §5, with the import rule of Corollary 4.3, will have zero circular dependency bugs, zero dangling reference bugs that survive load time, and zero hidden coupling bugs between peer modules. This is testable by static analysis.

**Prediction 13.2 (Propagation Completeness).** A structure managed by the engine will have zero "silently stale" shapes: every shape is either current (verified against all dependencies), flagged for review (explicitly marked stale), or locked (deliberately frozen). This is testable by running `engine status` at any time.

**Prediction 13.3 (History Completeness).** No information is ever lost in an engine-managed structure. Every state that ever existed is recoverable from the trace tree. This is testable by attempting to recover any prior state.

**Prediction 13.4 (Domain Agnosticism).** The same engine architecture, with different transformation libraries, manages academic papers, constructed languages, fictional worlds, and programming languages without modification to the engine itself. This is testable by implementing each domain and verifying the engine requires no domain-specific changes.

**Prediction 13.5 (Self-Hosting).** The engine's own source code, structured according to §5, can be loaded into the engine as shapes and managed by the engine. Editing the engine's source through the engine produces the same result as editing it directly, with the addition of full trace history and coherence checking. This is testable by self-hosting.

---

## 14. Implementation and Results

We implemented the shape engine in Go to test the predictions of §13. The implementation follows the six-layer architecture of §5 exactly: six directories (`layer0/` through `layer5/`), one package per emergence layer for layers 0-3, sub-packages for domain libraries (layer 4) and applications (layer 5).

### 14.1 Import Discipline Verified

The implementation's import graph:

| Package | Imports |
|---------|---------|
| `layer0` | nothing |
| `layer1` | `layer0` |
| `layer2` | `layer0`, `layer1` |
| `layer3` | `layer0`, `layer1`, `layer2` |
| `layer4/paper` | `layer0`, `layer2` |
| `layer5/cmd` | `layer0`, `layer3` |
| `layer5/loaders` | `layer0` |

No lateral imports within the same layer. No downward imports from higher layers. No cycles. The Go compiler enforces this statically: a cycle is a compilation error. Prediction 13.1 is confirmed for the engine's own codebase.

Note that `layer4/paper` imports `layer2` (for the `TransformFn` interface) but not `layer1` or `layer3`. It does not need traces or the engine runtime. Each layer imports only what it structurally requires, not the full stack below it. The import rule of Corollary 4.3 is a ceiling, not a mandate.

### 14.2 Propagation Confirmed

Editing a foundation shape (the axiom) immediately identifies all transitively dependent shapes as stale. No shape is silently stale. The propagation trichotomy (AutoUpdate, FlagForReview, NoChange) handles every dependency change. Prediction 13.2 is confirmed.

### 14.3 Domain Loading Confirmed

A volume loader converts 133 existing markdown papers (Volume 8, Society) into shapes with correct emergence layers, transformation functions, inter-part dependencies, and topic classifications. The engine required no domain-specific modification. Prediction 13.4 is confirmed for the paper domain.

### 14.4 The Central Result

The implementation revealed what the derivation actually produced. The six-layer architecture, the import discipline, the propagation trichotomy, the append-only trace: none of these depend on Go. They are structural requirements. Go is character. The structure is the same in any language.

In Go, layers are packages. In Rust, they are crates. In TypeScript, they are modules. In Python, they are packages. The discipline is identical: layer N imports only layers 0 through N-1. The types at layer 0 import nothing. The transformation interface at layer 2 is implemented by domain libraries at layer 4. The engine runtime at layer 3 composes layers 0-2 into a functioning system.

**Theorem 14.1 (Language Independence).** The shape engine architecture is a structural pattern, not a software artifact. Any implementation that satisfies the six-layer import discipline, the propagation trichotomy, and the append-only trace implements the shape engine, regardless of programming language.

*Derivation.* The architecture was derived from the axiom and the four Laws (§2-4). The derivation references no language-specific features. Every constraint (layered imports, propagation trichotomy, append-only history) is expressible in any language that supports modules, interfaces, and file I/O. The Go implementation is one projection of the structure. Other projections are structurally equivalent [1, Definition 16.1]. ∎

This is not an abstraction. It is a consequence. The paper derived structural requirements from the persistence axiom. The implementation confirmed those requirements hold in practice. The confirmation demonstrated that what was derived is structure, not code. The engine is a modeling exercise: given any domain, define its shapes, dimensions, and transforms, and the engine manages coherence.

---

## 15. Discussion

The shape engine is derived, not designed. Every architectural decision traces to a specific theorem or law in [1]. The layering is forced by emergence. The import discipline is forced by reference closure. The append-only trace is forced by conservation. The propagation trichotomy is forced by the requirement that every dependency change be handled coherently.

The self-referential property remains the strongest outstanding test. Prediction 13.5 (self-hosting) has not yet been confirmed: loading the engine's own source code into the engine as shapes and managing the engine through itself. This is the next step. If the engine can manage itself, it is structurally sound. If it cannot, there is a defect in either the engine or the theory. Both outcomes are informative.

The implementation process itself demonstrated the derivation's validity in an unexpected way. The first implementation was organized by technical concern (`pkg/shape`, `pkg/trace`, `pkg/store`, `pkg/engine`). This is the conventional Go layout: group by what things are. The derivation required reorganization by emergence: group by when things become possible. The conventional layout compiled and passed tests, but it obscured the structural relationships. The layered layout makes the architecture legible: you can read the import graph and see the emergence hierarchy. The structure is the documentation.

What this paper does: it derives the complete architecture of a structural editor from one axiom, implements it, confirms the predictions, and demonstrates that the result is language-independent. The architecture eliminates entire categories of defects (§11), manages any domain without modification (§14.3), and produces a structural pattern that works in any programming language (Theorem 14.1). The engine is not a tool. It is a consequence of persistence.

---

## References

[1] A. Butler, "A Complete Theory of Persistence," Independent preprint, Zenodo, 2026. doi:10.5281/zenodo.15192553

[2] A. Butler, "P ≠ NP: A Proof via Structural Self-Reference," Shape Theory Papers, 2026.
