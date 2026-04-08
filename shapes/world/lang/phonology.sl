// Phonology: the sound system as shapes.
//
// Each phoneme IS a shape with articulatory dimensions:
//   place: where in the mouth (bilabial, alveolar, velar, glottal...)
//   manner: how air flows (stop, fricative, nasal, approximant...)
//   voicing: vocal cord vibration (voiced, voiceless)
//   height/backness/rounding: for vowels
//
// The IPA IS the shape graph of human speech sounds.
// Any natural or constructed language selects a subset.
//
// On the FPGA: each phoneme is a waveform shape in the audio system.
// The phonology connects to the audio oscillators. Speaking IS rendering.

shape world.lang.phonology : world.lang {
  type: system
  layer: 5
  deps: [hardware.audio]
  "Sound system. Phonemes are shapes with articulatory dimensions."
}

shape world.lang.phonology.consonants : world.lang.phonology {
  type: data
  layer: 5
  """
// Consonant inventory. IPA symbols with articulatory features.
// Each consonant IS a shape: its structure IS its articulation.

// Stops (plosives): complete closure then release
add_shape("world.lang.phone.p", "phone", "p", 5)
set_dim("world.lang.phone.p", "manner", "stop")
set_dim("world.lang.phone.p", "place", "bilabial")
set_dim("world.lang.phone.p", "voicing", "voiceless")

add_shape("world.lang.phone.b", "phone", "b", 5)
set_dim("world.lang.phone.b", "manner", "stop")
set_dim("world.lang.phone.b", "place", "bilabial")
set_dim("world.lang.phone.b", "voicing", "voiced")

add_shape("world.lang.phone.t", "phone", "t", 5)
set_dim("world.lang.phone.t", "manner", "stop")
set_dim("world.lang.phone.t", "place", "alveolar")
set_dim("world.lang.phone.t", "voicing", "voiceless")

add_shape("world.lang.phone.d", "phone", "d", 5)
set_dim("world.lang.phone.d", "manner", "stop")
set_dim("world.lang.phone.d", "place", "alveolar")
set_dim("world.lang.phone.d", "voicing", "voiced")

add_shape("world.lang.phone.k", "phone", "k", 5)
set_dim("world.lang.phone.k", "manner", "stop")
set_dim("world.lang.phone.k", "place", "velar")
set_dim("world.lang.phone.k", "voicing", "voiceless")

add_shape("world.lang.phone.g", "phone", "g", 5)
set_dim("world.lang.phone.g", "manner", "stop")
set_dim("world.lang.phone.g", "place", "velar")
set_dim("world.lang.phone.g", "voicing", "voiced")

// Fricatives: turbulent airflow through narrow gap
add_shape("world.lang.phone.f", "phone", "f", 5)
set_dim("world.lang.phone.f", "manner", "fricative")
set_dim("world.lang.phone.f", "place", "labiodental")
set_dim("world.lang.phone.f", "voicing", "voiceless")

add_shape("world.lang.phone.v", "phone", "v", 5)
set_dim("world.lang.phone.v", "manner", "fricative")
set_dim("world.lang.phone.v", "place", "labiodental")
set_dim("world.lang.phone.v", "voicing", "voiced")

add_shape("world.lang.phone.s", "phone", "s", 5)
set_dim("world.lang.phone.s", "manner", "fricative")
set_dim("world.lang.phone.s", "place", "alveolar")
set_dim("world.lang.phone.s", "voicing", "voiceless")

add_shape("world.lang.phone.z", "phone", "z", 5)
set_dim("world.lang.phone.z", "manner", "fricative")
set_dim("world.lang.phone.z", "place", "alveolar")
set_dim("world.lang.phone.z", "voicing", "voiced")

add_shape("world.lang.phone.sh", "phone", "ʃ", 5)
set_dim("world.lang.phone.sh", "manner", "fricative")
set_dim("world.lang.phone.sh", "place", "postalveolar")
set_dim("world.lang.phone.sh", "voicing", "voiceless")

add_shape("world.lang.phone.h", "phone", "h", 5)
set_dim("world.lang.phone.h", "manner", "fricative")
set_dim("world.lang.phone.h", "place", "glottal")
set_dim("world.lang.phone.h", "voicing", "voiceless")

add_shape("world.lang.phone.th", "phone", "θ", 5)
set_dim("world.lang.phone.th", "manner", "fricative")
set_dim("world.lang.phone.th", "place", "dental")
set_dim("world.lang.phone.th", "voicing", "voiceless")

// Nasals: air through nose
add_shape("world.lang.phone.m", "phone", "m", 5)
set_dim("world.lang.phone.m", "manner", "nasal")
set_dim("world.lang.phone.m", "place", "bilabial")
set_dim("world.lang.phone.m", "voicing", "voiced")

add_shape("world.lang.phone.n", "phone", "n", 5)
set_dim("world.lang.phone.n", "manner", "nasal")
set_dim("world.lang.phone.n", "place", "alveolar")
set_dim("world.lang.phone.n", "voicing", "voiced")

add_shape("world.lang.phone.ng", "phone", "ŋ", 5)
set_dim("world.lang.phone.ng", "manner", "nasal")
set_dim("world.lang.phone.ng", "place", "velar")
set_dim("world.lang.phone.ng", "voicing", "voiced")

// Approximants: smooth airflow
add_shape("world.lang.phone.l", "phone", "l", 5)
set_dim("world.lang.phone.l", "manner", "lateral")
set_dim("world.lang.phone.l", "place", "alveolar")
set_dim("world.lang.phone.l", "voicing", "voiced")

add_shape("world.lang.phone.r", "phone", "r", 5)
set_dim("world.lang.phone.r", "manner", "approximant")
set_dim("world.lang.phone.r", "place", "alveolar")
set_dim("world.lang.phone.r", "voicing", "voiced")

add_shape("world.lang.phone.w", "phone", "w", 5)
set_dim("world.lang.phone.w", "manner", "approximant")
set_dim("world.lang.phone.w", "place", "labial_velar")
set_dim("world.lang.phone.w", "voicing", "voiced")

add_shape("world.lang.phone.j", "phone", "j", 5)
set_dim("world.lang.phone.j", "manner", "approximant")
set_dim("world.lang.phone.j", "place", "palatal")
set_dim("world.lang.phone.j", "voicing", "voiced")
"""
}

