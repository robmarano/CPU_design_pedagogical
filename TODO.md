# Unimplemented Designs & Future Work

This file serves as a reminder for architectural components that have yet to be designed or implemented.

## Phase 1: Single-Cycle Datapath
- [x] **ALU** (`alu.sv`) & **ALU Decoder** (`aludec.sv`)
- [x] **Register File** (`regfile.sv`): 32x32-bit, dual-read async, single-write sync.
- [x] **Main Decoder** (`maindec.sv`): Combinational mapping of 6-bit opcodes to core control signals.
- [x] **Sign Extension** (`signext.sv`): 16-bit to 32-bit immediate extension.
- [x] **Program Counter** (`dff.sv`): 32-bit state register.
- [x] **Instruction Memory** (`imem.sv`): ROM simulation.
- [x] **Data Memory** (`dmem.sv`): RAM simulation.
- [x] **Datapath Wrapper** (`datapath.sv`): Structural wiring of all single-cycle components.
- [x] **CPU Wrapper** (`cpu.sv`): Combines Control Unit (`maindec` + `aludec`) with the Datapath.
- [x] **Top-Level Computer** (`computer.sv`): Encapsulation of CPU and memories.

## Phase 2: Multi-Cycle Datapath
- [x] FSM Control Logic (`controller.sv` / `mainfsm.sv`)
- [x] Unified Memory integration (`mem.sv`)
- [x] State registers (IR, MDR, A, B, ALUOut) (`flopenr.sv` / `flopr.sv`)
- [x] Top-Level Integrations (`datapath.sv`, `cpu.sv`, `computer.sv`)

## Phase 3: Pipelined Datapath
- [ ] Pipeline boundary registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
- [ ] Hazard Detection Unit (Stalls/Flushes)
- [ ] Forwarding Unit (Bypassing)

## Phase 4: Cache Memory
- [ ] L1 Cache Controller
- [ ] Pipeline `mem_stall` logic
