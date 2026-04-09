shape theory.computing.ucisc.devices : theory.computing.ucisc.memory {
  type: structure
  layer: 0
  """
// uCISC Device Model.
//
// Up to 256 devices, all memory-mapped. No special I/O
// instructions. Reading a device = reading an address.
// Writing a device = writing an address. The device IS
// a region of the address space.
//
// Device types:
//   0x00 Missing/Invalid    No device present
//   0x01 Processor          Multiprocessor systems
//   0x02 Block Memory       RAM/ROM storage
//   0x03 Block I/O          Generic block I/O
//   0x04 Serial/UART        Serial communication
//   0x05 HID                Keyboard, mouse, joystick
//   0x06 Terminal            Full terminal device
//   0x07 Raster Graphics    Video display
//   0x08 GPIO               General purpose I/O pins
//   0x09 I2C                I2C bus controller
//   0x0A SPI                SPI bus controller
//   0x0D Debug              Debug/assertion device
//
// Device discovery (boot):
//   Scan devices 0-255. Read type at (N * 0x10 + 1).
//   Type 0x00 = empty slot. Build device table.
//
// Typical device layout:
//   0x000: Current processor
//   0x010: GPIO pins
//   0x020: Realtime clock
//   0x030-0x0F0: Motherboard devices (13 slots)
//   0x100-0x270: I/O bus devices (UART, I2C, SPI, etc.)
//   0x280-0x3F0: Block memory (RAM, ROM)
//   0x400-0x5F0: Block I/O (storage)
//   0x800-0xFF0: Other processors (multiprocessor)
//
// Video device (type 0x07):
//   Control registers at (N * 0x10).
//   Framebuffer in block memory at (N * 0x100).
//   Resolution, pixel format, vsync in control regs.
//
// The device model is the same as Shape OS: devices are shapes
// in the address space. Reading a device is reading a shape.
// Writing a device is editing a shape. No driver abstraction
// needed: the memory map IS the driver.
//
// Derives from: theory.computing.ucisc.memory
  """
}
