# The Computer Architect's Playbook: Building a CPU from Scratch

Welcome to your journey as a Computer Architect! This guide is written specifically for freshman and sophomore engineering and computer science students. Over the course of this project, you will not just learn *about* computers; you will design and build one from the ground up using SystemVerilog.

We will break down the construction of our MIPS32 processor into manageable "Epics." Roll your sleeves up—here is how we work.

---

## Epic 1: The Basic Components (Datapath & Control)

Before we can build a fully functional Single-Cycle CPU, we need building blocks. Think of this like manufacturing the engine parts before assembling the car. The two most critical parts of any CPU are the **ALU (Arithmetic Logic Unit)** and the **Register File**.

### Step 1: Consult the Specifications (The MIPS Green Sheet)
A Computer Architect never codes blindly. Our contract with the software developers is the **ISA (Instruction Set Architecture)**. 
1. Open the `docs/MIPS_Green_Sheet.pdf`.
2. Look at the **Core Instruction Set**. Notice how different instructions (`add`, `sub`, `and`, `or`) require different mathematical operations. 
3. Look at the **Opcode/Funct** fields. These binary numbers are what the software compiler generates. Our hardware must read these numbers and know exactly what to do.

### Step 2: Design the ALU (`alu.sv`)
The ALU does the actual math. 
*   **The Architect's Task:** We need a module that takes two 32-bit inputs (`a` and `b`), a control signal (`alucontrol`), and outputs a 32-bit `result`.
*   **Implementation:** We use a SystemVerilog `always_comb` block. This creates *combinational logic*—a web of logic gates (AND, OR, XOR) that calculate the answer instantly based on the inputs.
*   **Special Cases (MULT/DIV):** Multiplication and division take time and produce 64-bit results. We must use a clock (`always_ff @(negedge clk)`) to store these results in special registers called `hi` and `lo`.

### Step 3: Design the Decoder (`aludec.sv`)
How does the ALU know to add instead of subtract? The Decoder tells it.
*   **The Architect's Task:** Build a translator. It takes the instruction's `funct` code (like `100000` for ADD) and translates it into a simple 4-bit wire (`alucontrol = 4'b0010`) connected directly to the ALU.

### Step 4: Verification (The Testbench)
An architect's job isn't done when the code compiles; it's done when the hardware is proven flawless.
*   **The Architect's Task:** Write a testbench (`tb_alu.sv`). You must simulate the clock, inject fake inputs (`a=10`, `b=5`), and tell the ALU to add. You then write an `if` statement: *If the result is not 15, throw an error!*
*   **Waveforms:** We use `$dumpfile("tb_alu.vcd")` to generate waveforms. Professional architects spend hours staring at these waveforms to ensure signals arrive at exactly the right nanosecond.

### Step 5: Designing the Register File (`regfile.sv`)
Now that our ALU can calculate, we need a place to store data. In MIPS, we use a **Register File**.
*   **The Architect's Task:** Build a high-speed storage array.
    1.  **Storage:** We need 32 different 32-bit "buckets" (registers).
    2.  **Dual Read Ports:** Most MIPS instructions (like `add $s1, $s2, $s3`) need to read *two* values at once. Our hardware must allow reading from two different addresses simultaneously without waiting for a clock tick (*Asynchronous Read*).
    3.  **Single Write Port:** We only write one result back at a time. This happens only on the "tick" of the clock (*Synchronous Write*).
    4.  **The $zero Rule:** Register 0 is special. In MIPS, it must *always* return 0, no matter what software tries to write to it. As an architect, you implement this by hardcoding the output logic to return `0` if the address is `0`.

### Step 6: The Main Decoder (`maindec.sv`) - The Brain of the CPU
The ALU does the math and the Register File stores the data, but who conducts the orchestra? That is the job of the **Main Decoder**.
*   **The Architect's Task:** Build the master control unit. The CPU fetches a 32-bit instruction from memory. The top 6 bits (bits 31:26) are the **opcode**. The Main Decoder looks *only* at these 6 bits and instantly decides how every other component in the CPU should behave.
*   **Control Signals:** Based on the opcode (e.g., `lw`, `sw`, `beq`, `R-type`), the decoder outputs a combination of 1-bit flags:
    *   `RegWrite`: Should we save data to the Register File?
    *   `RegDst`: Are we writing to the `rd` or `rt` register?
    *   `ALUSrc`: Is the ALU's second input coming from a register (`rt`) or an immediate number?
    *   `Branch` / `Jump`: Are we changing the Program Counter (PC)?
    *   `MemWrite` / `MemToReg`: Are we interacting with Data Memory?
    *   **ALUOp**: A 2-bit code passed to the *ALU Decoder* (which we built in Step 3) to finalize the exact math operation.
    *   **Implementation:** We use an `always_comb` block with a `case(opcode)` statement to flip these control flags on or off like a switchboard.

    ### Step 7: The Sign Extender (`signext.sv`)
    Some MIPS instructions contain immediate numbers built right into the instruction code (like `addi $t0, $t1, -5`). 
    *   **The Architect's Task:** A MIPS instruction is exactly 32 bits wide. In an I-type instruction, the opcode, registers, and other data take up the top 16 bits, leaving exactly 16 bits for the immediate number. However, our ALU only accepts 32-bit inputs!
    *   **The Problem:** We cannot simply pad the front of a negative number with zeros. The 16-bit binary for `-1` is `1111111111111111`. If we pad it with zeros, it becomes `00000000000000001111111111111111`, which is the positive number `65535`!
    *   **Implementation:** To convert a 16-bit number to a 32-bit number while preserving its sign (positive or negative), we must perform **Sign Extension**. We look at the Most Significant Bit (MSB, which is bit 15) of the 16-bit input. We then copy that exact bit into the top 16 bits of our new 32-bit output. We can do this cleanly in SystemVerilog using the replication operator: `{{16{a[15]}}, a}`.

    ---


### Next Steps for You:
In our next lesson, we will build the **Register File** (`regfile.sv`). Prepare by looking at the MIPS Green Sheet: How many registers are there? How wide are they? What is special about Register `$zero`?
