# Shape Engine Architecture

*Draft v0.1 - April 2026*

---

## What This Is

The shape engine is the application of shape theory to itself. It is a structural editor, version control system, and projection engine unified by one principle: everything is a shape, and shapes transform according to M' = f(C, S).

The engine holds multi-dimensional structural content, tracks its full development history, propagates changes through emergence layers, and projects outputs (papers, lexicons, narratives, programs) from slices of the structure. It is domain-agnostic. Papers, constructed languages, fantasy worlds, programming languages, and D&D campaigns are all shapes in the same engine with different transformation libraries.

The engine ships as a tool. The structure ships as a data format. Others can build their own worlds and share them.

---

## Foundations

### One Axiom

> *Persistence is the capacity to change while maintaining continuity.* [1]

### The Transformation Law

M' = f(C, S)

Every transformation takes a moment M with character C (what changes) and structure S (the geometry governing transformation), producing emergent moment M'. This operates at every layer of the engine.

### The Four Laws

Everything in the engine must satisfy these, or it will not persist stably:

- **Law 0 (Persistence)**: A shape persists stably only if its structure S is coherent.
- **Law 1 (Stable Reference)**: References must close, point to invariants, or be bounded.
- **Law 2 (Conservation)**: No structure from nothing, no destruction into nothing.
- **Law 3 (Consistency)**: Coupled incompatible shapes must resolve or trigger dissolution.

---

## Core Primitive: The Shape

Everything in the engine is a shape. There is no other primitive.

### Shape Definition

```
Shape {
    id                      // hierarchical identity
    character {             // C: what changes
        dimension: value,   // map of dimension to coordinate
        ...
        content: ...        // the actual text, math, data at this position
    }
    structure {
        transformation {        // S: how this shape transforms
            fn: TransformFn     // the function itself (modular, domain-specific)
            deps: []ShapeRef    // what this shape derives from
            constraints: []     // coherence requirements
        }
        emergence {             // where this shape sits in the stack
            layer: int          // emergence level
            from: []ShapeRef    // what this emerges from (layer below)
            produces: []ShapeRef // what emerges from this (layer above)
        }
    }
    moment_sequence: TraceRef   // pointer into the trace tree
}
```

### Character

Character is a map of dimensions to values. It is what changes across transformations. For a paper section, the character might be:

```yaml
character:
  topic: 08a
  part: 3
  section: polarization
  formality: theorem
  content: "The economy's dominant axis is capital versus labor..."
```

For a conlang phoneme:

```yaml
character:
  language: proto-eastern
  category: consonant
  place: bilabial
  manner: stop
  voicing: voiced
  content: /b/
```

The same shape model holds both. The dimensions are different. The engine doesn't care.

### Structure: Transformation

Structure includes the transformation function. S is not just data. It contains f itself.

The `fn` field references a modular transformation function from a domain library. The engine provides the interface. Domains provide the implementations.

```
TransformFn = interface {
    // Given character C and structure S, produce M'
    apply(C, S) -> M'

    // Given a change to a dependency, determine propagation
    propagate(change, self) -> AutoUpdate | FlagForReview | NoChange
}
```

When a dependency changes:
- **AutoUpdate**: the transform can compute the new state automatically (mathematical derivation, sound change application, type checking)
- **FlagForReview**: the transform marks the shape stale, with the specific dependency change that caused it (text that derives from changed structure)
- **NoChange**: the dependency change doesn't affect this shape

### Structure: Emergence

Every shape has an emergence position: what layer it exists at, what it emerges from below, what it produces above.

A paper section emerges from its sub-components (paragraphs, theorems, figures). It produces the paper it belongs to. The paper emerges from its sections. The volume emerges from its papers. The canopy emerges from its volumes.

This is not metadata. It is structural. The emergence relationships determine how changes propagate (upward through emergence) and how state is computed (downward through derivation).

---

## Dimensions

### Dimensions Are Shapes

A dimension is not a flat axis. It is itself a shape with emergence structure. Each dimension has a canopy: a bottom (where it emerges, becomes meaningful) and a top (where it de-emerges, stops being meaningful).

