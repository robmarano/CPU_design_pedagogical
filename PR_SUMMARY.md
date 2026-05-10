# PR Summary: Document Pipeline Bubble Trap and Finalize README

## Objective
Document the debugging session that uncovered the Pipeline Bubble Trap edge case, ensuring students understand the complexity of asynchronous interrupts in pipelined architectures. Also, write a proper README to showcase the features and build instructions for the repository.

## Work Completed
- **STUDENT_GUIDE.md**: Added Step 33, explaining the Pipeline Bubble Trap (an interrupt hitting while the ID stage holds a flushed NOP), how it caused a reboot bug, and how introducing validD solved it.
- **ARCHITECTURE.md**: Added a dedicated section detailing the Pipeline Bubble Trap edge case alongside a Mermaid sequence diagram comparing the naive EPC capture implementation vs the fixed validD-aware implementation.
- **README.md**: Completely rewrote the root README to serve as an attractive project landing page. Included feature highlights (Pipelining, Cache, FPU, Exceptions, MMIO Terminal), prerequisite instructions (Verilator, SDL2), and build/run commands.
- **.gitignore and Private Memory**: Prevented temporary debugging scripts (sim_debug) from being checked in, while recording their diagnostic value into the private MEMORY file.

## Pending
- None. Ready for review and merge.
