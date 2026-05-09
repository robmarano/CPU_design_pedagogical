# PR Summary: Epic 4 - 5-Stage Pipelined Architecture

## Objective
Upgrade the MIPS CPU to a high-performance 5-Stage Pipelined Architecture. This involves dividing the datapath into `Fetch`, `Decode`, `Execute`, `Memory`, and `Writeback` stages, allowing 5 instructions to execute simultaneously. We will also implement a Hazard Unit to resolve Data and Control hazards.

## Work Completed
- **`src/pipelined_computer/floprc.sv` & `flopenrc.sv`**: Implemented pipeline boundary registers. These flip-flops support synchronous clearing (to flush instructions like a branch penalty) and synchronous enabling (to stall instructions like a load-use penalty).
- **`src/pipelined_computer/hazard.sv`**: Implemented the Hazard Detection and Forwarding Unit. 
  - Solves Read-After-Write (RAW) data hazards by forwarding `ALUOut` from the Memory/Writeback stages back to the Execute stage (`forwardaE`, `forwardbE`).
  - Solves Load-Use hazards by detecting a read dependency on an executing `lw` instruction and emitting `stallF`, `stallD`, and `flushE`.
  - Tested rigorously with `tb_hazard.sv`.

## Pending in this Epic
- Separate Instruction and Data Memory (reverting to Harvard architecture for pipeline throughput).
- Build the Pipelined Datapath (`datapath.sv`).
- Build the Pipelined CPU wrapper (`cpu.sv`).
- Test the pipeline with `mipstest.asm`, verifying correct behavior through RAW hazards, Load-Use stalls, and Branch flushes.