```
Dimension {
    id                  // itself a shape
    canopy_bottom       // emergence layer where this dimension begins
    canopy_top          // emergence layer where this dimension ends
    coordinates []      // valid values along this dimension
}
```

### Dimension Validity

Social governance dimensions don't exist below the layer where societies exist. Phonological dimensions don't exist below the layer where sound systems exist. Mathematical formalism dimensions don't exist below the layer where formal derivation exists.

When you expand the structure into a new dimension, shapes are only created within that dimension's valid canopy range. The structure is not a uniform grid. It is emergence-shaped.

### Adding Dimensions

Adding a dimension is an expansion operation. It creates new shape slots at every valid intersection within the dimension's canopy range. Those slots start with no content (stale against their dependencies in other dimensions). This is exactly what we did when we added Parts 4, 5, and 6 to Volume 8: each addition created 21 new shape slots (one per topic) that needed to be filled and verified.

---

## The Trace Tree

### Purpose

The trace tree is the moment sequence of the structure. It records the full development history: every change, every branch explored, every undo. It is append-only. You never lose access to any moment. Everything that can persist, will.

### Architecture: One Trace Per Layer

Each emergence layer has its own trace. Each trace is rooted in the layer below it at a specific version.

```
Layer 0 trace: foundation
    ^
Layer 1 trace: rooted in Layer 0 @ moment 12
    ^
Layer 2 trace: rooted in Layer 1 @ moment 7
    ^
Layer 3 trace: rooted in Layer 2 @ moment 3
```

Edit Layer 0: potentially affects everything above. Edit Layer 2: only Layers 2 and above are affected. The system-level trace is not a separate structure. It emerges from the composition of all layer traces.

### Trace Structure

Each trace is a tree, not a linked list. Branch points create subtrees for alternate explorations.

```
Trace {
    root: (parent_trace, moment)    // where this trace branches from parent layer
    moments: []Moment               // append-only sequence on this branch
    branches: {                     // named exploration branches
        name: Trace,                // each branch is itself a trace
        ...
    }
    locks: {moment_id: bool}        // which moments are frozen
    active_branch: name             // which branch is "current"
}

Moment {
    id: int                         // sequential within this trace
    action: Action                  // what happened
    timestamp: ...
}

Action = Edit | Lock | Unlock | Branch | Merge | Undo | RunProgram
```

### The Emergent Current Version

The "current state" of any shape is not stored as ground truth. It is computed by replaying the active branch of its layer trace from root, respecting locks. This is emergence: the current version emerges from the trace below it.

The emergent current version can be cached for performance and invalidated on new appends. But the trace is always the source of truth.

### Locking

A locked moment is frozen. Changes do not propagate past it. This gives you a controlled workbench:

1. Lock the top of a canopy section (the output you want to preserve)
2. Lock the bottom (the foundation you trust)
3. Work the internal layers freely
4. Unlock when ready
5. Resolution cascades: automatic for math, flagged for text

This is controlled resolution [1, Definition 14.2]. The locks create a bounded region where forcing can operate safely without destabilizing the layers above or below.

### Branching

Branch at any moment to explore an alternate path. The original path persists. Both branches are accessible. The engine tracks which branch is active (the one whose emergent state is "experienced").

Alternate branches are alternate realities. They persist in the trace tree. You can:
- Compare branches
- Lock moments you like from any branch
- Merge structure from one branch into another
- Switch the active branch at any time

### Storage on Disk

Traces are stored as sequence files: a root reference + an ordered sequence of actions.

```
.cuivien/traces/
  layer-0/
    main.seq              # root + actions on main branch
    exploration-1.seq     # branched from main @ moment 15
    locks.json            # frozen moments
  layer-1/
    main.seq              # rooted in layer-0/main @ moment 12
    ...
  layer-2/
    ...
```

Each `.seq` file is append-only. Actions are appended, never modified. Even undos are new actions that record the reversal.

---

## Programs

### Programs Are Shapes

A program is a shape whose transformation structure defines how to produce new shapes from input character. The domain volume template is a program. A sound change rule set is a program. A compiler is a program.

```
Program {
    id                      // itself a shape
    inputs: []Parameter     // what the user provides
    structure: S            // the transformation rules
    output: ShapeTemplate   // what gets produced
}
```