shape world.lang.phonology.vowels : world.lang.phonology {
  type: data
  layer: 5
  """
// Vowel inventory. Dimensions: height, backness, rounding.
// The vowel space IS a 3D shape. Each vowel IS a point in that space.

add_shape("world.lang.phone.a", "phone", "a", 5)
set_dim("world.lang.phone.a", "type", "vowel")
set_dim("world.lang.phone.a", "height", "open")
set_dim("world.lang.phone.a", "backness", "central")
set_dim("world.lang.phone.a", "rounding", "unrounded")

add_shape("world.lang.phone.e", "phone", "e", 5)
set_dim("world.lang.phone.e", "type", "vowel")
set_dim("world.lang.phone.e", "height", "close_mid")
set_dim("world.lang.phone.e", "backness", "front")
set_dim("world.lang.phone.e", "rounding", "unrounded")

add_shape("world.lang.phone.i", "phone", "i", 5)
set_dim("world.lang.phone.i", "type", "vowel")
set_dim("world.lang.phone.i", "height", "close")
set_dim("world.lang.phone.i", "backness", "front")
set_dim("world.lang.phone.i", "rounding", "unrounded")

add_shape("world.lang.phone.o", "phone", "o", 5)
set_dim("world.lang.phone.o", "type", "vowel")
set_dim("world.lang.phone.o", "height", "close_mid")
set_dim("world.lang.phone.o", "backness", "back")
set_dim("world.lang.phone.o", "rounding", "rounded")

add_shape("world.lang.phone.u", "phone", "u", 5)
set_dim("world.lang.phone.u", "type", "vowel")
set_dim("world.lang.phone.u", "height", "close")
set_dim("world.lang.phone.u", "backness", "back")
set_dim("world.lang.phone.u", "rounding", "rounded")
"""
}
