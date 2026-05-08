# PR Summary: Phase 1 Memory Integration & Top-Level

## Objective
Integrate the foundational datapath and control components into a fully functional Single-Cycle MIPS processor, connected to Instruction and Data memories.

## Work Completed
- **`src/single_cycle_computer/imem.sv`**: Implemented Instruction Memory (ROM). Converts byte-addressed PC values into word-aligned array indices (`a[31:2]`). Initialized via `$readmemh`.
- **`src/single_cycle_computer/dmem.sv`**: Implemented Data Memory (RAM). Features combinational read and synchronous write (on `posedge clk`) using word-aligned addressing.
- **`src/single_cycle_computer/dff.sv`**: Program Counter flip-flop with asynchronous reset.
- **Helper Modules**: Implemented `adder.sv` for PC increments, `sl2.sv` for branch shift logic, and `mux2.sv` for parameterized multiplexing.
- **`src/single_cycle_computer/datapath.sv`**: Successfully wired the Datapath! Instantiated and interconnected the ALU, Register File, Sign Extender, PC flip-flop, and all helper modules, exactly matching the Harris & Harris architectural block diagram. Tested for syntactic correctness.
- **Testbenches**: Built `tb_imem.sv` (with a dummy `memfile.dat`) and `tb_dmem.sv` to verify read/write behavior and address alignment.

## Pending in this Epic
- Implement the CPU Wrapper combining Datapath and Control (`cpu.sv`).
- Implement the Top-Level Computer combining CPU and Memories (`computer.sv`).
- Create a comprehensive system-level testbench (`tb_computer.sv`).
