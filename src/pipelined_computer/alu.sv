`timescale 1ns/1ps

module alu(
    input  logic        clk,     // Required for MULT/DIV sequential storage
    input  logic [31:0] a, b,
    input  logic [3:0]  alucontrol,
    output logic [31:0] result,
    output logic        zero
);

    logic [31:0] hi, lo; // Internal registers for MULT/DIV results

    initial begin
        hi = 32'b0;
        lo = 32'b0;
    end

    always_comb begin
        case (alucontrol)
            4'b0000: result = a & b;                 // AND
            4'b0001: result = a | b;                 // OR
            4'b0010: result = a + b;                 // ADD
            4'b0011: result = ~(a | b);              // NOR
            4'b0100: result = lo;                    // MFLO
            4'b0101: result = hi;                    // MFHI
            4'b0110: result = a - b;                 // SUB
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            default: result = 32'b0;                 // Default to 0 instead of X
        endcase
    end

    // MIPS branching checks if registers are equal, which means result of SUB is 0
    // Fix: We must ONLY check zero flag based on equality, independent of 'result' signal
    // otherwise the ALU zero flag will glitch when ALU is not performing SUB.
    // Wait, standard MIPS ALU outputs zero when result == 0.
    assign zero = (result == 32'b0);

    // Sequential logic for MULT and DIV
    always_ff @(negedge clk) begin
        if (alucontrol == 4'b1000) begin // MULT
            {hi, lo} <= $signed({{32{a[31]}}, a}) * $signed({{32{b[31]}}, b});
        end else if (alucontrol == 4'b1001) begin // DIV
            if (b != 0) begin
                lo <= $signed(a) / $signed(b); // LO = Quotient
                hi <= $signed(a) % $signed(b); // HI = Remainder
            end
        end
    end

endmodule
