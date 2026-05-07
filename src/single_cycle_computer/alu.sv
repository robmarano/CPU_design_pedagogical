`timescale 1ns/1ps

module alu(
    input  logic        clk,     // Required for MULT/DIV sequential storage
    input  logic [31:0] a, b,
    input  logic [3:0]  alucontrol,
    output logic [31:0] result,
    output logic        zero
);

    logic [31:0] hi, lo; // Separate 32-bit registers for MIPS HI and LO

    always_comb begin
        case (alucontrol)
            4'b0000: result = a & b;                 // AND
            4'b0001: result = a | b;                 // OR
            4'b0010: result = a + b;                 // ADD
            4'b0011: result = ~(a | b);              // NOR
            4'b0100: result = lo;                    // MFLO
            4'b0101: result = hi;                    // MFHI
            4'b0110: result = a - b;                 // SUB
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT
            default: result = 32'bx;                 // Default case
        endcase
    end

    assign zero = (result == 32'b0);

    // Sequential logic for MULT and DIV
    always_ff @(negedge clk) begin
        if (alucontrol == 4'b1000) begin // MULT
            {hi, lo} <= $signed(a) * $signed(b);
        end else if (alucontrol == 4'b1001) begin // DIV
            if (b != 0) begin
                lo <= $signed(a) / $signed(b); // LO = Quotient
                hi <= $signed(a) % $signed(b); // HI = Remainder
            end
        end
    end

endmodule
