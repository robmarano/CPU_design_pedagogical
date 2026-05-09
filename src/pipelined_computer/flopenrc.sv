`timescale 1ns/1ps

module flopenrc #(parameter WIDTH = 8) (
    input  logic             clk, reset,
    input  logic             en, clear,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or posedge reset) begin
        if      (reset) q <= 0;
        else if (clear) q <= 0;
        else if (en)    q <= d;
    end

endmodule
