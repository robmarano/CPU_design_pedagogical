# PR Summary: Epic 6 - Exceptions and Coprocessor 0 (CP0)

## Objective
Implement precise exception handling in the 5-Stage Pipelined Architecture. We will introduce Coprocessor 0 (CP0) to manage the `Status`, `Cause`, and `EPC` registers, and modify the datapath and hazard units to support software traps (`syscall`), hardware flushes, and exception returns (`eret`).

## Work Completed
- **Assembler Update**: Enhanced `scripts/assembler.py` to support `.org` directives for precise memory layout, and added opcodes for `syscall`, `eret`, `mfc0`, and `mtc0`.
- **Coprocessor 0 (`cp0.sv`)**: Created a dedicated module with `Status` (reg 12), `Cause` (reg 13), and `EPC` (reg 14). It captures the offending PC (`epc_reg`) and reason (`hw_exc_cause`) while setting the Exception Level (`EXL`) bit on a trap.
- **Datapath Updates (`datapath.sv`)**: 
  - Wired `cp0` into the `MEM` stage for precise, in-order exception resolution.
  - Implemented the `flush_exc` signal, which flushes the `IF/ID`, `ID/EX`, and `EX/MEM` registers to squash subsequent instructions when a trap occurs.
  - Added a new 3-way multiplexer (`pcexc_mux`) to jump the PC to `0x00000080` on a syscall, and to `EPC` upon an `eret`.
- **Decoder Updates (`maindec.sv`, `cpu.sv`)**: Decoded the new instructions and passed `syscall`, `eret`, `mfc0`, and `mtc0` signals cleanly down the pipeline.
- **Testing (`exception_after.asm`)**: Authored a program that successfully increments a counter, hits a `syscall`, traps to `0x80`, executes an exception handler (proving `mfc0`/`mtc0` work by incrementing the EPC by 4), and uses `eret` to return cleanly. The testbench verifies the result is exactly `101` in 46 clock cycles.
- **`STUDENT_GUIDE.md`**: Outlined Phase 5, explaining how and why exceptions are resolved in the MEM stage to guarantee precision.

## Pending in this Epic
- None. Ready for review and merge.
