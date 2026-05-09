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
    // BUG FIX: branch stalling handles dependencies on EX and MEM stages.
    // If the dependency is in the MEM stage, we still stall until it reaches WB, or we forward from MEM!
    // Actually, we can forward from MEM if it's an ALU result.
    // Let's forward from MEM stage if it's an ALU result. If it's a MEM read, it was stalled, so the data is now in WB.
    // Let's forward from both MEM and WB to ID? No, Harris & Harris only forwards from MEM to ID for branches. Wait, no.
    // If we only forward from MEM, what if the dependency is in WB?
    // Let's update forwardaD and forwardbD to just use simple logic: if it's in MEM, forward. If we stall correctly, it won't matter.
    // Actually, branchstallD handles it.
    assign forwardaD = (rsD != 0) && (rsD == writeregM) && regwriteM;
    assign forwardbD = (rtD != 0) && (rtD == writeregM) && regwriteM;

    // --- STALLING LOGIC ---
    // Load-Use Stall: If the EX stage is a Load (memtoregE), and the DECODE stage needs that register
    assign lwstallD = memtoregE & ((rtE == rsD) | (rtE == rtD));
    
    // Branch Stall: We must stall a branch if it depends on an ALU result currently in EX or a Load currently in MEM
    assign branchstallD = branchD & 
                          ((regwriteE & (writeregE == rsD | writeregE == rtD)) | 
                           (memtoregM & (writeregM == rsD | writeregM == rtD)));
    
    // Aggregate Stalls and Flushes
    assign stallD = lwstallD | branchstallD;
    assign stallF = stallD;
    
    // BUG FIX: flushE MUST be high on a stall (to insert a bubble) OR when a branch is taken (pcsrcD) 
    // to flush the instruction that was fetched in the branch delay slot (which is now in ID, moving to EX).
    assign flushE = stallD | pcsrcD;

endmodule
