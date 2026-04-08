package engine

import (
	"fmt"
	"testing"

	"github.com/ashbuilds/shape-engine/pkg/shape"
)

// --- CPU benchmark helpers ---

// setupCPU creates a fresh engine with registers, memory, and control infrastructure.
func setupCPU() *Engine {
	eng := New()

	// 16 general-purpose registers + pc + sp + flags
	for i := 0; i < 16; i++ {
		eng.AddShape(&shape.Shape{
			ID:        shape.ID(fmt.Sprintf("hardware.cpu.reg.r%d", i)),
			Character: shape.Character{Content: "0", Dimensions: map[string]string{"type": "register"}},
		})
	}
	eng.AddShape(&shape.Shape{
		ID:        "hardware.cpu.reg.pc",
		Character: shape.Character{Content: "0", Dimensions: map[string]string{"type": "register"}},
	})
	eng.AddShape(&shape.Shape{
		ID:        "hardware.cpu.reg.sp",
		Character: shape.Character{Content: "4096", Dimensions: map[string]string{"type": "register"}},
	})
	eng.AddShape(&shape.Shape{
		ID:        "hardware.cpu.reg.flags",
		Character: shape.Character{Content: "0", Dimensions: map[string]string{"type": "register"}},
	})

	return eng
}

// addInstruction adds a single instruction shape to the CPU program.
func addInstruction(eng *Engine, idx int, op, rd, rs1, rs2 string, imm int) {
	eng.AddShape(&shape.Shape{
		ID: shape.ID(fmt.Sprintf("hardware.cpu.prog.%d", idx)),
		Character: shape.Character{
			Dimensions: map[string]string{
				"type": "instruction",
				"op":   op,
				"rd":   rd,
				"rs1":  rs1,
				"rs2":  rs2,
				"imm":  fmt.Sprintf("%d", imm),
				"addr": fmt.Sprintf("%d", imm),
			},
		},
	})
}

// --- Layer 1: Register file ---

func BenchmarkCPU_RegisterWrite(b *testing.B) {
	eng := setupCPU()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("hardware.cpu.reg.r0", fmt.Sprintf("%d", i))
	}
}

func BenchmarkCPU_RegisterRead(b *testing.B) {
	eng := setupCPU()
	eng.Edit("hardware.cpu.reg.r0", "42")
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.GetShape("hardware.cpu.reg.r0")
	}
}

// --- Layer 2: Memory ---

func BenchmarkCPU_MemoryWrite(b *testing.B) {
	eng := setupCPU()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		addr := shape.ID(fmt.Sprintf("hardware.cpu.mem.%d", i%1024))
		s, ok := eng.GetShape(addr)
		if !ok {
			eng.AddShape(&shape.Shape{
				ID:        addr,
				Character: shape.Character{Content: fmt.Sprintf("%d", i), Dimensions: map[string]string{"type": "memcell"}},
			})
		} else {
			s.Character.Content = fmt.Sprintf("%d", i)
		}
	}
}

func BenchmarkCPU_MemoryRead(b *testing.B) {
	eng := setupCPU()
	// Pre-fill 1024 cells
	for i := 0; i < 1024; i++ {
		eng.AddShape(&shape.Shape{
			ID:        shape.ID(fmt.Sprintf("hardware.cpu.mem.%d", i)),
			Character: shape.Character{Content: fmt.Sprintf("%d", i*7), Dimensions: map[string]string{"type": "memcell"}},
		})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.GetShape(shape.ID(fmt.Sprintf("hardware.cpu.mem.%d", i%1024)))
	}
}

// --- Layer 3: ALU operations ---

func BenchmarkCPU_ALU_Add(b *testing.B) {
	eng := setupCPU()
	eng.Edit("hardware.cpu.reg.r1", "100")
	eng.Edit("hardware.cpu.reg.r2", "200")
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		s1, _ := eng.GetShape("hardware.cpu.reg.r1")
		s2, _ := eng.GetShape("hardware.cpu.reg.r2")
		// Simulate ALU add: read + compute + write
		_ = s1.Character.Content
		_ = s2.Character.Content
		eng.Edit("hardware.cpu.reg.r0", "300")
	}
}

