`timescale 1ns/1ps

module sl2(
    input  logic [31:0] a,
    output logic [31:0] y
);

    // Shift left by 2 (multiply by 4) for branch address calculation
    assign y = {a[29:0], 2'b00};

endmodule
