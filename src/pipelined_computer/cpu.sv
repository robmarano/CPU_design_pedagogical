`timescale 1ns/1ps

module cpu(
    input  logic        clk, reset,
    output logic [31:0] pcF,
    input  logic [31:0] instrF,
    output logic        memwriteM, memreadM,
    output logic [31:0] aluoutM, writedataM,
    input  logic [31:0] readdataM,
    input  logic        mem_ready
);

    logic [5:0] opD, functD;
    logic       regwriteD, memtoregD, memwriteD, memreadD, alusrcD, regdstD, branchD, jumpD;
    logic       bneD;
    logic [1:0] aluopD;
    logic [3:0] alucontrolD;
    logic       equalD, pcsrcD;

    // Pipeline control registers
    logic       regwriteE, memtoregE, memwriteE, memreadE, alusrcE, regdstE;
    logic [3:0] alucontrolE;
    logic       regwriteM, memtoregM;
    logic       regwriteW, memtoregW;
    logic       flushE;
    logic       mem_stall;

    // Assert mem_stall if the memory stage is reading/writing but main memory is not ready
    assign mem_stall = (memreadM | memwriteM) & ~mem_ready;

    assign bneD = (opD == 6'b000101);

    // Main Decoder (in ID stage)
    maindec md (
        .op(opD),
        .memtoreg(memtoregD), .memwrite(memwriteD), .memread(memreadD), .branch(branchD),
        .alusrc(alusrcD), .regdst(regdstD), .regwrite(regwriteD),
        .jump(jumpD), .aluop(aluopD)
    );

    // ALU Decoder (in ID stage)
    aludec ad (
        .funct(functD), .aluop(aluopD), .alucontrol(alucontrolD)
    );

    assign pcsrcD = branchD & (bneD ? ~equalD : equalD);

    // ID/EX Control Register (1+1+1+1+4+1+1 = 10 bits)
    flopenrc #(10) c1E (
        .clk(clk), .reset(reset), .en(~mem_stall), .clear(flushE),
        .d({regwriteD, memtoregD, memwriteD, memreadD, alucontrolD, alusrcD, regdstD}),
        .q({regwriteE, memtoregE, memwriteE, memreadE, alucontrolE, alusrcE, regdstE})
    );

    // EX/MEM Control Register
    flopenrc #(4) c2M (
        .clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0),
        .d({regwriteE, memtoregE, memwriteE, memreadE}),
        .q({regwriteM, memtoregM, memwriteM, memreadM})
    );

    // MEM/WB Control Register
    flopenrc #(2) c3W (
        .clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0),
        .d({regwriteM, memtoregM}),
        .q({regwriteW, memtoregW})
    );

    // Datapath
    datapath dp (
        .clk(clk), .reset(reset),
        .mem_stall(mem_stall),
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
