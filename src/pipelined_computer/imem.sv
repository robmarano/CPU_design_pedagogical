`timescale 1ns/1ps

module imem #(parameter INIT_FILE = "programs/memfile.dat") (
    input  logic [31:0] a,
    output logic [31:0] rd
);

    logic [31:0] RAM[0:255]; // 256 words (1024 bytes) of instruction memory

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, RAM);
        end
    end
    
    // MIPS memory is byte-addressable, but instructions are 32-bit words.
    assign rd = RAM[a[31:2]]; 

endmodule
