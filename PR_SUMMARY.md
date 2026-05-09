# PR Summary: Epic 3 - Multi-Cycle Architecture

## Objective
Evolve the MIPS32 CPU from a Single-Cycle (Harvard) design to a Multi-Cycle (Von Neumann) design. This involves introducing a Finite State Machine (FSM) to control execution across multiple clock cycles, allowing the sharing of the ALU and a single Unified Memory.

## Work Completed
- **`src/multi_cycle_computer/flopenr.sv`**: Implemented parameterized D-flip-flop with enable and asynchronous reset. Essential for IR, MDR, A, B, and ALUOut state registers.
- **`src/multi_cycle_computer/mem.sv`**: Implemented Unified Memory. Consolidated Instruction and Data memories into a single byte-addressable module, suitable for Von Neumann architecture.
- **`tests/multi_cycle_computer/tb_flopenr.sv`**: Verified hold, enable, and reset states.

## Pending in this Epic
- Implement the Multi-Cycle FSM Control Unit (`controller.sv` / `mainfsm.sv`).
- Build the Multi-Cycle Datapath Wrapper (`datapath.sv`).
- Build the Top-Level Multi-Cycle CPU (`cpu.sv` and `computer.sv`).
- Create an integration testbench to verify Multi-Cycle execution of the `mipstest.asm` program.
