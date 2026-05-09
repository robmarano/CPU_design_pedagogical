`timescale 1ns/1ps

module computer(
    input  logic        clk, reset,
    output logic [31:0] writedata, dataadr,
    output logic        memwrite
);

    logic [31:0] readdata;
    logic        memread;

    // Instantiate the CPU
    cpu mips (
        .clk(clk), 
        .reset(reset), 
        .adr(dataadr), 
        .writedata(writedata), 
        .memwrite(memwrite), 
        .memread(memread),
        .readdata(readdata)
    );

    // Instantiate Unified Memory
    mem memory (
        .clk(clk), 
        .we(memwrite), 
        .a(dataadr), 
        .wd(writedata), 
        .rd(readdata)
    );

endmodule
