`timescale 1ns/1ps

module signext(
    input  logic [15:0] a,
    output logic [31:0] y
);

    // Replicate the sign bit (a[15]) 16 times, then concatenate the original 16 bits
    assign y = {{16{a[15]}}, a};

endmodule
