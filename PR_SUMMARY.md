# PR Summary: Epic 5 - L1 Cache & System Integration

## Objective
Introduce realistic memory latency and demonstrate the performance impact of a Direct-Mapped L1 Cache. We will first establish a baseline using a slow `main_memory.sv`, then build `l1_cache.sv` to exploit spatial and temporal locality, significantly reducing the CPI (Cycles Per Instruction) of the `cache_test.asm` program.

## Work Completed
- **`scripts/assembler.py`**: Created a robust, bespoke Python MIPS assembler to easily compile test programs.
- **`programs/cache_test.asm`**: Authored an array summation program specifically designed to generate cache compulsory misses during initialization, followed by 100% hits during the summation loop. Assembled to `memfile_cache.dat`.
- **`STUDENT_GUIDE.md`**: Outlined Steps 19 and 20, explaining Memory Hierarchy, global pipeline stalling, address splitting (Tag/Index/Offset), and Cache Hit/Miss logic.

## Pending in this Epic
- Upgrade the Pipelined Datapath boundary registers (`EX/MEM`, `MEM/WB`) to `flopenrc.sv` to support global memory stalls.
- Implement `main_memory.sv` with a simulated 5-cycle read/write latency.
- Run the "No Cache" baseline test and document performance.
- Implement `l1_cache.sv` and `cache_controller.sv`.
- Run the "With Cache" test and compare performance.