// Audio: sound synthesis as shapes.
//
// A sample IS a shape with an amplitude value.
// A waveform IS a sequence of sample shapes.
// An oscillator IS a shape that generates waveforms.
// A filter IS a structural transform on a waveform.
// A mixer IS composition of waveform shapes.
//
// Sound IS wave propagation. Literally.

shape hardware.audio : hardware {
  type: system
  layer: 2
  "Audio synthesis and processing. Oscillators, filters, mixers. Sound IS shapes."
}

shape hardware.audio.oscillator : hardware.audio {
  type: exec
  layer: 2
  """
// Generate a waveform buffer.
// waveform: "sine", "square", "saw", "triangle"
// freq: frequency in Hz
// duration: length in samples (at 44100 Hz)
// amplitude: 0-255
//
// The waveform IS a shape: its structure IS its frequency and phase.
// A sine wave IS a rotation. A square wave IS a threshold.
// A saw wave IS a ramp. A triangle IS a fold.

let sample_rate = 44100
let samples = duration
let period = sample_rate / freq
let buf = ""

for i in range(samples) {
  let phase = mod(i, period)
  let t = phase * 256 / period
  let value = 128

  if waveform == "sine" {
    // Approximate sine with parabola: 4t(1-t) mapped to [0,255]
    let norm = t * 2 / 256
    if norm < 1 {
      set value = 128 + amplitude * (4 * norm * (1 - norm) - 1) / 2
    } else {
      set norm = norm - 1
      set value = 128 - amplitude * (4 * norm * (1 - norm) - 1) / 2
    }
  } else if waveform == "square" {
    set value = if_val(t < 128, 128 + amplitude / 2, 128 - amplitude / 2)
  } else if waveform == "saw" {
    set value = 128 - amplitude / 2 + t * amplitude / 256
  } else if waveform == "triangle" {
    if t < 128 {
      set value = 128 - amplitude / 2 + t * amplitude / 128
    } else {
      set value = 128 + amplitude / 2 - (t - 128) * amplitude / 128
    }
  }

  if buf != "" { set buf = buf + "," }
  set buf = buf + to_string(value)
}

buf
"""
}

shape hardware.audio.mixer : hardware.audio {
  type: exec
  layer: 2
  """
// Mix two audio buffers by averaging samples.
// a, b: comma-separated sample strings.
// The mix IS structural composition: two waveforms become one.

let sa = split(a, ",")
let sb = split(b, ",")
let n = min_num([len(sa), len(sb)])
let out = ""
for i in range(n) {
  let va = to_int(index(sa, i))
  let vb = to_int(index(sb, i))
  let mixed = (va + vb) / 2
  if out != "" { set out = out + "," }
  set out = out + to_string(mixed)
}
out
"""
}

shape hardware.audio.to_wav : hardware.audio {
  type: exec
  layer: 2
  """
// Export audio buffer as WAV file header info.
// The WAV format IS a shape: header + data.
// Header dimensions: sample_rate, bits_per_sample, channels, data_length.
// Data: the sample buffer.
//
// This is the projection from audio shapes to a file format.
// Same as framebuffer.to_ppm projects pixels to an image format.

let samples = split(buf, ",")
let n = len(samples)
let sr = default(sample_rate, "44100")
let bits = "8"
let channels = "1"

print("RIFF WAV")
print("Sample rate: " + sr)
print("Bits: " + bits)
print("Channels: " + channels)
print("Samples: " + to_string(n))
print("Duration: " + to_string(n / to_int(sr)) + "s")
"""
}
