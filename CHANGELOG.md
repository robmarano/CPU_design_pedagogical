# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - Phase 1 Foundation
### Added
- `alu.sv`: 32-bit ALU with arithmetic, logical, and sequential MULT/DIV capabilities.
- `aludec.sv`: ALU Control Decoder based on MIPS Green Sheet.
- `tb_alu.sv`: Comprehensive testbench for the ALU module.
- `regfile.sv`: 32x32-bit Register File with hardwired $zero logic.
- `tb_regfile.sv`: Comprehensive testbench for the Register File.
- `maindec.sv`: Main Control Decoder mapping 6-bit opcodes to the 9-bit control bus.
- `tb_maindec.sv`: Exhaustive testbench for the Main Decoder.
- `signext.sv`: 16-to-32-bit Sign Extension module.
- `tb_signext.sv`: Testbench for the Sign Extension module.
- `STUDENT_GUIDE.md`: Pedagogical step-by-step documentation for computer architecture students.
- `ARCHITECTURE.md`: Added architectural documentation and Mermaid data-flow diagrams.
- `PR_SUMMARY.md`: Added PR tracking documentation.
- `TODO.md`: Added tracking for unimplemented Phase 1 components.

### Fixed
- `alu.sv`: Fixed 64-bit sign extension truncation bug during `MULT` operation and added `initial` block to prevent `X` state propagation.
- `tb_alu.sv`: Expanded test coverage to include all ALU operations (AND, OR, NOR, SLT, DIV) and fixed false-positive pass messages on error.
- `.gitignore`: Fixed newline formatting issue.
