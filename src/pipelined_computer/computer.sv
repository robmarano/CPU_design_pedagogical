`timescale 1ns/1ps

module computer(
    input  logic        clk, reset,
    output logic [31:0] writedata, dataadr,
    output logic        memwrite
);

    logic [31:0] pc, instr, readdata;

    // Instantiate the Pipelined CPU
    cpu mips (
        .clk(clk), 
        .reset(reset), 
        .pcF(pc), 
        .instrF(instr), 
        .memwriteM(memwrite), 
        .aluoutM(dataadr), 
        .writedataM(writedata), 
        .readdataM(readdata)
    );

    // Instantiate Instruction Memory (Fetch Stage)
    imem imem (
        .a(pc), 
        .rd(instr)
    );

    // Instantiate Data Memory (Memory Stage)
    dmem dmem (
        .clk(clk), 
        .we(memwrite), 
        .a(dataadr), 
        .wd(writedata), 
        .rd(readdata)
    );

endmodule
