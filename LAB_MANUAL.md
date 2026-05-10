# Hands-On Lab Manual

This manual provides explicit command-line instructions for students to simulate and test each major milestone (Phase) of the CPU design. 

By executing these labs, you will witness the evolution of the CPU architecture and visually confirm its operational correctness at every step.

## Running the Labs

The repository includes a unified `Makefile` to automate the assembling of test programs and the compilation of the simulators.

### Prerequisites
To run all labs (specifically Lab 4), you will need:
- **Verilator**
- **SDL2** (Simple DirectMedia Layer)
- **Python 3**

```bash
# macOS installation
brew install verilator sdl2
```

---

## Lab 1: Single-Cycle CPU
In this phase, the CPU executes one instruction per clock cycle. The clock cycle must be extremely long to accommodate the slowest instruction.

**Test Program (`programs/basic_test.asm`):**
Adds 5 + 2 and stores the result (7) in memory address 84 (`0x54`).

**Execution:**
```bash
make lab1
```
**Expected Output:** `Simulation Succeeded: Wrote 7 to address 84.`

---

## Lab 2: Multi-Cycle CPU
In this phase, the CPU breaks down instructions into 3-5 smaller steps, allowing hardware reuse (like a unified memory and a single ALU).

**Execution:**
```bash
make lab2
```
**Expected Output:** `Simulation Succeeded: Wrote 7 to address 84.` *(Note: If you look at the generated `tb_computer.vcd` waveforms, this takes significantly more clock cycles to complete than Lab 1!)*

---

## Lab 3: Pipelined CPU (L1 Cache & FPU)
In this phase, the CPU uses a 5-stage pipeline, an L1 Direct-Mapped Cache, and an IEEE-754 Floating Point Unit mapped to the GPRs. We will run the legendary Quake III Fast Inverse Square Root algorithm!

**Test Program (`programs/quake3.asm`):**
Approximates `1 / sqrt(2.0)` using Carmack's bit-level type-punning hack.

**Execution:**
```bash
make lab3
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

**Execution:**
```bash
make lab4
```
**Expected Result:** A black OS window with a green "READY" prompt will appear. Click the window and start typing. The CPU's hardware interrupt logic will intercept your physical keyboard presses and echo them back to the screen!
