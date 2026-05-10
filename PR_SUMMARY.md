# PR Summary: Makefile Simplification for Student Labs

## Objective
Streamline the execution of the CPU simulations for students by introducing a unified Makefile with clean, abstract targets for each lab phase, and updating the LAB_MANUAL.md to reflect these simpler commands.

## Work Completed
- **Makefile**: Created an elegant, top-level Makefile that completely abstracts away the python3, iverilog, and verilator compilation steps. It includes targets lab1, lab2, lab3, and lab4 which automatically assemble the required .asm programs into memfile.dat, compile the SystemVerilog hardware models, and execute the binaries.
- **LAB_MANUAL.md**: Rewrote the execution instructions. Students now only need to run a single command (e.g., make lab3) to see the architecture in action, significantly lowering the barrier to entry.

## Pending
- None. Ready for review and merge.
