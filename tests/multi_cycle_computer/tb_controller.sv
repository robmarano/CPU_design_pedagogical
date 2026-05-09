`timescale 1ns/1ps

module tb_controller();
    logic       clk, reset;
    logic [5:0] op, funct;
    logic       zero;
    
    // Outputs
    logic       pcen, memread, memwrite, irwrite, regwrite;
    logic       alusrca, iord, memtoreg, regdst;
    logic [1:0] alusrcb, pcsource;
    logic [3:0] alucontrol;

    controller dut(.*);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_controller.vcd");
        $dumpvars(0, tb_controller);

        clk = 0; reset = 1; zero = 0; op = 0; funct = 0;
        #7; // Assert reset across first posedge (at #5)
        reset = 0; 
        
        // --- TEST 1: R-Type Instruction ---
        op = 6'b000000; funct = 6'b100000; // ADD
        
        // Cycle 1: FETCH (Current State at time 7)
        #1;
        if (memread !== 1 || irwrite !== 1 || alusrcb !== 2'b01 || pcen !== 1) $error("FETCH state failed");
        #9; // Move to DECODE (wait for next posedge at 15)
        
        // Cycle 2: DECODE
        #1;
        if (alusrcb !== 2'b11) $error("DECODE state failed");
        #9; // Move to RTYPEEX
        
        // Cycle 3: RTYPEEX
        #1;
        if (alusrca !== 1 || alucontrol !== 4'b0010) $error("RTYPEEX state failed");
        #9; // Move to RTYPEWB
        
        // Cycle 4: RTYPEWB
        #1;
        if (regwrite !== 1 || regdst !== 1 || memtoreg !== 0) $error("RTYPEWB state failed");
        #9; // Return to FETCH

        // --- TEST 2: Load Word ---
        op = 6'b100011; // lw
        
        // Cycle 1: FETCH
        #10; // Move to DECODE
        // Cycle 2: DECODE
        #10; // Move to MEMADR
        
        // Cycle 3: MEMADR
        #1;
        if (alusrca !== 1 || alusrcb !== 2'b10) $error("MEMADR state failed");
        #9; // Move to MEMRD
        
        // Cycle 4: MEMRD
        #1;
        if (memread !== 1 || iord !== 1) $error("MEMRD state failed");
        #9; // Move to MEMWB
        
        // Cycle 5: MEMWB
        #1;
        if (regwrite !== 1 || memtoreg !== 1 || regdst !== 0) $error("MEMWB state failed");
        #9; // Return to FETCH

        $display("All Multi-Cycle Controller tests passed.");
        $finish;
    end
endmodule
