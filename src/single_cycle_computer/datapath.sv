`timescale 1ns/1ps

module datapath(
    input  logic        clk, reset,
    input  logic        memtoreg, pcsrc,
    input  logic        alusrc, regdst,
    input  logic        regwrite, jump,
    input  logic [3:0]  alucontrol,
    output logic        zero,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic [31:0] aluout, writedata,
    input  logic [31:0] readdata
);

    logic [4:0]  writereg;
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
    logic [31:0] signimm, signimmsh;
    logic [31:0] srca, srcb;
    logic [31:0] result;

    // Next PC logic
    dff #(32) pcreg (
        .clk(clk), 
        .reset(reset), 
        .d(pcnext), 
        .q(pc)
    );

    adder pcadd1 (
        .a(pc), 
        .b(32'b100), 
        .y(pcplus4)
    );

    sl2 immsh (
        .a(signimm), 
        .y(signimmsh)
    );

    adder pcadd2 (
        .a(pcplus4), 
        .b(signimmsh), 
        .y(pcbranch)
    );

    mux2 #(32) pcbrmux (
        .d0(pcplus4), 
        .d1(pcbranch), 
        .s(pcsrc), 
        .y(pcnextbr)
    );

    mux2 #(32) pcmux (
        .d0(pcnextbr), 
        .d1({pcplus4[31:28], instr[25:0], 2'b00}), 
        .s(jump), 
        .y(pcnext)
    );

    // Register file logic
    mux2 #(5) wrmux (
        .d0(instr[20:16]), 
        .d1(instr[15:11]), 
        .s(regdst), 
        .y(writereg)
    );

    regfile rf (
        .clk(clk), 
        .we3(regwrite), 
        .ra1(instr[25:21]), 
        .ra2(instr[20:16]), 
        .wa3(writereg), 
        .wd3(result), 
        .rd1(srca), 
        .rd2(writedata) // wd going to memory
    );

    mux2 #(32) resmux (
        .d0(aluout), 
        .d1(readdata), 
        .s(memtoreg), 
        .y(result)
    );

    signext se (
        .a(instr[15:0]), 
        .y(signimm)
    );

    // ALU logic
    mux2 #(32) srcbmux (
        .d0(writedata), 
        .d1(signimm), 
        .s(alusrc), 
        .y(srcb)
    );

    alu alu_inst (
        .clk(clk),
        .a(srca), 
        .b(srcb), 
        .alucontrol(alucontrol), 
        .result(aluout), 
        .zero(zero)
    );

endmodule
