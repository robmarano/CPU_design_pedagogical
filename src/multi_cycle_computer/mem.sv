`timescale 1ns/1ps

module mem(
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a, wd,
    output logic [31:0] rd
);

    logic [31:0] RAM[0:63]; // 64 words (256 bytes) of unified memory
    
    initial begin
        $readmemh("memfile.dat", RAM);
    end

    // Combinational read (Unified memory serves both instructions and data)
    assign rd = RAM[a[31:2]];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we) begin
            RAM[a[31:2]] <= wd;
        end
    end

endmodule