Running a program: let the current version of S operate over initial condition C. The engine applies the transformation at each step, recording each change to the trace. The output is the emergent result.

### Programs Produce Traces

When you run a program, it generates a sequence of changes in the trace. You can:
- Inspect the intermediate states
- Lock any intermediate moment
- Branch from any point in the program's execution
- Re-run with different input character
- Compare outputs across runs

### Example: Domain Volume Program

```
Program "domain-volume" {
    inputs: {
        domain: string,
        emergence_layers: []LayerDef,
        parallel_systems: []SystemDef,
        cross_cutting: []ThemeDef
    }
    structure: {
        // For each topic × each part, create a shape
        // Wire emergence relationships
        // Wire cross-references
        // Set transform functions per part:
        //   Part 3: paper.FormalDerivation
        //   Part 2: paper.TeachingDerivation (derives from Part 3)
        //   Part 1: paper.PractitionerTranslation (derives from Part 2)
        //   Part 4: paper.GeometryDerivation (derives from Part 3)
        //   Part 5: paper.MathDerivation (derives from Parts 3+4)
        //   Part 6: paper.HistoryAnalysis (derives from Parts 3+4+5)
    }
}
```

Apply to Society: produces Volume 8. Apply to Physics: produces Volume 2. Same program, different character.

### Example: Conlang Sound Change Program

```
Program "sound-change" {
    inputs: {
        source_inventory: PhonemeSet,
        rules: []SoundChangeRule,
        lexicon: []LexicalEntry
    }
    structure: {
        // For each rule, in order:
        //   Apply rule to every lexical entry
        //   Record changes
        //   Propagate through morphological paradigms
    }
}
```

Mathematical rules propagate automatically. The engine applies f(C, S) at each step. The trace records the full derivation. Lock the proto-language, run the program, inspect the daughter language. Branch to try different rule orderings.

### Example: D&D Campaign

```
Program "campaign-session" {
    inputs: {
        session_events: []Event,    // what happened at the table
        world_state: ShapeRef       // current world structure
    }
    structure: {
        // Lock session events (canonical, happened)
        // Derive world state changes from events
        // Flag narrative inconsistencies for review
        // Update NPC states, location states, timeline
    }
}
```

Session records are locked nodes. The world structure flexes around them. Retcons unlock a specific derivation node, re-derive the connective structure, lock again. The original derivation persists on its branch. The emergent canonical version follows the retcon.

---

## Transform Library

### Interface

Every transformation function implements one interface:

```
TransformFn {
    apply(C, S) -> M'
    propagate(change, self) -> AutoUpdate | FlagForReview | NoChange
}
```

### Built-in Domains

**Paper domain** (`paper.*`):
- `paper.FormalDerivation` - derive theorems from axioms, flag prose for review
- `paper.TeachingDerivation` - derive educational text from formal counterpart
- `paper.PractitionerTranslation` - translate structural analysis into domain language
- `paper.GeometryDerivation` - derive quantitative geometry from qualitative analysis
- `paper.MathDerivation` - derive mathematical apparatus from geometry
- `paper.HistoryAnalysis` - locate historical figures against structural framework
- `paper.CoherenceCheck` - verify Laws 0-3 along an arc

**Conlang domain** (`conlang.*`):
- `conlang.SoundChange` - apply phonological rules (automatic propagation)
- `conlang.MorphParadigm` - generate morphological paradigm tables
- `conlang.SyntaxRule` - apply syntactic constraints
- `conlang.LexiconDerivation` - derive daughter language lexicon from proto-language

**Worldbuilding domain** (`world.*`):
- `world.NarrativeConsistency` - check timeline and causality
- `world.GeographyConstraint` - verify spatial relationships
- `world.CharacterArc` - track character state across events
- `world.TimelineCheck` - verify temporal ordering

**Programming domain** (`code.*`):
- `code.TypeCheck` - verify type consistency
- `code.Compile` - produce executable from source
- `code.Evaluate` - run and capture output

### Extensibility

Users extend the library by implementing the `TransformFn` interface. A new domain is a new set of transforms. The engine calls the interface. It never knows or cares what domain it's operating in.

