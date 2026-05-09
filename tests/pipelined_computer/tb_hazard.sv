`timescale 1ns/1ps

module tb_hazard();
    logic [4:0] rsE, rtE, rsD, rtD;
    logic [4:0] writeregE, writeregM, writeregW;
    logic       regwriteE, regwriteM, regwriteW;
    logic       memtoregE, memtoregM;
    logic       branchD;
    
    logic       forwardaD, forwardbD;
    logic [1:0] forwardaE, forwardbE;
    logic       stallF, stallD, flushE;

    hazard dut(.*);

    initial begin
        $dumpfile("tb_hazard.vcd");
        $dumpvars(0, tb_hazard);

        // Initialize all inputs to 0
        rsE=0; rtE=0; rsD=0; rtD=0;
        writeregE=0; writeregM=0; writeregW=0;
        regwriteE=0; regwriteM=0; regwriteW=0;
        memtoregE=0; memtoregM=0; branchD=0;
        #10;

        // --- TEST 1: Forwarding to EX from Memory Stage ---
        // Ex: ADD $t0, $t1, $t2 in EX, but $t1 is being written by ADD $t1, $t3, $t4 in MEM
        rsE = 5'd9; rtE = 5'd10;  // EX stage needs $9 and $10
        writeregM = 5'd9;         // MEM stage is writing to $9
        regwriteM = 1;            // MEM stage write is valid
        #10;
        if (forwardaE !== 2'b10 || forwardbE !== 2'b00) $error("Failed EX Forwarding from MEM");

        // --- TEST 2: Forwarding to EX from Writeback Stage ---
        // Same as above, but MEM stage isn't writing, WB stage is.
        regwriteM = 0; writeregM = 0;
        writeregW = 5'd10;        // WB stage is writing to $10
        regwriteW = 1;            // WB stage write is valid
        #10;
        if (forwardaE !== 2'b00 || forwardbE !== 2'b01) $error("Failed EX Forwarding from WB");

        // --- TEST 3: Load-Use Stall ---
        // Ex: LW $t0, 0($t1) in EX, and ADD $t2, $t0, $t3 in ID
        rsE=0; rtE=5'd8;          // EX stage is LW writing to $8 (rtE used for loads)
        memtoregE = 1;            // EX stage is a Memory Read
        rsD=5'd8; rtD=5'd9;       // ID stage needs $8 and $9
        #10;
        if (stallF !== 1 || stallD !== 1 || flushE !== 1) $error("Failed Load-Use Stall logic");

        $display("All Hazard Unit tests passed.");
        $finish;
    end
endmodule
