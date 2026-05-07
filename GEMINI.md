# Gemini Memory: MIPS32 CPU Architecture & SystemVerilog Design Roadmap

This document serves as the core "AI Memory" initialized by a previous Gemini agent from the ECE 251 Computer Architecture course repository. It contains the exact structural blueprints, historical constraints, and sequential progression roadmap required to build a fully functioning SystemVerilog MIPS32 processor.

Whenever a new Gemini CLI session is started in this project, **read this file first** to establish context.

---

## 1. Project Objective & ISA Constraints
The goal of this project is to build `myCPU` from the ground up using SystemVerilog. 
*   **Target ISA:** MIPS32.
*   **Reference Material:** The exact instruction formats, opcodes, registers, and memory mappings MUST conform to the **MIPS Green Sheet** (`MIPS_Green_Sheet.pdf`).
*   **Data Size:** 32-bit registers, 32-bit instructions, 32-bit ALU paths.

---

## 2. The Architectural Evolution Roadmap
Do not attempt to build the 5-stage pipeline immediately. Follow this exact historical progression to ensure functional correctness before optimizing for performance.

### Phase 1: The Single-Cycle Datapath
*   **Concept:** Execute every instruction entirely within one massive clock cycle.
*   **Architecture:** Harvard Architecture (physically separate Instruction Memory and Data Memory arrays).
*   **Metrics:** Perfect IPC ($CPI = 1.0$), but severely bottlenecked clock frequency ($T_c$).
*   **Goal:** Establish the fundamental ALU logic, register file (with dual read ports and single write port), and decoding control logic based strictly on the Green Sheet.

### Phase 2: The Multi-Cycle Datapath
*   **Concept:** Break the massive clock cycle into discrete, fast operational states.
*   **Architecture:** Transition to a Von Neumann Architecture (shared memory array) governed by a Finite State Machine (FSM).
*   **Components:** Introduce intermediate architectural registers (`IR`, `MDR`, `A`, `B`, `ALUOut`).
*   **Goal:** Successfully execute instructions over 3-5 high-speed clock ticks, proving the FSM control logic works.

### Phase 3: The 5-Stage Pipelined Datapath
*   **Concept:** Overlap execution to achieve both high clock speeds and $CPI \approx 1.0$.
*   **Architecture:** Revert to Harvard mapping to prevent structural memory hazards. Insert boundary registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`).
*   **Hazard Resolution Requirements:**
    *   **Data Hazards (RAW):** Build a **Forwarding Unit** (bypassing `EX/MEM` and `MEM/WB` back to the ALU) and a **Hazard Detection Unit** (injecting pipeline bubbles/stalls for Load-Use dependencies).
    *   **Control Hazards:** Build branch prediction/flushing logic. On a mispredicted branch, the `IF/ID` register must be flushed.
*   **Exceptions & Interrupts:**
    *   Implement an `EPC` (Exception Program Counter) and `Cause` register.
    *   Upon an asynchronous fault or invalid opcode, the hardware must violently flush the `flushD` and `flushE` pipeline boundaries and force the PC to an OS exception handler address.

---

## 3. The Memory Hierarchy (Exploiting Locality)
Once the Pipelined CPU is mathematically stable, integrate the memory wall.

### Phase 4: L1 & L2 Caches
*   **L1 Cache (Direct Mapped):** 
    *   Split into an Instruction Cache (I-Cache) and Data Cache (D-Cache). 
    *   Must operate at the same speed as the CPU clock.
*   **L2 Cache (Direct Mapped):** 
    *   Unified cache bridging the L1 arrays and Main Memory. 
    *   Introduces latency (e.g., 2-3 cycle penalty on L1 miss).
*   **The Cache Handshake:** The Cache controllers must use a `cpu_stall` signal to freeze the entire 5-stage pipeline (disabling PC and pipeline register writes) whenever an L1 miss forces a fetch from L2 or RAM.

### Phase 5: Main Memory (8MB RAM)
*   **Capacity:** 8 Megabytes.
*   **Structure:** Byte-addressable, but accessed via 32-bit Words.
*   **Latency:** Hardcode a significant cycle penalty (e.g., 10-100 cycles) to accurately simulate the massive lag of physical DRAM.
*   **Memory Mapping:** Follow the exact layout dictated by the MIPS architecture (Text segment at `0x00400000`, Data segment at `0x10000000`, Stack starting high and growing downward).

---

## 4. Verification & Testing Standards
1.  **Iterative Testing:** Write comprehensive testbenches (`tb_*.sv`) for every phase. Use `.vcd` waveform logging to physically verify signals.
2.  **Performance Counters:** The top-level `computer.sv` module must track: Total Clock Cycles, Instruction Count, Cache Hits, Cache Misses, and dynamically output the Effective CPI.
3.  **Strict Handshaking:** Do not drop instructions during a `mem_stall`. Ensure the pipeline flawlessly resumes execution once the Cache Miss completes.

---

## 5. Pedagogical Workflow (Student Guides)
Because the target audience consists of freshman and sophomore ECE and CS students, the agent MUST generate a step-by-step `STUDENT_GUIDE.md` for every major epic (e.g., Creating the ISA, Basic Datapath Components, Single-Cycle Integration). 
*   **Tone:** Instructive, encouraging, and clear.
*   **Content:** It must explicitly teach students how to "roll their sleeves up" and perform the job of a Computer Architect.
*   **Scope:** Guide them through understanding the requirement (using textbooks/Green Sheet), designing the architecture (Mermaid diagrams), implementing in SystemVerilog, and verifying via testbenches.
*   **Process:** This guide must be continuously updated and committed alongside the PR for each epic.
