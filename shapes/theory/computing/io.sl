shape theory.computing.io : theory.computing.system {
  type: structure
  layer: 0
  """
// Layer 9: Input/Output.
//
// I/O devices are the contact boundary between the computer
// shape and the external world. Each device converts between
// internal representation (bits) and external structure
// (light, sound, mechanical motion, electromagnetic signal).
//
// Keyboard (input):
//   Switch matrix: rows x columns of key switches.
//   Scan: controller drives rows, reads columns.
//   Key press -> scan code -> interrupt -> driver -> character.
//   The keyboard is how human character enters the computer's
//   transformation. It is mutual contact (Definition 5.3):
//   the human and computer in bilateral coupling.
//
// Display (output):
//   Framebuffer: 2D array of pixels in DRAM.
//   Each pixel: RGB color (8 bits each = 24 bits, 16M colors).
//   Resolution: 3840 x 2160 (4K) = 8.3M pixels.
//   Framebuffer size: 8.3M x 4 bytes = ~33 MB.
//   Display controller: reads framebuffer, drives display at
//     60-144 Hz refresh rate.
//   GPU (Graphics Processing Unit): massively parallel processor
//     specialized for pixel computation. Thousands of simple
//     cores executing the same operation on different data (SIMD).
//     The GPU computes what the framebuffer contains; the display
//     controller sends it to the screen.
//
// Storage (persistent I/O):
//   SSD (Solid State Drive): NAND flash memory.
//     Organized as pages (4KB write unit) and blocks (256KB
//     erase unit). Read: ~20us. Write: ~200us. Erase: ~2ms.
//     Flash translation layer (FTL): maps logical to physical
//     addresses, handles wear leveling and garbage collection.
//   Capacity: 1-8 TB. Bandwidth: 3-7 GB/s (NVMe).
//   Storage is where state persists across power cycles.
//   This is the hardware implementation of persistent memory:
//   the moment sequence survives power-off.
//
// Network (I/O):
//   NIC (Network Interface Controller): sends/receives packets.
//   Ethernet: frames of bytes on a wire or fiber.
//   The network is mutual contact between computers:
//   each computer's character enters the other's transformation.
//
// Timer:
//   Crystal oscillator: quartz crystal vibrating at precise
//   frequency. The system clock. Typically 100 MHz base,
//   PLL-multiplied to 3-5 GHz for the CPU core.
//   The timer is the physical tick: the discrete moment
//   boundary of the hardware transformation law.
//
// Derives from: theory.computing.system
  """
}