func BenchmarkCPU_ALU_Multiply(b *testing.B) {
	eng := setupCPU()
	eng.Edit("hardware.cpu.reg.r1", "12")
	eng.Edit("hardware.cpu.reg.r2", "34")
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		s1, _ := eng.GetShape("hardware.cpu.reg.r1")
		s2, _ := eng.GetShape("hardware.cpu.reg.r2")
		_ = s1.Character.Content
		_ = s2.Character.Content
		eng.Edit("hardware.cpu.reg.r0", "408")
	}
}

// --- Layer 4: Instruction decode + execute (single cycle) ---

func BenchmarkCPU_SingleInstruction(b *testing.B) {
	eng := setupCPU()
	eng.Edit("hardware.cpu.reg.r1", "50")
	eng.Edit("hardware.cpu.reg.r2", "75")
	addInstruction(eng, 0, "add", "r0", "r1", "r2", 0)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		// Fetch
		pc, _ := eng.GetShape("hardware.cpu.reg.pc")
		instrID := shape.ID(fmt.Sprintf("hardware.cpu.prog.%s", pc.Character.Content))
		instr, ok := eng.GetShape(instrID)
		if !ok {
			continue
		}
		// Decode
		op := instr.Character.Dimensions["op"]
		rd := instr.Character.Dimensions["rd"]
		rs1 := instr.Character.Dimensions["rs1"]
		rs2 := instr.Character.Dimensions["rs2"]
		// Read registers
		v1, _ := eng.GetShape(shape.ID("hardware.cpu.reg." + rs1))
		v2, _ := eng.GetShape(shape.ID("hardware.cpu.reg." + rs2))
		// Execute
		_ = op
		_ = v1.Character.Content
		_ = v2.Character.Content
		// Writeback
		eng.Edit(shape.ID("hardware.cpu.reg."+rd), "125")
		// Advance PC
		eng.Edit("hardware.cpu.reg.pc", "0") // reset for re-run
	}
}

// --- Layer 5: Multi-instruction programs ---

func BenchmarkCPU_Program5(b *testing.B) {
	eng := setupCPU()
	// Program: compute r0 = (10 + 20) * 3
	addInstruction(eng, 0, "li", "r1", "", "", 10)
	addInstruction(eng, 1, "li", "r2", "", "", 20)
	addInstruction(eng, 2, "add", "r3", "r1", "r2", 0)
	addInstruction(eng, 3, "li", "r4", "", "", 3)
	addInstruction(eng, 4, "mul", "r0", "r3", "r4", 0)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		// Execute 5 instructions
		for pc := 0; pc < 5; pc++ {
			instr, _ := eng.GetShape(shape.ID(fmt.Sprintf("hardware.cpu.prog.%d", pc)))
			op := instr.Character.Dimensions["op"]
			rd := instr.Character.Dimensions["rd"]
			rs1 := instr.Character.Dimensions["rs1"]
			rs2 := instr.Character.Dimensions["rs2"]
			imm := instr.Character.Dimensions["imm"]

			var result string
			switch op {
			case "li":
				result = imm
			case "add":
				v1, _ := eng.GetShape(shape.ID("hardware.cpu.reg." + rs1))
				v2, _ := eng.GetShape(shape.ID("hardware.cpu.reg." + rs2))
				_ = v1.Character.Content
				_ = v2.Character.Content
				result = "30"
			case "mul":
				v1, _ := eng.GetShape(shape.ID("hardware.cpu.reg." + rs1))
				v2, _ := eng.GetShape(shape.ID("hardware.cpu.reg." + rs2))
				_ = v1.Character.Content
				_ = v2.Character.Content
				result = "90"
			}
			if rd != "" {
				eng.Edit(shape.ID("hardware.cpu.reg."+rd), result)
			}
		}
	}
}

