shape theory.computing.peripheral.storage : theory.computing.peripheral, theory.computing.memory.dram {
  type: unit
  layer: 0
  """
// Storage Protocol.
//
// Storage is persistent memory: state survives power cycles.
// The protocol maps between the volatile world (DRAM, registers)
// and the persistent world (flash, disk).
//
// Block device abstraction:
//   Storage is addressed in blocks (512B or 4KB).
//   Operations: read_block(lba) -> data, write_block(lba, data).
//   LBA (Logical Block Address): linear address space.
//   The device handles physical mapping internally.
//
// Command queue:
//   Host submits commands to a submission queue in DRAM.
//   Device fetches commands via DMA.
//   Device executes commands (possibly out of order for
//     optimization: adjacent LBAs merged, seeks minimized).
//   Device posts completion to a completion queue in DRAM.
//   Device interrupts host on completion.
//   Queue depth: 64K commands outstanding.
//
// SSD internals (NAND flash):
//   Pages (4KB): smallest write unit.
//   Blocks (256KB = 64 pages): smallest erase unit.
//   Write: can only write to erased pages.
//   Erase: must erase entire block.
//   Flash Translation Layer (FTL): maps LBA to physical page.
//     Handles write amplification, wear leveling, garbage
//     collection. The FTL is the coherence maintenance layer
//     of the storage device.
//
// Filesystem (on top of block device):
//   Maps names (paths) to block ranges.
//   Inode: metadata (size, permissions, block pointers).
//   Directory: maps names to inode numbers.
//   Superblock: filesystem metadata (size, free space, root inode).
//   Journal: log of pending operations for crash recovery.
//     Write-ahead logging: write intent to journal BEFORE
//     modifying data. On crash, replay journal to recover
//     consistent state. This is active coherence maintenance
//     across power failure.
//
// Derives from: theory.computing.peripheral, theory.computing.memory.dram
  """
}
