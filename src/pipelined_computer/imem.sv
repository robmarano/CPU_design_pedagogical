`timescale 1ns/1ps

module imem(
    input  logic [31:0] a,
    output logic [31:0] rd
);

    logic [31:0] RAM[0:255]; // 256 words (1024 bytes) of instruction memory

    initial begin
        // Initialize memory with machine code from a file.
        // In a real synthesis environment, this might be a block RAM initialization.
        $readmemh("programs/memfile_cache.dat", RAM);
    end

    // MIPS memory is byte-addressable, but instructions are 32-bit words.
    // By ignoring the bottom two bits (a[31:2]), we convert a byte address to a word index.
    assign rd = RAM[a[31:2]]; 

endmodule
