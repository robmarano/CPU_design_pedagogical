`timescale 1ns/1ps

module hazard(
    input  logic [4:0] rsE, rtE,
    input  logic [4:0] rsD, rtD,
    input  logic [4:0] writeregE, writeregM, writeregW,
    input  logic       regwriteE, regwriteM, regwriteW,
    input  logic       memtoregE, memtoregM,
    input  logic       branchD, pcsrcD,
    
    output logic       forwardaD, forwardbD,
    output logic [1:0] forwardaE, forwardbE,
    output logic       stallF, stallD, flushE
);

    logic lwstallD, branchstallD;

    // --- FORWARDING LOGIC ---
    // Forwarding to Execute Stage (ALU inputs)
    always_comb begin
        forwardaE = 2'b00;
        forwardbE = 2'b00;
        
        // Forward A
        if (rsE != 0) begin
            if (rsE == writeregM && regwriteM)      forwardaE = 2'b10; // Forward from Memory stage
            else if (rsE == writeregW && regwriteW) forwardaE = 2'b01; // Forward from Writeback stage
        end
        
        // Forward B
        if (rtE != 0) begin
            if (rtE == writeregM && regwriteM)      forwardbE = 2'b10; // Forward from Memory stage
            else if (rtE == writeregW && regwriteW) forwardbE = 2'b01; // Forward from Writeback stage
        end
    end

    // Forwarding to Decode Stage (for Branch Equality Check)
    // BUG FIX: branches check equality in the ID stage. 
    // They must forward from the MEM stage if an ALU instruction immediately preceding it writes to the reg.
    assign forwardaD = (rsD != 0) && (rsD == writeregM) && regwriteM;
    assign forwardbD = (rtD != 0) && (rtD == writeregM) && regwriteM;

    // --- STALLING LOGIC ---
    // Load-Use Stall: If the EX stage is a Load (memtoregE), and the DECODE stage needs that register
    assign lwstallD = memtoregE & ((rtE == rsD) | (rtE == rtD));
    
    // Branch Stall: We must stall a branch if it depends on an ALU result currently in EX or a Load currently in MEM
    // BUG FIX: branch stall must also trigger if the branch depends on an ALU result in MEM? No, we forward from MEM.
    // Wait, what if the instruction in EX is an ALU instruction? We stall 1 cycle. (Because we can't forward from EX to ID combo logic).
    // So if regwriteE and (writeregE == rsD | writeregE == rtD), we stall!
    // What if the instruction in MEM is a LOAD? We stall 1 cycle. (We can't forward load data from MEM because the load data comes from memory at the end of MEM cycle!).
    assign branchstallD = branchD & 
                          ((regwriteE & (writeregE == rsD | writeregE == rtD)) | 
                           (memtoregM & (writeregM == rsD | writeregM == rtD)));
    
    // Aggregate Stalls and Flushes
    assign stallD = lwstallD | branchstallD;
    assign stallF = stallD;
    
    assign flushE = stallD | pcsrcD;

endmodule
