shape theory.computing.ucisc.registers : theory.computing.ucisc {
  type: structure
  layer: 0
  """
// uCISC Register File.
//
// 6 general-purpose registers + 4 special registers.
// Each register is 16 bits. Each can be used as:
//   - Value: the register's contents (&r1 syntax)
//   - Pointer: dereference as memory address (r1 syntax)
//   - Pointer+offset: address + immediate (r1/10 syntax)
//
// General purpose:
//   r1, r2, r3: local memory pointers / values
//   r5, r6, r7: bankable pointers / values
//                When banking bit set, these address device
//                memory instead of local memory.
//   (r4 does not exist - encoding 4 is used for special regs)
//
// Special:
//   pc (0.reg):       Program counter. Source=current address.
//                     Destination=jump target.
//   val (4.val):      Immediate value. Source only.
//                     Returns the sign-extended immediate field.
//   banking (4.reg):  Banking control. Destination only.
//                     Each bit controls which register accesses
//                     device memory: bit1=r1, bit2=r2, bit3=r3,
//                     bit5=r5, bit6=r6, bit7=r7.
//   flags (8.reg):    Status and control flags (R/W).
//   interrupt (12.reg): Interrupt control register.
//
// Source encodings (4 bits):
//   0x0: pc          0x4: val        0x8: flags      0xC: interrupt
//   0x1: r1.mem      0x5: &r1        0x9: r5.mem     0xD: &r5
//   0x2: r2.mem      0x6: &r2        0xA: r6.mem     0xE: &r6
//   0x3: r3.mem      0x7: &r3        0xB: r7.mem     0xF: &r7
//
// Destination encodings (4 bits):
//   0x0: pc          0x4: banking    0x8: flags      0xC: interrupt
//   0x1: r1.mem      0x5: &r1        0x9: r5.mem     0xD: &r5
//   0x2: r2.mem      0x6: &r2        0xA: r6.mem     0xE: &r6
//   0x3: r3.mem      0x7: &r3        0xB: r7.mem     0xF: &r7
//
// The register file is small by design. Six registers is
// enough to hold a frame pointer, stack pointer, two operands,
// a scratch register, and a device pointer. Anything more is
// memory. The simplicity is the point.
//
// Derives from: theory.computing.ucisc
  """
}