Transform libraries can compose: a worldbuilding project that includes conlangs uses both `world.*` and `conlang.*` transforms. The engine wires them through the emergence structure.

---

## Projections

### Projections Are Emergent Shapes

A projection is a shape that emerges from a slice of the structure. A paper is a projection. A lexicon is a projection. A compiled binary is a projection.

```
Projection {
    id                      // itself a shape
    selector: DimQuery      // which shapes to include
    ordering: OrderSpec     // how to sequence them
    format: FormatSpec      // output format
    transforms: []          // output transforms (page breaks, TOC generation, etc.)
}
```

### Example Projections

**Volume PDF**: select all shapes where volume=8, order by part then category then topic then section, format as markdown-to-PDF, transform with title page + structured TOC + page breaks.

**Single topic deep dive**: select all shapes where topic=08a across all parts, order by part (1-6), format as markdown. See one topic at every depth.

**All predictions**: select all shapes where section=predictions across all topics, format as table. See every testable prediction in the volume.

**Conlang dictionary**: select all shapes where type=lexical-entry in the current daughter language, order alphabetically, format as dictionary layout.

**Campaign timeline**: select all locked session events, order chronologically, format as narrative.

### The Paper as Projection

The current paper build pipeline (`papers book N`) is a specific projection: select a volume's shapes, order them by the volume's dimensional structure, render to PDF. The structured TOC we built is part of the projection's transform layer, it reads the dimensional coordinates (part, category, topic) and generates the grouped listing.

The engine replaces the build pipeline. `cuivien project paper vol8` runs the projection. The output is the same PDF. But now you can also run `cuivien project paper vol8 --topic 08a` for a single-topic vertical, or `cuivien project predictions vol8` for the prediction table.

---

## Engine Operations

### Core Commands

| Command | What It Does |
|---------|-------------|
| `engine init <program>` | Initialize a structure from a program template |
| `engine edit <shape>` | Modify a shape's character, append to trace |
| `engine lock <shape> [moment]` | Freeze a moment, block propagation past it |
| `engine unlock <shape>` | Release a lock, trigger resolution cascade |
| `engine branch <name> [from]` | Create an exploration branch at a moment |
| `engine switch <branch>` | Change active branch |
| `engine run <program> <input>` | Execute a program, generating trace entries |
| `engine propagate` | Cascade pending changes through emergence |
| `engine status` | Show stale shapes, locks, pending reviews |
| `engine project <projection>` | Render output from a structural slice |
| `engine verify <arc>` | Run coherence checks along a dependency path |
| `engine history [shape]` | Show trace tree |
| `engine diff <moment-a> <moment-b>` | Compare two moments |

### Workflow

1. `engine init domain-volume --domain society` - creates the dimensional structure
2. `engine edit vol8.08a.part3.structure` - write the foundation
3. `engine lock vol8.08a.part3` - lock what you trust
4. `engine run paper.expand-dimension --dim part4` - add geometry dimension
5. `engine status` - see 21 stale Part 4 shapes needing content
6. `engine edit vol8.08a.part4.generators` - fill in content
7. `engine propagate` - math propagates, text gets flagged
8. `engine unlock vol8.08a.part3` - resolution cascades
9. `engine verify arc.vertical` - check emergence stack coherence
10. `engine project paper vol8` - render the volume PDF

---

## Storage Format

### Directory Structure

```
.cuivien/
  engine.json                   # engine config, dimension registry, active branches
  transforms/                   # transform library (built-in + user extensions)
    paper/
      formal-derivation.lua     # or .wasm, .so, whatever module format
      ...
    conlang/
      sound-change.lua
      ...
  traces/
    layer-0/
      main.seq                  # append-only action log
      exploration-1.seq         # branch
      locks.json
    layer-1/
      main.seq
      ...

shapes/                         # shape files (human-readable, git-friendly)
  vol8/
    08a/
      part3/
        structure.yaml          # shape definition
        polarization.yaml
        ...
      part4/
        generators.yaml
        ...
```

### Shape File Format

