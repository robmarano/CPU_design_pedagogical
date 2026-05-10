# PR Summary: Untracked Files Clean-up

## Objective
Resolve lingering untracked files in the working directory to ensure a clean git state and proper dependency management for fresh repository clones.

## Work Completed
- **Deleted fpr.sv**: Removed orphaned Floating Point Register file code. The architecture utilizes a Unified Register File, rendering this module obsolete.
- **Tracked font8x8_basic.h**: Committed the third-party VGA font header required by the Verilator/SDL2 terminal wrapper. This ensures make works cleanly out of the box for other developers.
- **Tracked MMIO_DESIGN.md**: Committed the historical MMIO design specification to the docs/ folder.
- **Updated .gitignore**: Added *.dat to ignore assembled machine code binaries, treating them as transient build artifacts rather than source code.

## Pending
- None. Ready for review and merge.
