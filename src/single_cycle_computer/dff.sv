`timescale 1ns/1ps

module dff #(parameter WIDTH = 32) (
    input  logic             clk, reset,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) q <= 32'h00000000;
        else       q <= d;
    end

endmodule