```yaml
id: vol8.08a.part3.polarization
character:
  topic: 08a
  part: 3
  section: polarization
  formality: theorem
  content: |
    The economy's dominant axis is capital versus labor.
    Both poles assume value exists and fight over distribution.
    Neither asks where value comes from.
structure:
  transform: paper.FormalDerivation
  deps:
    - vol8.08a.part3.structure
    - 01.theorem12.13
    - 01.law3
  constraints:
    - law0: coherent
    - law1: refs-closed
    - law3: no-contradictions
emergence:
  layer: 3
  from:
    - vol8.08a.part3.shape-definition
    - vol8.08a.part3.transformation-law
  produces:
    - vol8.08a.part3.exclusions
    - vol8.08a.part4.mixing-angles
```

### Trace File Format

Each `.seq` file is a newline-delimited JSON log (append-friendly, streamable):

```jsonl
{"moment":0,"action":"init","root":{"parent":"layer-0/main","moment":12},"ts":"2026-04-05T10:00:00Z"}
{"moment":1,"action":"edit","target":"vol8.08a.part3.structure","delta":{"content":"..."},"ts":"..."}
{"moment":2,"action":"edit","target":"vol8.08a.part3.polarization","delta":{"content":"..."},"ts":"..."}
{"moment":3,"action":"lock","target":"vol8.08a.part3","ts":"..."}
{"moment":4,"action":"branch","name":"alt-exclusions","from_moment":2,"ts":"..."}
{"moment":5,"action":"edit","target":"vol8.08a.part3.exclusions","delta":{"content":"..."},"ts":"..."}
{"moment":6,"action":"unlock","target":"vol8.08a.part3","ts":"..."}
{"moment":7,"action":"propagate","stale":["vol8.08a.part4.generators","vol8.08a.part2.polarization"],"auto_updated":["vol8.08a.part5.constants"],"ts":"..."}
```

---

## Migration Path

### From Current System

The current cuivien system has four components that map to the engine:

| Current | Engine Equivalent |
|---------|------------------|
| shapes/*.md (sgrams, 228 concepts) | Knowledge graph shapes (transform: `knowledge.Connection`) |
| canopy.json (593 claims, dependency chains) | Structural shapes with deps and emergence |
| docs/papers/*.md (126 Vol 8 papers) | Content shapes organized by dimensions |
| projects/*.json (coherence tracking) | Engine state: locks, active branches, verification status |

### Build Sequence

1. **Define the shape file format** and write a converter from current papers to shape files
2. **Implement the trace system** (append-only logs, branching, locking)
3. **Implement the emergence propagation** (staleness computation, cascade)
4. **Implement the projection engine** (replace `papers book` with `engine project`)
5. **Implement the transform interface** and the `paper.*` domain library
6. **Migrate Volume 8** into the engine as the reference implementation
7. **Build remaining volumes using the engine**, each iteration improving the tool
8. **Add conlang domain** transforms, test with language design work
9. **Add worldbuilding domain** transforms
10. **Ship the tool with the data format**

Each step is usable. Step 1 gives structured shape files. Step 4 replaces the current PDF pipeline. Step 6 proves the architecture on real content. The engine grows by being used.

---

## What This Enables

**For the paper canopy**: Edit a theorem in Paper 01. The engine flags every downstream shape across all volumes that derives from that theorem. Mathematical consequences propagate automatically. Prose sections are flagged for review with the specific change that triggered them. The unit of work is one shape, not one paper.

**For conlangs**: Define a proto-language. Apply sound change programs. Branch to explore different daughter languages. Lock the proto-language, compare outcomes. The entire derivation history is preserved. Share the structure: others can explore the same language family.

**For worldbuilding**: Build a world in layers. Lock canonical events. Flex the structure around them. Retcon minimally by unlocking specific derivation nodes. The full creative history persists. Export projections: timeline, atlas, character guide, campaign notes.

**For programming**: Define a type system as shapes. The compiler is a transform library. Type checking is coherence verification. Refactoring is editing structure with automatic propagation.

**For others**: The tool ships with the engine and domain libraries. Open the tool, choose a domain (or compose domains), start building. Share structures in the data format. Others can explore, branch, extend. The creative process is structurally visible and fully recoverable.

---

## References

[1] A. Butler, "A Complete Theory of Persistence," Independent preprint, Zenodo, 2026. doi:10.5281/zenodo.15192553