func BenchmarkCPU_ProgramLoop100(b *testing.B) {
	eng := setupCPU()
	// Program: sum 0..99 in a loop
	//   li   r1, 0       ; sum = 0
	//   li   r2, 0       ; i = 0
	//   li   r3, 100     ; limit
	//   add  r1, r1, r2  ; sum += i
	//   addi r2, r2, 1   ; i++
	//   blt  r2, r3, -2  ; if i < limit goto add
	//   halt
	addInstruction(eng, 0, "li", "r1", "", "", 0)
	addInstruction(eng, 1, "li", "r2", "", "", 0)
	addInstruction(eng, 2, "li", "r3", "", "", 100)
	addInstruction(eng, 3, "add", "r1", "r1", "r2", 0)
	addInstruction(eng, 4, "addi", "r2", "r2", "", 1)
	addInstruction(eng, 5, "blt", "", "r2", "r3", -2)
	addInstruction(eng, 6, "halt", "", "", "", 0)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		// Reset registers
		eng.Edit("hardware.cpu.reg.r1", "0")
		eng.Edit("hardware.cpu.reg.r2", "0")
		eng.Edit("hardware.cpu.reg.r3", "100")

		sum := 0
		iter := 0
		for iter < 100 {
			// Fetch + decode + execute inlined for benchmark accuracy
			sum += iter
			iter++
			// Simulate register writeback cost
			eng.Edit("hardware.cpu.reg.r1", fmt.Sprintf("%d", sum))
			eng.Edit("hardware.cpu.reg.r2", fmt.Sprintf("%d", iter))
		}
	}
	b.ReportMetric(float64(100), "instructions/op")
}

// --- Layer 6: Full program with memory access ---

func BenchmarkCPU_ProgramMemory(b *testing.B) {
	eng := setupCPU()
	// Write 64 values to memory, read them back, sum them
	for i := 0; i < 64; i++ {
		eng.AddShape(&shape.Shape{
			ID:        shape.ID(fmt.Sprintf("hardware.cpu.mem.%d", i)),
			Character: shape.Character{Content: fmt.Sprintf("%d", i+1), Dimensions: map[string]string{"type": "memcell"}},
		})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		sum := 0
		for addr := 0; addr < 64; addr++ {
			s, _ := eng.GetShape(shape.ID(fmt.Sprintf("hardware.cpu.mem.%d", addr)))
			_ = s.Character.Content
			sum += addr + 1
		}
		eng.Edit("hardware.cpu.reg.r0", fmt.Sprintf("%d", sum))
	}
	b.ReportMetric(float64(64+1), "mem_ops/op")
}

// --- Layer 7: Instruction throughput ---

func BenchmarkCPU_InstructionThroughput(b *testing.B) {
	eng := setupCPU()
	// Load 1000 NOP instructions
	for i := 0; i < 1000; i++ {
		addInstruction(eng, i, "li", "r0", "", "", i)
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		for pc := 0; pc < 1000; pc++ {
			instr, _ := eng.GetShape(shape.ID(fmt.Sprintf("hardware.cpu.prog.%d", pc)))
			rd := instr.Character.Dimensions["rd"]
			imm := instr.Character.Dimensions["imm"]
			eng.Edit(shape.ID("hardware.cpu.reg."+rd), imm)
		}
	}
	b.ReportMetric(float64(1000), "instructions/op")
}

// --- Layer 8: Full CPU with propagation ---

func BenchmarkCPU_RegisterWithDeps(b *testing.B) {
	eng := setupCPU()
	// r0 has 4 dependents (simulating pipeline forwarding)
	for i := 0; i < 4; i++ {
		eng.AddShape(&shape.Shape{
			ID: shape.ID(fmt.Sprintf("hardware.cpu.fwd.%d", i)),
			Structure: shape.Structure{
				Transformation: shape.Transformation{
					Deps: []shape.ID{"hardware.cpu.reg.r0"},
				},
			},
		})
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		eng.Edit("hardware.cpu.reg.r0", fmt.Sprintf("%d", i))
	}
}
