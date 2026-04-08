shape theory.computing.c64.sid : theory.computing.c64 {
  type: unit
  layer: 0
  """
// MOS 6581/8580 SID (Sound Interface Device).
//
// The SID is the most sophisticated sound chip of its era.
// 3 voices, each with independent waveform, ADSR envelope,
// frequency, and pulse width. Plus a programmable filter.
//
// Clock: CPU clock / 1 = 1.022727 MHz (NTSC).
// Sample rate: CPU clock (each cycle updates the waveform).
//
// Registers ($D400-$D41C, 29 registers):
//
// Voice 1 ($D400-$D406):
//   $D400-$D401  Frequency (16-bit, F = Fclk * Freg / 16777216)
//   $D402-$D403  Pulse width (12-bit, duty cycle for pulse wave)
//   $D404        Control register:
//     Bit 0: GATE (1=start ADSR, 0=release)
//     Bit 1: SYNC (synchronize with voice 3)
//     Bit 2: RING (ring modulate with voice 3)
//     Bit 3: TEST (halt oscillator)
//     Bit 4: TRIANGLE waveform select
//     Bit 5: SAWTOOTH waveform select
//     Bit 6: PULSE waveform select
//     Bit 7: NOISE waveform select
//   $D405        Attack/Decay (4 bits each)
//   $D406        Sustain/Release (4 bits each)
//
// Voice 2 ($D407-$D40D): same layout.
// Voice 3 ($D40E-$D414): same layout.
//
// Filter ($D415-$D418):
//   $D415-$D416  Filter cutoff frequency (11-bit)
//   $D417        Filter resonance (4-bit) + filter input select
//   $D418        Volume (4-bit) + filter mode:
//     Bit 4: Low-pass
//     Bit 5: Band-pass
//     Bit 6: High-pass
//     Bit 7: Mute voice 3 (for reading paddle/noise)
//
// Read registers:
//   $D419        Paddle X (analog input, 8-bit)
//   $D41A        Paddle Y
//   $D41B        Voice 3 oscillator output (8-bit, for RNG)
//   $D41C        Voice 3 envelope output (8-bit)
//
// ADSR timing (cycles per step):
//   Attack:  2, 8, 16, 24, 38, 56, 68, 80,
//            100, 250, 500, 800, 1000, 3000, 5000, 8000
//   Decay/Release: same values x 3
//
// Waveforms (per cycle, 24-bit accumulator):
//   Triangle: |2*acc - max| (fold at midpoint)
//   Sawtooth: acc (linear ramp)
//   Pulse: acc > pw ? max : 0 (square wave with variable duty)
//   Noise: LFSR (23-bit, XOR feedback from bits 17 and 22)
//   Combined: waveform outputs AND'd (unique SID behavior)
//
// Filter: 12 dB/octave state-variable filter.
//   Cutoff: Fc = Fclk * (Freg / 2^11) (approximately)
//   Resonance: Q factor from 0 (none) to 15 (self-oscillating)
//   The 6581's filter has analog component variations that give
//   each chip a unique sound. The 8580 is cleaner.
//
// The SID's sound is cycle-accurate: every CPU cycle advances
// the oscillator accumulators, envelope counters, and filter
// state. Changing a register mid-waveform produces the change
// at that exact cycle.
//
// Derives from: theory.computing.c64
  """
}
