# PR Summary: Epic 3 - Multi-Cycle Architecture

## Objective
Evolve the MIPS32 CPU from a Single-Cycle (Harvard) design to a Multi-Cycle (Von Neumann) design. This involves introducing a Finite State Machine (FSM) to control execution across multiple clock cycles, allowing the sharing of the ALU and a single Unified Memory.

## Work Completed
- *Pending implementation*

## Pending in this Epic
- Implement State Registers (`flopenr.sv`, `dff.sv` updates for IR, MDR, A, B, ALUOut).
- Implement Unified Memory (`mem.sv`).
- Implement the Multi-Cycle FSM Control Unit (`controller.sv` / `mainfsm.sv`).
- Build the Multi-Cycle Datapath Wrapper (`datapath.sv`).
- Build the Top-Level Multi-Cycle CPU (`cpu.sv` and `computer.sv`).
- Create an integration testbench to verify Multi-Cycle execution of the `mipstest.asm` program.
