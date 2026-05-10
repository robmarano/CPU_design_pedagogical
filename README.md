# MIPS32 Pedagogical CPU in SystemVerilog

A complete, 5-stage pipelined MIPS32 CPU implemented in SystemVerilog. Designed from the ground up for educational purposes, this project walks through the evolution of a CPU from a basic Single-Cycle datapath up to a fully interactive, pipelined architecture.

## Architecture Highlights
- **5-Stage Pipelined Datapath**: Fetch, Decode, Execute, Memory, Writeback.
- **Hazard Unit**: Full support for data forwarding (bypassing), load-use stalls, and branch flushing.
- **L1 Data Cache**: 64-byte Direct-Mapped Cache with 16-byte block sizes.
- **IEEE-754 FPU**: Floating-point Coprocessor mapped onto the GPRs for zero-cost type punning (successfully executes the Quake III fast inverse square root algorithm).
- **Coprocessor 0 (CP0)**: Hardware support for precise synchronous exceptions (`syscall`) and asynchronous hardware interrupts.
- **Memory-Mapped I/O (MMIO)**: A complete Verilator and SDL2 wrapper that renders an 80x24 green-on-black ASCII terminal, responding to physical host keystrokes.

## Documentation
Check out the [STUDENT_GUIDE.md](STUDENT_GUIDE.md) for a step-by-step walkthrough of how and why each component was designed, progressing through 8 distinct Epics. 

Architectural block diagrams and ALU mappings can be found in [ARCHITECTURE.md](ARCHITECTURE.md).

## Getting Started

### Prerequisites
To run the interactive terminal and simulate the CPU, you will need:
- **Verilator**
- **SDL2** (Simple DirectMedia Layer)
- **Python 3** (for the custom MIPS assembler)

```bash
# macOS installation
brew install verilator sdl2
```

### Building and Running
The CPU ships with an interactive terminal firmware (`terminal.asm`) that enables hardware interrupts and echoes your keystrokes to the screen.

1. **Assemble the firmware:**
   ```bash
   python3 scripts/assembler.py programs/terminal.asm programs/memfile.dat
   ```

2. **Compile the Verilator C++ Model:**
   ```bash
   make
   ```

3. **Run the CPU:**
   ```bash
   ./obj_dir/Vcomputer
   ```
   
   An OS window named "MIPS32 Terminal" will appear. Click on it and start typing!
