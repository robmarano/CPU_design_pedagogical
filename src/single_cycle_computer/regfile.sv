`timescale 1ns/1ps

module regfile(
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  ra1, ra2, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);

    logic [31:0] rf[31:0];

    // Three-port register file
    // Read two ports combinationally (A1/RD1, A2/RD2)
    // Write third port on rising edge of clock (A3/WD3/WE3)
    // Register 0 hardwired to 0

    always_ff @(posedge clk) begin
        if (we3) rf[wa3] <= wd3;
    end

    assign rd1 = (ra1 != 0) ? rf[ra1] : 32'b0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 32'b0;

endmodule
