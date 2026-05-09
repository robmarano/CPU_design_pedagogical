`timescale 1ns/1ps

module datapath(
    input  logic        clk, reset,
    input  logic        pcen, irwrite,
    input  logic        iord, alusrca,
    input  logic        regwrite, regdst, memtoreg,
    input  logic [1:0]  alusrcb, pcsource,
    input  logic [3:0]  alucontrol,
    output logic        zero,
    output logic [31:0] adr, writedata,
    input  logic [31:0] readdata,
    output logic [31:0] instr
);

    logic [4:0]  writereg;
    logic [31:0] pcnext, pc;
    logic [31:0] signimm, signimmsh;
    logic [31:0] srca, srcb;
    logic [31:0] result;
    logic [31:0] data;
    logic [31:0] rd1, rd2;
    logic [31:0] a, b;
    logic [31:0] aluresult, aluout;

    // --- State Registers ---
    flopenr #(32) pcreg (
        .clk(clk), .reset(reset), .en(pcen), 
        .d(pcnext), .q(pc)
    );

    flopenr #(32) instrreg (
        .clk(clk), .reset(reset), .en(irwrite), 
        .d(readdata), .q(instr)
    );

    flopr #(32) datareg (
        .clk(clk), .reset(reset), 
        .d(readdata), .q(data)
    );

    flopr #(32) areg (
        .clk(clk), .reset(reset), 
        .d(rd1), .q(a)
    );

    flopr #(32) breg (
        .clk(clk), .reset(reset), 
        .d(rd2), .q(b)
    );

    flopr #(32) aluoutreg (
        .clk(clk), .reset(reset), 
        .d(aluresult), .q(aluout)
    );


    // --- Multiplexers and Routing ---
    // Memory Address Mux
    mux2 #(32) adrmux (
        .d0(pc), .d1(aluout), .s(iord), .y(adr)
    );

    // Register File Destination Mux
    mux2 #(5) regdstmux (
        .d0(instr[20:16]), .d1(instr[15:11]), .s(regdst), .y(writereg)
    );

    // Register File Write Data Mux
    mux2 #(32) wdmux (
        .d0(aluout), .d1(data), .s(memtoreg), .y(result)
    );

    // Sign Extension
    signext se (
        .a(instr[15:0]), .y(signimm)
    );

    sl2 immsh (
        .a(signimm), .y(signimmsh)
    );

    // ALU Input A Mux
    mux2 #(32) srcamux (
        .d0(pc), .d1(a), .s(alusrca), .y(srca)
    );

    // ALU Input B Mux
    mux4 #(32) srcbmux (
        .d0(b), .d1(32'd4), .d2(signimm), .d3(signimmsh), 
        .s(alusrcb), .y(srcb)
    );

    // PC Next Mux
    mux3 #(32) pcmux (
        .d0(aluresult), .d1(aluout), .d2({pc[31:28], instr[25:0], 2'b00}), 
        .s(pcsource), .y(pcnext)
    );

    // Write data to memory is always from register B
    assign writedata = b;

    // --- Core Components ---
    regfile rf (
        .clk(clk), 
        .we3(regwrite), 
        .ra1(instr[25:21]), 
        .ra2(instr[20:16]), 
        .wa3(writereg), 
        .wd3(result), 
        .rd1(rd1), 
        .rd2(rd2)
    );

    alu alu_inst (
        .clk(clk),
        .a(srca), 
        .b(srcb), 
        .alucontrol(alucontrol), 
        .result(aluresult), 
        .zero(zero)
    );

endmodule
