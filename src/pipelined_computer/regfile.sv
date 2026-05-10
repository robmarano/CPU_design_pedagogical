`timescale 1ns/1ps

module regfile(
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  ra1, ra2, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);

    logic [31:0] ram[31:0];
    
    // Initialize registers to zero to prevent X propagation
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            ram[i] = 32'b0;
        end
    end

    // Three-port register file
    // Read two ports combinationally (A1/RD1, A2/RD2)
    // Write third port on falling edge of clock to allow forwarding from WB to ID within the SAME cycle
    // (This is standard practice for MIPS pipelined register files)
    always_ff @(negedge clk) begin
        if (we3 && wa3 != 0) ram[wa3] <= wd3;
    end

    // Internal forwarding: if reading the same register being written THIS cycle, forward the write data.
    assign rd1 = (ra1 != 0) ? ((ra1 == wa3 && we3) ? wd3 : ram[ra1]) : 32'b0;
    assign rd2 = (ra2 != 0) ? ((ra2 == wa3 && we3) ? wd3 : ram[ra2]) : 32'b0;

endmodule
