// Shape - coherence shell.
//
// Usage:
//
//	shape <program> [shapes...]   # What coheres with these shapes?
//	shape compile <file.shape>    # Compile text to binary
//
// Or register as shell/interpreter:
//
//	#!/usr/bin/env shape
//
// Then: ./program.shp @alice @knows ?
//
// The program is a shape structure. Arguments are shapes.
// Output is what coheres.
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		repl(nil, nil)
		return
	}

	// Special: compile command
	if os.Args[1] == "compile" {
		if len(os.Args) < 3 {
			fmt.Println("Usage: shape compile <file.shape>")
			return
		}
		compile(os.Args[2])
		return
	}

	// Load program
	program := os.Args[1]
	emu, parser, err := load(program)
	if err != nil {
		fmt.Printf("Error loading %s: %v\n", program, err)
		return
	}

	// No query args = interactive mode
	if len(os.Args) == 2 {
		repl(emu, parser)
		return
	}

	// Query: args become shapes, find what coheres
	args := os.Args[2:]
	results, bindings := queryFromArgs(emu, parser, args)

	// If we have bindings and they differ from results, print bindings
	if len(bindings) > 0 {
		for _, id := range bindings {
			s := emu.Get(id)
			if s != nil {
				printValue(s)
				fmt.Println()
			}
		}
	} else {
		printResults(emu, results)
	}
}

// load reads a program (.shp binary or .shape text)
func load(path string) (*Emulator, *Parser, error) {
	emu := NewEmulator()
	parser := NewParser(emu)

	if strings.HasSuffix(path, ".shp") {
		// Binary - load shapes and names
		names, err := emu.LoadPagesWithNames(path)
		if err != nil {
			return nil, nil, err
		}
		parser.SetNames(names)
	} else {
		// Text - parse (ParseFile sets baseDir for relative paths)
		if err := parser.ParseFile(path); err != nil {
			return nil, nil, err
		}
	}

	// Run coherence pass FIRST - collapse duplicate shapes
	// This ensures format engine finds canonical predicates
	emu.CoherencePass()

	// Track shape count before format engine
	shapeCountBefore := len(emu.shapes)

	// Run format coherence - derives shapes from files with formats
	fe := NewFormatEngine(emu, parser)
	fe.Cohere()

	// Only run second coherence pass if format engine created new shapes
	if len(emu.shapes) > shapeCountBefore {
		emu.CoherencePass()
	}

	// Create scheduler for coherence verification (file existence, etc.)
	// The scheduler uses shortest-coherent-distance algorithm
	emu.scheduler = NewScheduler(emu)

	return emu, parser, nil
}

// queryFromArgs interprets CLI args as a natural query
// 1 arg:  concept -> return its connections
// 2 args: concept predicate -> find (concept predicate ?)
// 3 args: subject predicate object -> match triple (? is wildcard)
func queryFromArgs(emu *Emulator, parser *Parser, args []string) ([]ShapeID, []ShapeID) {
	if len(args) == 0 {
		return nil, nil
	}

	// Resolve args to shape IDs (_ becomes wildcard)
	resolve := func(arg string) ShapeID {
		if arg == "_" {
			return 0 // Wildcard
		}
		// Try name lookup first
		if id := parser.Lookup(arg); id != 0 {
			return id
		}
		// Try as literal value
		for _, s := range emu.shapes {
			if s.Type == TypeString && string(s.V) == arg {
				return s.ID
			}
		}
		return 0
	}

	switch len(args) {
	case 1:
		// Single concept: return its connections
		id := resolve(args[0])
		if id == 0 {
			return nil, nil
		}
		s := emu.Get(id)
		if s == nil {
			return nil, nil
		}
		return s.C, s.C

	case 2:
		// concept predicate: find (concept predicate ?)
		subj := resolve(args[0])
		pred := resolve(args[1])
		return findTriples(emu, subj, pred, 0)

	default:
		// 3+ args: subject predicate object
		subj := resolve(args[0])
		pred := resolve(args[1])
		obj := resolve(args[2])
		return findTriples(emu, subj, pred, obj)
	}
}

// findTriples finds triples matching pattern (0 = wildcard)
func findTriples(emu *Emulator, subj, pred, obj ShapeID) ([]ShapeID, []ShapeID) {
	var results []ShapeID
	var bindings []ShapeID

	// Resolve query parameters to canonical IDs
	subj = emu.Resolve(subj)
	pred = emu.Resolve(pred)
	obj = emu.Resolve(obj)

	for _, s := range emu.shapes {
		if s.Type != TypeList || len(s.C) < 3 {
			continue
		}

		// Resolve connection IDs to canonical forms
		c0 := emu.Resolve(s.C[0])
		c1 := emu.Resolve(s.C[1])
		c2 := emu.Resolve(s.C[2])

		// Match pattern
		match := true
		var binding ShapeID

		if subj != 0 && c0 != subj {
			match = false
		} else if subj == 0 {
			binding = c0
		}

		if match && pred != 0 && c1 != pred {
			match = false
		} else if pred == 0 && match {
			binding = c1
		}

		if match && obj != 0 && c2 != obj {
			match = false
		} else if obj == 0 && match {
			binding = c2
		}

		if match {
			results = append(results, s.ID)
			if binding != 0 {
				bindings = append(bindings, binding)
			}
		}
	}

	return results, bindings
}

