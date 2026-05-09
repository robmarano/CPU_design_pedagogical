`timescale 1ns/1ps

module cpu(
    input  logic        clk, reset,
    output logic [31:0] pcF,
    input  logic [31:0] instrF,
    output logic        memwriteM,
    output logic [31:0] aluoutM, writedataM,
    input  logic [31:0] readdataM
);

    logic [5:0] opD, functD;
    logic       regwriteD, memtoregD, memwriteD, alusrcD, regdstD, branchD, jumpD;
    logic       bneD;
    logic [1:0] aluopD;
    logic [3:0] alucontrolD;
    logic       equalD, pcsrcD;

    // Pipeline control registers
    logic       regwriteE, memtoregE, memwriteE, alusrcE, regdstE;
    logic [3:0] alucontrolE;
    logic       regwriteM, memtoregM;
    logic       regwriteW, memtoregW;
    logic       flushE;

    assign bneD = (opD == 6'b000101);

    // Main Decoder (in ID stage)
    maindec md (
        .op(opD),
        .memtoreg(memtoregD), .memwrite(memwriteD), .branch(branchD),
        .alusrc(alusrcD), .regdst(regdstD), .regwrite(regwriteD),
        .jump(jumpD), .aluop(aluopD)
    );

    // ALU Decoder (in ID stage)
    aludec ad (
        .funct(functD), .aluop(aluopD), .alucontrol(alucontrolD)
    );

    assign pcsrcD = branchD & (bneD ? ~equalD : equalD);

    // ID/EX Control Register (1+1+1+4+1+1 = 9 bits)
    floprc #(9) c1E (
        .clk(clk), .reset(reset), .clear(flushE),
        .d({regwriteD, memtoregD, memwriteD, alucontrolD, alusrcD, regdstD}),
        .q({regwriteE, memtoregE, memwriteE, alucontrolE, alusrcE, regdstE})
    );

    // EX/MEM Control Register
    floprc #(3) c2M (
        .clk(clk), .reset(reset), .clear(1'b0),
        .d({regwriteE, memtoregE, memwriteE}),
        .q({regwriteM, memtoregM, memwriteM})
    );

    // MEM/WB Control Register
    floprc #(2) c3W (
        .clk(clk), .reset(reset), .clear(1'b0),
        .d({regwriteM, memtoregM}),
        .q({regwriteW, memtoregW})
    );

    // Datapath
    datapath dp (
        .clk(clk), .reset(reset),
        .memtoregE(memtoregE), .memtoregM(memtoregM), .memtoregW(memtoregW),
        .pcsrcD(pcsrcD), .branchD(branchD),
        .alusrcE(alusrcE), .regdstE(regdstE),
        .regwriteE(regwriteE), .regwriteM(regwriteM), .regwriteW(regwriteW),
        .jumpD(jumpD),
        .alucontrolE(alucontrolE),
        .equalD(equalD),
        .pcF(pcF), .instrF(instrF),
        .aluoutM(aluoutM), .writedataM(writedataM), .readdataM(readdataM),
        .opD(opD), .functD(functD),
        .flushE(flushE)
    );

endmodule
