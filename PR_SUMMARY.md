# PR Summary: Epic 3 - Multi-Cycle Architecture

## Objective
Evolve the MIPS32 CPU from a Single-Cycle (Harvard) design to a Multi-Cycle (Von Neumann) design. This involves introducing a Finite State Machine (FSM) to control execution across multiple clock cycles, allowing the sharing of the ALU and a single Unified Memory.

## Work Completed
- **`src/multi_cycle_computer/flopenr.sv`**: Implemented parameterized D-flip-flop with enable and asynchronous reset. Essential for IR, MDR, A, B, and ALUOut state registers.
- **`src/multi_cycle_computer/mem.sv`**: Implemented Unified Memory. Consolidated Instruction and Data memories into a single byte-addressable module, suitable for Von Neumann architecture.
- **`src/multi_cycle_computer/mainfsm.sv`**: Implemented the core FSM state transitions (FETCH -> DECODE -> EXECUTE/MEMADR, etc.) and output control signals using a robust `typedef enum` structure and a 16-bit unified control output vector.
- **`src/multi_cycle_computer/controller.sv`**: Built the multi-cycle controller wrapper. Instantiates the FSM and reuses `aludec.sv` from Epic 1 to generate ALU controls based on `aluop` and `funct`. Also processes `pcen` logic.
- **`tests/multi_cycle_computer/tb_controller.sv`**: Verified cycle-by-cycle control signal generation across complex instructions (e.g., ensuring `lw` traces the path `FETCH -> DECODE -> MEMADR -> MEMRD -> MEMWB`).

## Pending in this Epic
- Build the Multi-Cycle Datapath Wrapper (`datapath.sv`).
- Build the Top-Level Multi-Cycle CPU (`cpu.sv` and `computer.sv`).
- Create an integration testbench to verify Multi-Cycle execution of the `mipstest.asm` program.
