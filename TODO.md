# Unimplemented Designs & Future Work

This file serves as a reminder for architectural components that have yet to be designed or implemented.

## Phase 1: Single-Cycle Datapath
- [ ] **Register File** (`regfile.sv`): 32x32-bit, dual-read async, single-write sync.
- [ ] **Main Decoder** (`maindec.sv`): Combinational mapping of 6-bit opcodes to core control signals (RegWrite, MemWrite, Branch, etc.).
- [ ] **Sign Extension** (`signext.sv`): 16-bit to 32-bit immediate extension.
- [ ] **Program Counter** (`pc.sv` / `dff.sv`): 32-bit state register.
- [ ] **Instruction Memory** (`imem.sv`): ROM simulation.
- [ ] **Data Memory** (`dmem.sv`): RAM simulation.
- [ ] **Datapath Wrapper** (`datapath.sv`): Structural wiring of all single-cycle components.
- [ ] **Top-Level Computer** (`computer.sv`): Encapsulation of CPU and memories.

## Phase 2: Multi-Cycle Datapath
- [ ] FSM Control Logic
- [ ] Unified Memory integration
- [ ] State registers (IR, MDR, A, B, ALUOut)

## Phase 3: Pipelined Datapath
- [ ] Pipeline boundary registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
- [ ] Hazard Detection Unit (Stalls/Flushes)
- [ ] Forwarding Unit (Bypassing)

## Phase 4: Cache Memory
- [ ] L1 Cache Controller
- [ ] Pipeline `mem_stall` logic
