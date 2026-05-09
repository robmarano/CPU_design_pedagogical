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

    logic [31:0] instrD;
    logic [5:0]  opD, functD;
    logic        regwriteD, memtoregD, memwriteD, memreadD, alusrcD, regdstD, branchD, jumpD;
    logic        syscallD, eretD, mfc0D, mtc0D;
    logic        bneD;
    logic [1:0]  aluopD;
    logic [3:0]  alucontrolD;
    logic        equalD, pcsrcD;

    // Pipeline control registers
    logic       regwriteE, memtoregE, memwriteE, memreadE, alusrcE, regdstE;
    logic       syscallE, eretE, mfc0E, mtc0E;
    logic [3:0] alucontrolE;
    
    logic       regwriteM, memtoregM;
    logic       syscallM, eretM, mfc0M, mtc0M;
    
    logic       regwriteW, memtoregW;
    logic       mfc0W;
    
    logic       flushE;
    logic       mem_stall;

    // Assert mem_stall if the memory stage is reading/writing but main memory is not ready
    assign mem_stall = (memreadM | memwriteM) & ~mem_ready;

    assign bneD = (opD == 6'b000101);

    // Main Decoder (in ID stage)
    maindec md (
        .instr(instrD),
        .memtoreg(memtoregD), .memwrite(memwriteD), .memread(memreadD), .branch(branchD),
        .alusrc(alusrcD), .regdst(regdstD), .regwrite(regwriteD),
        .jump(jumpD), .aluop(aluopD),
        .syscall(syscallD), .eret(eretD), .mfc0(mfc0D), .mtc0(mtc0D)
    );

    // ALU Decoder (in ID stage)
    aludec ad (
        .funct(functD), .aluop(aluopD), .alucontrol(alucontrolD)
    );

    assign pcsrcD = branchD & (bneD ? ~equalD : equalD);

    // ID/EX Control Register (14 bits)
    flopenrc #(14) c1E (
        .clk(clk), .reset(reset), .en(~mem_stall), .clear(flushE),
        .d({regwriteD, memtoregD, memwriteD, memreadD, alucontrolD, alusrcD, regdstD, syscallD, eretD, mfc0D, mtc0D}),
        .q({regwriteE, memtoregE, memwriteE, memreadE, alucontrolE, alusrcE, regdstE, syscallE, eretE, mfc0E, mtc0E})
    );

    // EX/MEM Control Register (8 bits)
    flopenrc #(8) c2M (
        .clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0),
        .d({regwriteE, memtoregE, memwriteE, memreadE, syscallE, eretE, mfc0E, mtc0E}),
        .q({regwriteM, memtoregM, memwriteM, memreadM, syscallM, eretM, mfc0M, mtc0M})
    );

    // MEM/WB Control Register (3 bits)
    flopenrc #(3) c3W (
        .clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0),
        .d({regwriteM, memtoregM, mfc0M}),
        .q({regwriteW, memtoregW, mfc0W})
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
        
        .syscallM(syscallM), .eretM(eretM), .mfc0W(mfc0W), .mtc0M(mtc0M),
        
        .equalD(equalD),
        .pcF(pcF), .instrF(instrF),
        .aluoutM(aluoutM), .writedataM(writedataM), .readdataM(readdataM),
        .instrD(instrD),
        .opD(opD), .functD(functD),
        .flushE(flushE)
    );

endmodule
