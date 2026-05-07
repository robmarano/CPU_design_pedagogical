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
- **`src/single_cycle_computer/maindec.sv`**: Implemented the Main Decoder.
    - Accurately translates 6-bit opcodes into the 9-bit control bus (`regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop`).
- **`src/single_cycle_computer/signext.sv`**: Implemented the 16-to-32-bit Sign Extension module using SystemVerilog replication operators.
- **`tests/single_cycle_computer/tb_signext.sv`**: Built a testbench to verify positive, negative, and edge-case (largest positive/negative) integer extensions.
- **`tests/single_cycle_computer/tb_maindec.sv`**: Built an exhaustive testbench to verify correct signal generation for `R-type`, `lw`, `sw`, `beq`, `addi`, and `j`.
- **`tests/single_cycle_computer/tb_regfile.sv`**: Built a testbench to verify synchronous writes, asynchronous reads, and the immutability of Register 0.
- **`tests/single_cycle_computer/tb_alu.sv`**: Built an exhaustive testbench to verify combinational and sequential operations, covering ADD, SUB, AND, OR, NOR, SLT, MULT, DIV, MFHI, and MFLO. Addressed AI review feedback by properly failing CI on `$error`.
- **Infrastructure & Pedagogy**: Configured basic testing infrastructure using Icarus Verilog, fixed `.gitignore` formatting, and drafted the `STUDENT_GUIDE.md` detailing architectural rationale.
- **AI Review Fixes**: Fixed 64-bit casting truncation in `alu.sv` for the `MULT` instruction and initialized `hi`/`lo` registers to avoid `X` states on startup.

## Pending in this Epic
- All foundational datapath and control components for Phase 1 are complete. The next Epic will involve memory simulation and integrating these modules into the `datapath.sv` and `computer.sv` top-level wrappers.
