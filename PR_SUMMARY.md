# PR Summary: Epic 4 - 5-Stage Pipelined Architecture

## Objective
Upgrade the MIPS CPU to a high-performance 5-Stage Pipelined Architecture. This involves dividing the datapath into `Fetch`, `Decode`, `Execute`, `Memory`, and `Writeback` stages, allowing 5 instructions to execute simultaneously. We will also implement a Hazard Unit to resolve Data and Control hazards.

## Work Completed
- *Pending implementation*

## Pending in this Epic
- Implement Pipeline Registers (`flopenr.sv`, `flopenrc.sv`, `floprc.sv` with clear/flush logic).
- Implement the **Hazard Unit** (`hazard.sv`) to control forwarding, stalls, and flushes.
- Separate Instruction and Data Memory (reverting to Harvard architecture for pipeline throughput).
- Build the Pipelined Datapath (`datapath.sv`).
- Build the Pipelined CPU wrapper (`cpu.sv`).
- Test the pipeline with `mipstest.asm`, verifying correct behavior through RAW hazards, Load-Use stalls, and Branch flushes.