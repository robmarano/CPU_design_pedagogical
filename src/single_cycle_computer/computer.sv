`timescale 1ns/1ps

module computer(
    input  logic        clk, reset,
    output logic [31:0] writedata, dataadr,
    output logic        memwrite
);

    logic [31:0] pc, instr, readdata;

    // Instantiate the CPU
    cpu mips (
        .clk(clk), 
        .reset(reset), 
        .pc(pc), 
        .instr(instr), 
        .memwrite(memwrite), 
        .aluout(dataadr), 
        .writedata(writedata), 
        .readdata(readdata)
    );

    // Instantiate Instruction Memory
    imem imem (
        .a(pc), 
        .rd(instr)
    );

    // Instantiate Data Memory
    dmem dmem (
        .clk(clk), 
        .we(memwrite), 
        .a(dataadr), 
        .wd(writedata), 
        .rd(readdata)
    );

endmodule
