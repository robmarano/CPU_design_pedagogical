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

### Next Steps for You:
In our next lesson, we will build the **Register File** (`regfile.sv`). Prepare by looking at the MIPS Green Sheet: How many registers are there? How wide are they? What is special about Register `$zero`?
