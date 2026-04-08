shape theory.computing.c64.cia : theory.computing.c64 {
  type: unit
  layer: 0
  """
// MOS 6526 CIA (Complex Interface Adapter) x 2.
//
// Two identical CIAs handle I/O, timers, and serial communication.
// Each has 16 registers.
//
// CIA1 ($DC00-$DC0F): keyboard, joystick port 2, timer A/B.
// CIA2 ($DD00-$DD0F): serial bus, user port, VIC bank, timer A/B.
//
// Registers (per CIA):
//   $x0  Port A data (CIA1: keyboard column drive)
//   $x1  Port B data (CIA1: keyboard row read)
//   $x2  Port A data direction
//   $x3  Port B data direction
//   $x4  Timer A low byte
//   $x5  Timer A high byte
//   $x6  Timer B low byte
//   $x7  Timer B high byte
//   $x8  TOD 10ths of seconds (BCD)
//   $x9  TOD seconds (BCD)
//   $xA  TOD minutes (BCD)
//   $xB  TOD hours (BCD, bit 7 = AM/PM)
//   $xC  Serial shift register
//   $xD  Interrupt control/status:
//     Bit 0: Timer A underflow
//     Bit 1: Timer B underflow
//     Bit 2: TOD alarm
//     Bit 3: Serial shift register full/empty
//     Bit 4: FLAG pin (accent key on CIA1)
//     Bit 7: Read: any interrupt occurred. Write: set/clear mask.
//   $xE  Timer A control:
//     Bit 0: Start timer
//     Bit 1: Port B bit 6 output mode
//     Bit 2: Port B toggle/pulse
//     Bit 3: One-shot/continuous
//     Bit 4: Force reload
//     Bit 5: Timer counts: 0=phi2 clock, 1=CNT pin
//     Bit 6: Serial direction (0=in, 1=out)
//     Bit 7: TOD frequency (0=60Hz, 1=50Hz)
//   $xF  Timer B control:
//     Bit 0-4: same as Timer A
//     Bit 5-6: Timer B counts: 00=phi2, 01=CNT, 10=Timer A, 11=Timer A + CNT
//
// Keyboard matrix (CIA1):
//   8x8 matrix. CIA1 Port A drives columns, Port B reads rows.
//   To scan: write a 0 to one column bit in Port A, read Port B.
//   Bits that read 0 = keys pressed in that column.
//   Full scan: 8 writes + 8 reads = 16 bus cycles.
//
// CIA1 also handles:
//   Joystick port 2 (bits 0-4 of Port A/B depending on direction)
//   Lightpen input (directly to VIC-II)
//
// CIA2 handles:
//   $DD00 bits 0-1: VIC-II bank select (4 x 16KB banks)
//     00 = bank 3 ($C000-$FFFF)
//     01 = bank 2 ($8000-$BFFF)
//     10 = bank 1 ($4000-$7FFF)
//     11 = bank 0 ($0000-$3FFF) [default]
//   Serial bus: IEC bus for disk drive (1541), printer, etc.
//   User port: directly accessible 8-bit parallel port.
//   NMI: CIA2 interrupts generate NMI (non-maskable).
//
// Timer timing: counts down from latch value each phi2 cycle.
//   At 0: underflow. Optionally reload from latch, generate IRQ.
//   Timer A cascading into Timer B: 32-bit timer capability.
//
// TOD (Time of Day): real-time clock, counts from AC power
//   frequency (50/60 Hz input on TOD pin). BCD format.
//   Alarm: can trigger interrupt when TOD matches alarm time.
//
// Derives from: theory.computing.c64
  """
}
