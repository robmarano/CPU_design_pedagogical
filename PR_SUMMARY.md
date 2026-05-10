# PR Summary: Documentation, Architecture Diagrams, and Clean-up

## Objective
Update the documentation to accurately reflect the final state of the Pipelined CPU, including the FPU, Cache, MMIO, and Hardware Interrupts. Clean up the git repository by ignoring temporary simulator builds, waveform files, and one-off Python scripts.

## Work Completed
- **.gitignore Updates**: Added rules to ignore obj_dir/, *_sim, *.vcd, and fix*.py. This ensures the repository stays clean.
- **ARCHITECTURE.md Updates**: 
  - Added a comprehensive Full System Architecture Diagram using Mermaid, visualizing the CPU Pipeline, Memory Hierarchy (L1 & DRAM), Peripherals (CP0, UART MMIO), and how the interrupt logic wires them all together.
  - Added a Sequence Diagram (SDL2 Keyboard Interrupt Sequence) that traces a physical keypress from the macOS host, through the Verilator C++ wrapper, into the MMIO UART, triggering Coprocessor 0, executing the software interrupt handler, and returning via eret.
  - Updated the 4-bit ALU Control Mapping table to include the new FPU instructions (mul.s, sub.s) and the shift instruction (srlv).

## Pending
- None. Ready for review and merge.
