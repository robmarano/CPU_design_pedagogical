# PR Summary: Epic 8 - Phase 7: Memory-Mapped I/O (MMIO) and Hardware Interrupts

## Objective
Implement MMIO with asynchronous hardware interrupts, bridging the physical host environment (macOS Apple Silicon via SDL2) with the emulated MIPS datapath. This creates a fully functional, interactive system capable of rendering a bitmapped ASCII terminal and reading localhost keyboard input.

## Work Completed
- **Host Emulation Environment (`sim_main.cpp`, `Makefile`)**: Developed a Verilator + C++ wrapper that uses SDL2 to spawn an OS window. It manages an 80x24 terminal character buffer, mapping standard ASCII keys to UART streams and rendering a VGA-style 8x8 font.
- **MMIO Bus Routing (`computer.sv`)**: Integrated a custom MMIO address decoder overriding the L1 Cache.
  - `0x00007F00`: UART RX Control
  - `0x00007F04`: UART RX Data (reads the keyboard character)
  - `0x00007F08`: UART TX Control
  - `0x00007F0C`: UART TX Data (writes character directly to SDL2 screen)
- **Precise Asynchronous Hardware Interrupts (`cp0.sv`, `datapath.sv`)**: 
  - Wired the SDL2 `rx_valid` signal straight into Coprocessor 0 as an external hardware interrupt (`hw_int`).
  - To prevent destroying pipeline integrity, asynchronous interrupts trigger directly in the Decode (ID) stage. This pushes the `hw_int` flag down to the MEM stage, flushing `IF` and `ID` cleanly, ensuring the EPC accurately captures the PC of the suspended instruction so `eret` can perfectly resume it later.
- **Interactive Firmware (`terminal.asm`)**: Authored an interrupt-driven assembly program. It enables CP0 interrupts, writes "READY
" to the terminal, and drops into an infinite sleep loop. Whenever a key is pressed, the hardware automatically traps to `0x80`, echoes the key back to the terminal, and uses `eret` to return to sleep.
- **`STUDENT_GUIDE.md`**: Updated with "Phase 7: Memory-Mapped I/O and Hardware Interrupts" summarizing MMIO bypassing caches and how asynchronous interrupts differ from synchronous exceptions.

## Pending in this Epic
- None. Ready for review and merge.
