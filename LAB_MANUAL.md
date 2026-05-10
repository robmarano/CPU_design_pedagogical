# Hands-On Lab Manual

This manual provides explicit command-line instructions for students to simulate and test each major milestone (Phase) of the CPU design. 

By executing these labs, you will witness the evolution of the CPU architecture and visually confirm its operational correctness at every step.

## Lab 1: Single-Cycle CPU
In this phase, the CPU executes one instruction per clock cycle. The clock cycle must be extremely long to accommodate the slowest instruction.

**Test Program (`programs/basic_test.asm`):**
Adds 5 + 2 and stores the result (7) in memory address 84 (`0x54`).

**Instructions:**
1. Assemble the basic test program into the global `memfile.dat`:
   ```bash
   python3 scripts/assembler.py programs/basic_test.asm memfile.dat
   ```
2. Compile the Single-Cycle hardware with the testbench:
   ```bash
   iverilog -g2012 -I src/single_cycle_computer -o single_sim tests/single_cycle_computer/tb_computer.sv src/single_cycle_computer/*.sv
   ```
3. Run the simulation:
   ```bash
   ./single_sim
   ```
   **Expected Output:** `Simulation Succeeded: Wrote 7 to address 84.`

---

## Lab 2: Multi-Cycle CPU
In this phase, the CPU breaks down instructions into 3-5 smaller steps, allowing hardware reuse (like a unified memory and a single ALU).

**Instructions:**
1. Keep the same `memfile.dat` generated in Lab 1.
2. Compile the Multi-Cycle hardware with its testbench:
   ```bash
   iverilog -g2012 -I src/multi_cycle_computer -o multi_sim tests/multi_cycle_computer/tb_computer.sv src/multi_cycle_computer/*.sv
   ```
3. Run the simulation:
   ```bash
   ./multi_sim
   ```
   **Expected Output:** `Simulation Succeeded: Wrote 7 to address 84.` *(Note: If you look at the VCD waveforms, this takes significantly more clock cycles to complete than Lab 1!)*

---

## Lab 3: Pipelined CPU (L1 Cache & FPU)
In this phase, the CPU uses a 5-stage pipeline, an L1 Direct-Mapped Cache, and an IEEE-754 Floating Point Unit mapped to the GPRs. We will run the legendary Quake III Fast Inverse Square Root algorithm!

**Test Program (`programs/quake3.asm`):**
Approximates `1 / sqrt(2.0)` using Carmack's bit-level type-punning hack.

**Instructions:**
1. Assemble the Quake 3 program:
   ```bash
   python3 scripts/assembler.py programs/quake3.asm programs/memfile_quake3.dat
   ```
2. Compile the Pipelined hardware with the Quake testbench:
   ```bash
   iverilog -g2012 -I src/pipelined_computer -o quake_sim tests/pipelined_computer/tb_quake.sv src/pipelined_computer/*.sv
   ```
3. Run the simulation:
   ```bash
   ./quake_sim
   ```
   **Expected Output:** 
   ```text
   QUAKE III FAST INVERSE SQUARE ROOT PASSED!
   Hardware correctly executed the Carmack magic number algorithm!
   Result Float Hex: 3f34f95e (~0.706929)
   Total Execution Cycles: 24
   ```

---

## Lab 4: Interactive Memory-Mapped I/O
In the final phase, we connect the Pipelined CPU to the real world. Using Verilator and SDL2, we render a live, interactive terminal that streams your physical keystrokes into the CPU via hardware interrupts.

**Instructions:**
1. Ensure you have the host dependencies installed (`brew install verilator sdl2` on macOS).
2. Assemble the interactive terminal firmware to `programs/memfile.dat`:
   ```bash
   python3 scripts/assembler.py programs/terminal.asm programs/memfile.dat
   ```
3. Compile the Verilator C++ simulation model:
   ```bash
   make clean
   make
   ```
4. Run the interactive OS window:
   ```bash
   ./obj_dir/Vcomputer
   ```
   **Expected Result:** A black window with a green "READY" prompt will appear. Click the window and start typing. The CPU's hardware interrupt logic will intercept your keys and echo them to the screen!
