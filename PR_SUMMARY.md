# PR Summary: Epic 3 - Multi-Cycle Architecture

## Objective
Evolve the MIPS32 CPU from a Single-Cycle (Harvard) design to a Multi-Cycle (Von Neumann) design. This involves introducing a Finite State Machine (FSM) to control execution across multiple clock cycles, allowing the sharing of the ALU and a single Unified Memory.

## Work Completed
- **`src/multi_cycle_computer/flopenr.sv` & `flopr.sv`**: Implemented state registers.
- **`src/multi_cycle_computer/mem.sv`**: Implemented Unified Memory. 
- **`src/multi_cycle_computer/mainfsm.sv`**: Implemented the core FSM state transitions and output control signals.
- **`src/multi_cycle_computer/controller.sv`**: Built the multi-cycle controller wrapper.
- **`src/multi_cycle_computer/datapath.sv`**: Successfully wired the Multi-Cycle datapath. It instantiates exactly ONE ALU and ONE Memory module, reusing them across cycles using large 4-to-1 multiplexers (`mux4.sv`). Added critical state registers (`IR`, `MDR`, `A`, `B`, `ALUOut`).
- **`src/multi_cycle_computer/cpu.sv` & `computer.sv`**: Completed the top-level wrappers for the multi-cycle CPU.
- **`tests/multi_cycle_computer/tb_computer.sv`**: Ran the system-level integration test against the `mipstest.asm` memory file. **Simulation Succeeded**, writing `7` to address `84` exactly as the Harris & Harris specification requires!

## Pending in this Epic
- Phase 2 (Multi-Cycle Architecture) is now 100% complete and fully verified. Ready to merge into `main` and begin Epic 4 (Pipelined Datapath).
