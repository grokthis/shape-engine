shape theory.computing.boot : theory.computing.system, theory.computing.io {
  type: structure
  layer: 0
  """
// Layer 10: Power-On and Boot Sequence.
//
// The power button is the forcing shape that brings the
// computer from dissolution to coherence.
//
// POWER BUTTON:
//   Momentary switch connecting ATX power supply PS_ON# to ground.
//   Press: PS_ON# goes low. Power supply activates.
//   The power supply converts AC mains (120/240V, 50/60Hz) to
//   DC rails: +12V (CPU, GPU), +5V (peripherals), +3.3V (logic).
//   Power good signal: PSU asserts after voltages stabilize
//   (~100-500ms). This releases the CPU reset line.
//
// RESET SEQUENCE:
//   CPU reset pin deasserted. CPU begins executing.
//   All registers cleared. All caches empty. All TLBs empty.
//   Pipeline empty. No instructions in flight.
//   PC loaded with reset vector: a fixed address (typically
//   0xFFFFFFF0 on x86, 0x0 on many RISC).
//   The computer is in its minimal state: structure present,
//   character absent. This is the hardware empty_s.
//
// FIRMWARE (BIOS/UEFI):
//   First code executed. Stored in flash ROM on motherboard.
//   POST (Power-On Self-Test):
//     Test CPU: execute simple instructions, verify results.
//     Test memory: write patterns, read back, check.
//     Enumerate PCI/PCIe devices.
//     Initialize display (basic text mode).
//     Beep codes if failure (no display = use speaker).
//   POST is coherence checking: verify that every component
//   satisfies its structural specification. If any test fails,
//   the system halts (incoherent hardware cannot persist as
//   a functioning computer).
//
// BOOTLOADER:
//   Firmware reads first sector of boot device (SSD).
//   Bootloader loaded to memory. Firmware transfers control.
//   Bootloader (e.g., GRUB): locates kernel on filesystem,
//     loads it to memory, passes control with boot parameters.
//
// KERNEL INITIALIZATION:
//   Set up page tables (virtual memory).
//   Initialize interrupt handlers.
//   Detect and initialize hardware (device drivers).
//   Mount root filesystem.
//   Start init process (PID 1).
//
// INIT -> USERSPACE:
//   Init process starts system services.
//   Services start in dependency order (each service is a shape
//   that depends on other shapes: network depends on NIC driver,
//   GUI depends on display driver, etc.).
//   Login prompt appears. The computer is fully coherent:
//   every layer from silicon to userspace is operational.
//
// POWER OFF:
//   Shutdown sequence: reverse of boot.
//   Userspace processes terminated (SIGTERM, then SIGKILL).
//   Filesystems synced and unmounted.
//   Kernel halts.
//   ACPI power-off: firmware signals PSU to cut power.
//   PS_ON# goes high. Voltages drop. Capacitors discharge.
//   DRAM state lost (volatile). SSD state persists (non-volatile).
//   The computer returns to its powered-off state: structure
//   present (silicon, wires, components), character absent
//   (no voltages, no state, no computation).
//   The shape persists structurally but has no moment sequence
//   until power returns.
//
// Derives from: theory.computing.system, theory.computing.io
  """
}
