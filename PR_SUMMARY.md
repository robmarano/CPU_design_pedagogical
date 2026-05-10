# PR Summary: Epic 7 - Phase 6: FPU Coprocessor & Quake 3 Fast Inverse Square Root

## Objective
Implement floating-point arithmetic to successfully execute the legendary Quake III Fast Inverse Square Root algorithm (the `0x5f3759df` magic number algorithm). To avoid massive pipeline duplication for pedagogical simplicity, the FPU instructions are mapped to operate on the General Purpose Register (GPR) file, demonstrating free bit-level type-punning between integer and float values.

## Work Completed
- **Combinational FPU (`fpu.sv`)**: Developed a simplified IEEE-754 Single Precision floating-point unit capable of performing multiplication (`mul.s`) and subtraction (`sub.s`).
- **ALU Integration (`alu.sv`)**: Embedded the FPU directly into the EX-stage ALU. Also implemented the integer shift-right-logical-variable (`srlv`) instruction which is critical for the `i >> 1` step of the algorithm.
- **Decoder Expansion (`aludec.sv`, `maindec.sv`)**: Added decoding for `srlv`, `mul.s`, and `sub.s`.
- **Assembler Update (`scripts/assembler.py`)**: Enhanced the Python assembler to support `srlv` as well as the new pseudo-R-type floating point instructions. It maps floating point register strings (e.g., `$f4`) to their integer equivalents to support the unified register file.
- **Quake 3 Algorithm (`quake3.asm`)**: Authored the full Fast Inverse Square Root algorithm in MIPS assembly.
- **Testbench Verification (`tb_quake.sv`)**: The simulation passes beautifully, correctly evaluating the inverse square root of `2.0f`. The hardware outputs `0x3f34f95e` (~`0.706929`), matching the exact theoretical algorithmic approximation in exactly 24 clock cycles!
- **`STUDENT_GUIDE.md`**: Outlined Phase 6, explaining the unified register file trick for type punning and walking through the magic of the Quake 3 algorithm execution on our hardware.

## Pending in this Epic
- None. Ready for review and merge.
