`timescale 1ns/1ps

module hazard(
    input  logic [4:0] rsE, rtE,
    input  logic [4:0] rsD, rtD,
    input  logic [4:0] writeregE, writeregM, writeregW,
    input  logic       regwriteE, regwriteM, regwriteW,
    input  logic       memtoregE, memtoregM,
    input  logic       branchD,
    
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
    assign forwardaD = (rsD != 0) && (rsD == writeregM) && regwriteM;
    assign forwardbD = (rtD != 0) && (rtD == writeregM) && regwriteM;

    // --- STALLING LOGIC ---
    // Load-Use Stall: If the EX stage is a Load (memtoregE), and the DECODE stage needs that register
    assign lwstallD = memtoregE & ((rtE == rsD) | (rtE == rtD));
    
    // Branch Stall: We must stall a branch if it depends on an ALU result currently in EX or a Load currently in MEM
    assign branchstallD = branchD & 
                          (regwriteE & ((writeregE == rsD) | (writeregE == rtD))) | 
                          (memtoregM & ((writeregM == rsD) | (writeregM == rtD)));
    
    // Aggregate Stalls and Flushes
    // If we stall DECODE, we must also stall FETCH (so we don't lose the next instruction).
    // If we stall DECODE, we must FLUSH EXECUTE (insert a bubble) so the stalled instruction doesn't execute twice.
    assign stallD = lwstallD | branchstallD;
    assign stallF = stallD;
    assign flushE = stallD;

    // Note: 'regwriteE' and 'writeregE' were used in branchstallD but not in module inputs.
    // In the Harris & Harris pipeline, branch comparisons happen in ID. If the instruction in EX
    // is writing to a register needed by the branch, we must stall. We need to define those wires internally
    // or add them as inputs. Let's add them as inputs to match the full design.

endmodule
