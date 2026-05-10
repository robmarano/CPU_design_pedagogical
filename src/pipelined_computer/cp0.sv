`timescale 1ns/1ps

module cp0(
    input  logic        clk, reset,
    // ID/EX Read/Write ports
    input  logic        we,
    input  logic [4:0]  a,     // Register number
    input  logic [31:0] wd,
    output logic [31:0] rd,
    
    // Exception/Interrupt Interface
    input  logic        hw_exc,      // Trigger synchronous exception (syscall) in MEM
    input  logic [31:0] hw_exc_epc,  // PC of the offending instruction
    input  logic [31:0] hw_exc_cause,// Exception cause (e.g., 8 for syscall)
    
    input  logic        hw_int,      // Asynchronous hardware interrupt pin
    input  logic [31:0] pc_id,       // PC of instruction currently in Decode
    
    output logic        int_pending, // Tells Datapath to flush ID and trap
    output logic [31:0] epc          // Sent to PC mux for eret
);

    logic [31:0] status;
    logic [31:0] cause;
    logic [31:0] epc_reg;
    
    // Status bits:
    // bit 0: IE (Interrupt Enable)
    // bit 1: EXL (Exception Level)

    assign int_pending = hw_int & status[0] & ~status[1];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            status  <= 32'h00000001; // IE=1, EXL=0
            cause   <= 32'b0;
            epc_reg <= 32'b0;
        end else if (hw_exc) begin // Sync exception in MEM
            status[1] <= 1'b1;
            cause     <= hw_exc_cause;
            epc_reg   <= hw_exc_epc;
        end else if (int_pending) begin // Async interrupt triggering from ID
            status[1] <= 1'b1;
            cause     <= 32'b0; // 0 = Hardware Interrupt
            epc_reg   <= pc_id;   // Save PC of the squashed ID instruction
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
