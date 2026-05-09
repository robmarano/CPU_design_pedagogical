`timescale 1ns/1ps

module computer(
    input  logic        clk, reset,
    output logic [31:0] writedata, dataadr,
    output logic        memwrite
);

    logic [31:0] pc, instr, readdata;
    logic        memread, mem_ready;

    // Instantiate the Pipelined CPU
    cpu mips (
        .clk(clk), 
        .reset(reset), 
        .pcF(pc), 
        .instrF(instr), 
        .memwriteM(memwrite), 
        .memreadM(memread),
        .aluoutM(dataadr), 
        .writedataM(writedata), 
        .readdataM(readdata),
        .mem_ready(mem_ready)
    );

    // Instantiate Instruction Memory (Fetch Stage)
    imem imem (
        .a(pc), 
        .rd(instr)
    );

    // Instantiate Main Data Memory with 5-cycle Latency (Memory Stage)
    main_memory dmem (
        .clk(clk), 
        .reset(reset),
        .mem_write(memwrite), 
        .mem_read(memread),
        .a(dataadr), 
        .wd(writedata), 
        .rd(readdata),
        .mem_ready(mem_ready)
    );

endmodule
