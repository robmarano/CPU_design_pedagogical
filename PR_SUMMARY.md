# PR Summary: Phase 1 Memory Integration & Top-Level

## Objective
Integrate the foundational datapath and control components into a fully functional Single-Cycle MIPS processor, connected to Instruction and Data memories.

## Work Completed
- **`src/single_cycle_computer/imem.sv`**: Implemented Instruction Memory (ROM). Converts byte-addressed PC values into word-aligned array indices (`a[31:2]`). Initialized via `$readmemh`.
- **`src/single_cycle_computer/dmem.sv`**: Implemented Data Memory (RAM). Features combinational read and synchronous write (on `posedge clk`) using word-aligned addressing.
- **Testbenches**: Built `tb_imem.sv` (with a dummy `memfile.dat`) and `tb_dmem.sv` to verify read/write behavior and address alignment.

## Pending in this Epic
- Implement Program Counter (`dff.sv`).
- Implement the Datapath Wrapper (`datapath.sv`).
- Implement the CPU Wrapper combining Datapath and Control (`cpu.sv`).
- Implement the Top-Level Computer combining CPU and Memories (`computer.sv`).
- Create a comprehensive system-level testbench (`tb_computer.sv`).
