`timescale 1ns/1ps

module alu(
    input  logic        clk,
    input  logic [31:0] a, b,
    input  logic [3:0]  alucontrol,
    output logic [31:0] result,
    output logic        zero
);

    logic [31:0] hi, lo; // Internal registers for MULT/DIV results
    
    // Floating Point Unit (Combinational)
    logic [31:0] fp_result;
    logic        fp_is_mul;
    
    assign fp_is_mul = (alucontrol == 4'b1100);
    
    fpu fp_unit (
        .a(a),
        .b(b),
        .is_mul(fp_is_mul),
        .result(fp_result)
    );

    initial begin
        hi = 32'b0;
        lo = 32'b0;
    end

    // Use a wire for the shift amount to avoid iverilog bit-select warnings in always_comb
    wire [4:0] shift_amt = b[4:0];

    always @(*) begin
        case (alucontrol)
            4'b0000: result = a & b;                 // AND
            4'b0001: result = a | b;                 // OR
            4'b0010: result = a + b;                 // ADD
            4'b0011: result = ~(a | b);              // NOR
            4'b0100: result = lo;                    // MFLO
            4'b0101: result = hi;                    // MFHI
            4'b0110: result = a - b;                 // SUB
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b1010: result = a >> shift_amt;        // SRLV
            4'b1100: result = fp_result;             // mul.s
            4'b1101: result = fp_result;             // sub.s
            default: result = 32'b0;                 // Default to 0 instead of X
        endcase
    end

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