// cohere finds shapes that match a query pattern
func cohere(emu *Emulator, parser *Parser, query string) []ShapeID {
	results, _ := cohereWithBindings(emu, parser, query)
	return results
}

// cohereWithBindings finds shapes that match and returns variable bindings
func cohereWithBindings(emu *Emulator, parser *Parser, query string) ([]ShapeID, []ShapeID) {
	query = strings.TrimSpace(query)

	// Simple word query (no parentheses, no @) - find by name or value
	if !strings.HasPrefix(query, "(") && !strings.HasPrefix(query, "@") {
		return findByNameOrValue(emu, parser, query)
	}

	// Reference query (@name) - find by name and return connections
	if strings.HasPrefix(query, "@") && !strings.Contains(query, " ") {
		name := strings.TrimPrefix(query, "@")
		if id := parser.Lookup(name); id != 0 {
			// Return shapes connected to this one
			s := emu.Get(id)
			if s != nil {
				return s.C, s.C
			}
		}
		return nil, nil
	}

	// Triple pattern query
	startID := emu.nextID

	// Handle variable marker
	query = strings.ReplaceAll(query, "@_", "@_var_")
	query = strings.ReplaceAll(query, " _ ", " @_var_ ")

	if err := parser.ParseString(query); err != nil {
		return nil, nil
	}

	// Find query shapes (newly created) - only lists/triples, not variables
	var queryShapes []*Shape
	var queryIDs []ShapeID // Track IDs for cleanup
	for id := startID; id < emu.nextID; id++ {
		queryIDs = append(queryIDs, id)
		if s := emu.Get(id); s != nil && s.Type == TypeList {
			queryShapes = append(queryShapes, s)
		}
	}

	if len(queryShapes) == 0 {
		// Clean up any shapes created during failed parse
		for _, id := range queryIDs {
			emu.Collapse(id)
		}
		return nil, nil
	}

	varID := parser.Lookup("_var_")

	// Find what coheres with query
	var results []ShapeID
	var bindings []ShapeID

	// For each shape in the program, check if it coheres with query
	for id, s := range emu.shapes {
		if id >= startID {
			continue // Skip query shapes themselves
		}
		if binding := matchWithBinding(emu, s, queryShapes, varID); binding != 0 {
			results = append(results, id)
			bindings = append(bindings, binding)
		}
	}

	// Clean up query shapes - they were only needed for matching
	for _, id := range queryIDs {
		emu.Collapse(id)
	}

	return results, bindings
}

// findByNameOrValue finds shapes by name lookup or value match
func findByNameOrValue(emu *Emulator, parser *Parser, query string) ([]ShapeID, []ShapeID) {
	// First try name lookup
	if id := parser.Lookup(query); id != 0 {
		s := emu.Get(id)
		if s != nil {
			// Return connections
			return s.C, s.C
		}
	}

	// Then try value match
	var results []ShapeID
	queryBytes := []byte(query)
	for id, s := range emu.shapes {
		if s.Type == TypeString && bytesEqual(s.V, queryBytes) {
			results = append(results, id)
		}
	}

	return results, results
}

func bytesEqual(a, b []byte) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

// matchWithBinding checks if a shape matches and returns the variable binding
func matchWithBinding(emu *Emulator, s *Shape, query []*Shape, varID ShapeID) ShapeID {
	for _, q := range query {
		// If query is a triple (list with 3 connections), match structure
		if q.Type == TypeList && len(q.C) >= 3 {
			if s.Type != TypeList || len(s.C) < 3 {
				continue
			}

			// Check each position, track binding
			match := true
			var binding ShapeID
			for i := 0; i < 3 && i < len(q.C) && i < len(s.C); i++ {
				qc := q.C[i]
				sc := s.C[i]

				// Variable matches anything - capture binding
				if qc == varID {
					binding = sc
					continue
				}

				// Must be same shape (same ID or same value)
				if qc != sc && !shapesEqual(emu, qc, sc) {
					match = false
					break
				}
			}

			if match {
				if binding == 0 {
					binding = s.ID // Return the shape itself if no variable
				}
				return binding
			}
		}
	}

	return 0
}

