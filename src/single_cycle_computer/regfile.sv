`timescale 1ns/1ps

module regfile(
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  ra1, ra2, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);

    logic [31:0] rf[31:0];
    
    // Initialize registers to zero to prevent X propagation
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] = 32'b0;
        end
    end

    // Three-port register file
    // Read two ports combinationally (A1/RD1, A2/RD2)
    // Write third port on rising edge of clock (A3/WD3/WE3)
    // Register 0 hardwired to 0

    always_ff @(posedge clk) begin
        if (we3 && wa3 != 0) rf[wa3] <= wd3;
    end

    assign rd1 = (ra1 != 0) ? rf[ra1] : 32'b0;
    assign rd2 = (ra2 != 0) ? rf[ra2] : 32'b0;

endmodule
