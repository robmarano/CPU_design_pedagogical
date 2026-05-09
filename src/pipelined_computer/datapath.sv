`timescale 1ns/1ps

module datapath(
    input  logic        clk, reset,
    input  logic        memtoregE, memtoregM, memtoregW,
    input  logic        pcsrcD, branchD,
    input  logic        alusrcE, regdstE,
    input  logic        regwriteE, regwriteM, regwriteW,
    input  logic        jumpD,
    input  logic [3:0]  alucontrolE,
    output logic        equalD,
    output logic [31:0] pcF,
    input  logic [31:0] instrF,
    output logic [31:0] aluoutM, writedataM,
    input  logic [31:0] readdataM,
    output logic [5:0]  opD, functD,
    output logic        flushE
);

    // Hazard signals
    logic forwardaD, forwardbD;
    logic [1:0] forwardaE, forwardbE;
    logic stallF, stallD;

    // IF stage logic
    logic [31:0] pcplus4F, pcnextbrF, pcnextF;
    
    // ID stage logic
    logic [31:0] instrD, pcplus4D, signimmD, signimmshD;
    logic [31:0] rd1D, rd2D;
    logic [4:0]  rsD, rtD, rdD;
    logic [31:0] eqcmpaD, eqcmpbD;
    logic [31:0] pcbranchD;
    
    // EX stage logic
    logic [31:0] rd1E, rd2E, signimmE;
    logic [4:0]  rsE, rtE, rdE, writeregE;
    logic [31:0] srcaE, srcbE, writedataE;
    logic [31:0] aluoutE;
    logic        zeroE; // Unused in branch-in-ID architecture
    
    // MEM stage logic
    logic [4:0]  writeregM;
    
    // WB stage logic
    logic [31:0] aluoutW, readdataW, resultW;
    logic [4:0]  writeregW;

    // --- Hazard Unit ---
    hazard h (
        .rsD(rsD), .rtD(rtD), .rsE(rsE), .rtE(rtE),
        .writeregE(writeregE), .writeregM(writeregM), .writeregW(writeregW),
        .regwriteE(regwriteE), .regwriteM(regwriteM), .regwriteW(regwriteW),
        .memtoregE(memtoregE), .memtoregM(memtoregM), .branchD(branchD), .pcsrcD(pcsrcD),
        .forwardaD(forwardaD), .forwardbD(forwardbD),
        .forwardaE(forwardaE), .forwardbE(forwardbE),
        .stallF(stallF), .stallD(stallD), .flushE(flushE)
    );

    // --- IF Stage ---
    mux2 #(32) pcbrmux (
        .d0(pcplus4F), .d1(pcbranchD), .s(pcsrcD), .y(pcnextbrF)
    );
    mux2 #(32) pcmux (
        .d0(pcnextbrF), .d1({pcplus4D[31:28], instrD[25:0], 2'b00}), .s(jumpD), .y(pcnextF)
    );
    
    // PC Register (stalls on Load-Use)
    flopenr #(32) pcreg (
        .clk(clk), .reset(reset), .en(~stallF), .d(pcnextF), .q(pcF)
    );
    adder pcadd1 (
        .a(pcF), .b(32'h4), .y(pcplus4F)
    );

    // --- IF/ID Pipeline Register ---
    // Clears on branch/jump, stalls on Load-Use
    flopenrc #(32) r1D (
        .clk(clk), .reset(reset), .en(~stallD), .clear(pcsrcD | jumpD), .d(instrF), .q(instrD)
    );
    flopenrc #(32) r2D (
        .clk(clk), .reset(reset), .en(~stallD), .clear(pcsrcD | jumpD), .d(pcplus4F), .q(pcplus4D)
    );

    // --- ID Stage ---
    assign opD = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD = instrD[25:21];
    assign rtD = instrD[20:16];
    assign rdD = instrD[15:11];

    regfile rf (
        .clk(clk), .we3(regwriteW), .ra1(rsD), .ra2(rtD),
        .wa3(writeregW), .wd3(resultW), .rd1(rd1D), .rd2(rd2D)
    );

    signext se (.a(instrD[15:0]), .y(signimmD));
    sl2 immsh (.a(signimmD), .y(signimmshD));
    adder pcadd2 (.a(pcplus4D), .b(signimmshD), .y(pcbranchD));

    // Forwarding for branch equality check
    mux2 #(32) eqmuxa (.d0(rd1D), .d1(aluoutM), .s(forwardaD), .y(eqcmpaD));
    mux2 #(32) eqmuxb (.d0(rd2D), .d1(aluoutM), .s(forwardbD), .y(eqcmpbD));
    assign equalD = (eqcmpaD == eqcmpbD);

    // --- ID/EX Pipeline Register ---
    floprc #(32) r1E (.clk(clk), .reset(reset), .clear(flushE), .d(rd1D), .q(rd1E));
    floprc #(32) r2E (.clk(clk), .reset(reset), .clear(flushE), .d(rd2D), .q(rd2E));
    floprc #(32) r3E (.clk(clk), .reset(reset), .clear(flushE), .d(signimmD), .q(signimmE));
    floprc #(5)  r4E (.clk(clk), .reset(reset), .clear(flushE), .d(rsD), .q(rsE));
    floprc #(5)  r5E (.clk(clk), .reset(reset), .clear(flushE), .d(rtD), .q(rtE));
    floprc #(5)  r6E (.clk(clk), .reset(reset), .clear(flushE), .d(rdD), .q(rdE));

    // --- EX Stage ---
    mux3 #(32) amuxE (.d0(rd1E), .d1(resultW), .d2(aluoutM), .s(forwardaE), .y(srcaE));
    mux3 #(32) bmuxE (.d0(rd2E), .d1(resultW), .d2(aluoutM), .s(forwardbE), .y(writedataE));
    mux2 #(32) srcbmuxE (.d0(writedataE), .d1(signimmE), .s(alusrcE), .y(srcbE));
    mux2 #(5)  regdstmuxE (.d0(rtE), .d1(rdE), .s(regdstE), .y(writeregE));

    alu alu_inst (
        .clk(clk), .a(srcaE), .b(srcbE), .alucontrol(alucontrolE),
        .result(aluoutE), .zero(zeroE)
    );

    // --- EX/MEM Pipeline Register ---
    floprc #(32) r1M (.clk(clk), .reset(reset), .clear(1'b0), .d(aluoutE), .q(aluoutM));
    floprc #(32) r2M (.clk(clk), .reset(reset), .clear(1'b0), .d(writedataE), .q(writedataM));
    floprc #(5)  r3M (.clk(clk), .reset(reset), .clear(1'b0), .d(writeregE), .q(writeregM));

    // --- MEM Stage ---
    // (Memory interaction happens outside in computer.sv)

    // --- MEM/WB Pipeline Register ---
    floprc #(32) r1W (.clk(clk), .reset(reset), .clear(1'b0), .d(aluoutM), .q(aluoutW));
    floprc #(32) r2W (.clk(clk), .reset(reset), .clear(1'b0), .d(readdataM), .q(readdataW));
    floprc #(5)  r3W (.clk(clk), .reset(reset), .clear(1'b0), .d(writeregM), .q(writeregW));

    // --- WB Stage ---
    mux2 #(32) resmuxW (.d0(aluoutW), .d1(readdataW), .s(memtoregW), .y(resultW));

endmodule
