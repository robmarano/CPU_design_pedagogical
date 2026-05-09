# PR Summary: Epic 5 - L1 Cache & System Integration

## Objective
Introduce realistic memory latency and demonstrate the performance impact of a Direct-Mapped L1 Cache. We will first establish a baseline using a slow `main_memory.sv`, then build `l1_cache.sv` to exploit spatial and temporal locality, significantly reducing the CPI (Cycles Per Instruction) of the `cache_test.asm` program.

## Work Completed
- **`scripts/assembler.py`**: Created a robust, bespoke Python MIPS assembler to easily compile test programs.
- **`programs/cache_test.asm`**: Authored an array summation program specifically designed to generate cache compulsory misses during initialization, followed by 100% hits during the summation loop. Assembled to `memfile_cache.dat`.
- **Baseline Architecture Setup**: Upgraded the Pipelined Datapath boundary registers to `flopenrc.sv` to support global memory stalls (`mem_stall`). Fixed a critical hazard unit bug where pipeline stalls cleared register state unintentionally.
- **`main_memory.sv`**: Implemented with a simulated 5-cycle read/write latency.
- **Baseline Profiling**: Ran the "No Cache" baseline test. Executing the 184 dynamic instructions required **369 clock cycles**, yielding a baseline CPI of **2.00**.
- **`l1_cache.sv`**: Built a 64-byte Direct-Mapped Cache with 16-byte (4-word) blocks, utilizing a Write-Through, No-Write-Allocate policy.
- **Cache Profiling**: Re-ran the simulation using the L1 Cache. 12 out of 16 memory reads resulted in Cache Hits. The execution time dropped to **325 clock cycles**, yielding a cached CPI of **1.76** (a 12% absolute performance increase), exactly matching mathematical predictions.
- **`STUDENT_GUIDE.md`**: Documented Steps 19, 20, and 21, explaining Memory Hierarchy, global pipeline stalling, address splitting (Tag/Index/Offset), Cache Hit/Miss logic, and the final CPI calculations.

## Pending in this Epic
- None. Ready for review and merge.
