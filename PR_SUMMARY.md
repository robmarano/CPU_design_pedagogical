# PR Summary: Phase 1 Datapath Foundation (ALU & Decoder)

## Objective
Establish the foundational arithmetic and control decoding logic for the MIPS32 Single-Cycle datapath.

## Work Completed
- **`src/single_cycle_computer/alu.sv`**: Implemented a 32-bit ALU supporting standard MIPS operations (ADD, SUB, AND, OR, NOR, SLT). Included sequential execution for `MULT` and `DIV` storing results on the falling clock edge.
- **ALU Refactoring**: Replaced a single 64-bit `hilo` register with distinct 32-bit `hi` and `lo` registers to perfectly align with MIPS architectural specifications and cleanly suppress `iverilog` part-select warnings.
- **`src/single_cycle_computer/aludec.sv`**: Created the ALU Control Decoder, accurately mapping the 2-bit `aluop` and 6-bit `funct` (R-type) fields to the internal 4-bit `alucontrol` signal.
- **`src/single_cycle_computer/regfile.sv`**: Implemented the 32x32-bit Register File.
    - Two asynchronous read ports.
    - One synchronous write port (on `posedge clk`).
    - Hardwired Register 0 (`$zero`) to always return 0, ensuring architectural compliance.
- **`tests/single_cycle_computer/tb_regfile.sv`**: Built a testbench to verify synchronous writes, asynchronous reads, and the immutability of Register 0.
- **`tests/single_cycle_computer/tb_alu.sv`**: Built an exhaustive testbench to verify combinational and sequential operations.
- **Infrastructure**: Configured basic testing infrastructure using Icarus Verilog.

## Pending in this Epic
- Implement the Main Decoder (`maindec.sv`).
- Implement Sign Extension (`signext.sv`).
