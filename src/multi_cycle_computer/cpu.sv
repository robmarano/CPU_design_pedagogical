`timescale 1ns/1ps

module cpu(
    input  logic        clk, reset,
    output logic [31:0] adr, writedata,
    output logic        memwrite, memread,
    input  logic [31:0] readdata
);

    logic        pcen, irwrite, iord, alusrca;
    logic        regwrite, regdst, memtoreg;
    logic [1:0]  alusrcb, pcsource;
    logic [3:0]  alucontrol;
    logic        zero;
    logic [31:0] instr;

    // Control Unit
    controller c (
        .clk(clk), 
        .reset(reset),
        .op(instr[31:26]), 
        .funct(instr[5:0]),
        .zero(zero),
        .pcen(pcen), 
        .memread(memread), 
        .memwrite(memwrite),
        .irwrite(irwrite), 
        .regwrite(regwrite),
        .alusrca(alusrca), 
        .iord(iord), 
        .memtoreg(memtoreg), 
        .regdst(regdst),
        .alusrcb(alusrcb), 
        .pcsource(pcsource),
        .alucontrol(alucontrol)
    );

    // Datapath
    datapath dp (
        .clk(clk), 
        .reset(reset),
        .pcen(pcen), 
        .irwrite(irwrite),
        .iord(iord), 
        .alusrca(alusrca),
        .regwrite(regwrite), 
        .regdst(regdst), 
        .memtoreg(memtoreg),
        .alusrcb(alusrcb), 
        .pcsource(pcsource),
        .alucontrol(alucontrol),
        .zero(zero),
        .adr(adr), 
        .writedata(writedata),
        .readdata(readdata),
        .instr(instr)
    );

endmodule