// shapesEqual checks if two shapes have equal values
func shapesEqual(emu *Emulator, a, b ShapeID) bool {
	sa, sb := emu.Get(a), emu.Get(b)
	if sa == nil || sb == nil {
		return false
	}
	if sa.Type != sb.Type {
		return false
	}
	if len(sa.V) != len(sb.V) {
		return false
	}
	for i := range sa.V {
		if sa.V[i] != sb.V[i] {
			return false
		}
	}
	return true
}

func printResults(emu *Emulator, results []ShapeID) {
	if len(results) == 0 {
		fmt.Println("No results")
		return
	}

	for _, id := range results {
		s := emu.Get(id)
		if s == nil {
			continue
		}
		printShape(emu, s)
	}
}

func printShape(emu *Emulator, s *Shape) {
	switch s.Type {
	case TypeList:
		// Print as triple if 3 connections
		if len(s.C) >= 3 {
			fmt.Print("(")
			for i, c := range s.C[:3] {
				if i > 0 {
					fmt.Print(" ")
				}
				if cs := emu.Get(c); cs != nil {
					printValue(cs)
				}
			}
			fmt.Println(")")
		}
	default:
		printValue(s)
		fmt.Println()
	}
}

func printValue(s *Shape) {
	switch s.Type {
	case TypeString:
		fmt.Printf("%s", s.V)
	case TypeContent:
		// File content - print as string
		fmt.Printf("%s", s.V)
	case TypeInt:
		// Decode int
		if len(s.V) >= 8 {
			fmt.Printf("%d", int64(s.V[0])|int64(s.V[1])<<8|int64(s.V[2])<<16|int64(s.V[3])<<24)
		}
	default:
		fmt.Printf("[%d:%s]", s.ID, typeName(s.Type))
	}
}

func compile(path string) {
	emu := NewEmulator()
	parser := NewParser(emu)

	f, err := os.Open(path)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}
	defer f.Close()

	if err := parser.Parse(f); err != nil {
		fmt.Printf("Parse error: %v\n", err)
		return
	}

	outPath := strings.TrimSuffix(path, ".shape") + ".shp"
	if err := emu.SavePagesWithNames(outPath, parser.Names()); err != nil {
		fmt.Printf("Save error: %v\n", err)
		return
	}

	fmt.Printf("Compiled %d shapes, %d names -> %s\n", len(emu.shapes), len(parser.Names()), outPath)
}

func repl(emu *Emulator, parser *Parser) {
	if emu == nil {
		emu = NewEmulator()
		parser = NewParser(emu)
	}

	fmt.Println("Shape (Ctrl+D to exit)")
	fmt.Printf("%d shapes loaded\n", len(emu.shapes))
	fmt.Println()

	scanner := bufio.NewScanner(os.Stdin)
	for {
		fmt.Print("> ")
		if !scanner.Scan() {
			break
		}

		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		// Commands
		if line == ":q" || line == ":quit" {
			break
		}
		if line == ":s" || line == ":stats" {
			stats(emu)
			continue
		}
		if line == ":l" || line == ":list" {
			listShapes(emu)
			continue
		}
		if strings.HasPrefix(line, ":save ") {
			path := strings.TrimSpace(line[6:])
			if err := emu.SavePages(path); err != nil {
				fmt.Printf("Error: %v\n", err)
			} else {
				fmt.Printf("Saved %s\n", path)
			}
			continue
		}

		// Query or define
		if strings.HasPrefix(line, "(") || strings.Contains(line, "?") {
			// Query
			results := cohere(emu, parser, line)
			printResults(emu, results)
		} else {
			// Define
			if err := parser.ParseString(line); err != nil {
				fmt.Printf("Error: %v\n", err)
			}
		}
	}
	fmt.Println()
}

func stats(emu *Emulator) {
	typeCounts := make(map[uint8]int)
	for _, s := range emu.shapes {
		typeCounts[s.Type]++
	}
	fmt.Printf("Shapes: %d\n", len(emu.shapes))
	for t, c := range typeCounts {
		fmt.Printf("  %s: %d\n", typeName(t), c)
	}
}

func listShapes(emu *Emulator) {
	for _, s := range emu.shapes {
		printShape(emu, s)
	}
}

func typeName(t uint8) string {
	switch t {
	case TypeNil:
		return "nil"
	case TypeInt:
		return "int"
	case TypeFloat:
		return "float"
	case TypeString:
		return "string"
	case TypeBool:
		return "bool"
	case TypeFile:
		return "file"
	case TypeList:
		return "list"
	case TypeRef:
		return "ref"
	case TypeContent:
		return "content"
	case TypePrint:
		return "print"
	default:
		return fmt.Sprintf("t%d", t)
	}
}
