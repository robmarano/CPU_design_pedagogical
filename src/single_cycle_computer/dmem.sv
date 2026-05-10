`timescale 1ns/1ps

module dmem(
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a, wd,
    output logic [31:0] rd
);

    logic [31:0] RAM[0:255]; // 64 words (256 bytes) of data memory

    // Combinational read: Address is shifted to access words (a[31:2])
    assign rd = RAM[a[31:2]];

    // Synchronous write: Happens on the rising edge of the clock if Write Enable (we) is high
    always_ff @(posedge clk) begin
        if (we) begin
            RAM[a[31:2]] <= wd;
        end
    end

endmodule
