`timescale 1ns/1ps

module cp0(
    input  logic        clk, reset,
    // ID/EX Read/Write ports
    input  logic        we,
    input  logic [4:0]  a,     // Register number
    input  logic [31:0] wd,
    output logic [31:0] rd,
    
    // Exception Interface
    input  logic        hw_exc,      // Trigger exception
    input  logic [31:0] hw_exc_epc,  // PC of the offending instruction
    input  logic [31:0] hw_exc_cause,// Exception cause (e.g., 8 for syscall)
    output logic [31:0] epc          // Sent to PC mux for eret
);

    logic [31:0] status;
    logic [31:0] cause;
    logic [31:0] epc_reg;
    
    // Status bits:
    // bit 0: IE (Interrupt Enable)
    // bit 1: EXL (Exception Level)

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            status  <= 32'h00000001; // IE=1, EXL=0
            cause   <= 32'b0;
            epc_reg <= 32'b0;
        end else if (hw_exc) begin
            status[1] <= 1'b1;        // Set EXL to 1 (disables interrupts/prevents nested exceptions)
            cause     <= hw_exc_cause;
            epc_reg   <= hw_exc_epc;
        end else if (we) begin
            case(a)
                12: status  <= wd;
                13: cause   <= wd;
                14: epc_reg <= wd;
            endcase
        end
    end
    
    always_comb begin
        case(a)
            12: rd = status;
            13: rd = cause;
            14: rd = epc_reg;
            default: rd = 32'b0;
        endcase
    end
    
    assign epc = epc_reg;

endmodule
