`timescale 1ns/1ps

module datapath(
    input  logic        clk, reset,
    input  logic        mem_stall,
    input  logic        hw_int,
    
    input  logic        memtoregE, memtoregM, memtoregW,
    input  logic        pcsrcD, branchD,
    input  logic        alusrcE, regdstE,
    input  logic        regwriteE, regwriteM, regwriteW,
    input  logic        jumpD,
    input  logic [3:0]  alucontrolE,
    
    input  logic        syscallM, eretM, mfc0W, mtc0M,
    
    output logic        equalD,
    output logic [31:0] pcF,
    input  logic [31:0] instrF,
    output logic [31:0] aluoutM, writedataM,
    input  logic [31:0] readdataM,
    
    output logic [31:0] instrD,
    output logic [5:0]  opD, functD,
    output logic        flushE
);

    // Hazard signals
    logic forwardaD, forwardbD;
    logic [1:0] forwardaE, forwardbE;
    logic stallF, stallD;
    logic flush_exc, int_pending;

    // IF stage
    logic [31:0] pcplus4F, pcnextbrF, pcnextF_normal, pcnextF;
    
    // ID stage
    logic [31:0] pcplus4D, signimmD, signimmshD, pcD;
    logic [31:0] rd1D, rd2D;
    logic [4:0]  rsD, rtD, rdD;
    logic [31:0] eqcmpaD, eqcmpbD;
    logic [31:0] pcbranchD;
    
    // EX stage
    logic [31:0] rd1E, rd2E, signimmE, pcE;
    logic [4:0]  rsE, rtE, rdE, writeregE;
    logic [31:0] srcaE, srcbE, writedataE;
    logic [31:0] aluoutE;
    logic        zeroE;
    
    // MEM stage
    logic [4:0]  writeregM, rdM;
    logic [31:0] pcM;
    logic [31:0] cp0_rdM, epc;
    
    // WB stage
    logic [31:0] aluoutW, readdataW, resultW, cp0_rdW;
    logic [4:0]  writeregW;
    logic [31:0] resultW_final;

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
    
    assign flush_exc = syscallM | eretM;

    // --- IF Stage ---
    mux2 #(32) pcbrmux (
        .d0(pcplus4F), .d1(pcbranchD), .s(pcsrcD), .y(pcnextbrF)
    );
    mux2 #(32) pcmux (
        .d0(pcnextbrF), .d1({pcplus4D[31:28], instrD[25:0], 2'b00}), .s(jumpD), .y(pcnextF_normal)
    );
    
    // PC Trap Mux: jump to 0x80 on syscall or async interrupt, or to EPC on eret
    wire trap_to_80 = syscallM | int_pending;
    mux3 #(32) pcexc_mux (
        .d0(pcnextF_normal), .d1(32'h00000080), .d2(epc), .s({eretM, trap_to_80}), .y(pcnextF)
    );
    
    flopenr #(32) pcreg (
        .clk(clk), .reset(reset), .en(~stallF & ~mem_stall), .d(pcnextF), .q(pcF)
    );
    adder pcadd1 (
        .a(pcF), .b(32'h4), .y(pcplus4F)
    );

    // --- IF/ID Pipeline Register ---
    // Flush IF/ID on branch/jump, sync exception, or async interrupt
    wire flush_if_id = pcsrcD | jumpD | flush_exc | int_pending;
    flopenrc #(32) r1D (.clk(clk), .reset(reset), .en(~stallD & ~mem_stall), .clear(flush_if_id), .d(instrF), .q(instrD));
    flopenrc #(32) r2D (.clk(clk), .reset(reset), .en(~stallD & ~mem_stall), .clear(flush_if_id), .d(pcplus4F), .q(pcplus4D));
    flopenrc #(32) r3D (.clk(clk), .reset(reset), .en(~stallD & ~mem_stall), .clear(flush_if_id), .d(pcF), .q(pcD));

    // --- ID Stage ---
    assign opD = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD = instrD[25:21];
    assign rtD = instrD[20:16];
    assign rdD = instrD[15:11];

    regfile rf (
        .clk(clk), .we3(regwriteW), .ra1(rsD), .ra2(rtD),
        .wa3(writeregW), .wd3(resultW_final), .rd1(rd1D), .rd2(rd2D)
    );

    signext se (.a(instrD[15:0]), .y(signimmD));
    sl2 immsh (.a(signimmD), .y(signimmshD));
    adder pcadd2 (.a(pcplus4D), .b(signimmshD), .y(pcbranchD));

    mux2 #(32) eqmuxa (.d0(rd1D), .d1(aluoutM), .s(forwardaD), .y(eqcmpaD));
    mux2 #(32) eqmuxb (.d0(rd2D), .d1(aluoutM), .s(forwardbD), .y(eqcmpbD));
    assign equalD = (eqcmpaD == eqcmpbD);

    // --- ID/EX Pipeline Register ---
    // If int_pending is true, we must also flush ID/EX so the squashed instruction in ID doesn't execute
    wire flush_id_ex = flushE | flush_exc | int_pending;
    flopenrc #(32) r1E (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_id_ex), .d(rd1D), .q(rd1E));
    flopenrc #(32) r2E (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_id_ex), .d(rd2D), .q(rd2E));
    flopenrc #(32) r3E (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_id_ex), .d(signimmD), .q(signimmE));
    flopenrc #(5)  r4E (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_id_ex), .d(rsD), .q(rsE));
    flopenrc #(5)  r5E (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_id_ex), .d(rtD), .q(rtE));
    flopenrc #(5)  r6E (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_id_ex), .d(rdD), .q(rdE));
    flopenrc #(32) r7E (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_id_ex), .d(pcD), .q(pcE));

    // --- EX Stage ---
    mux3 #(32) amuxE (.d0(rd1E), .d1(resultW_final), .d2(aluoutM), .s(forwardaE), .y(srcaE));
    mux3 #(32) bmuxE (.d0(rd2E), .d1(resultW_final), .d2(aluoutM), .s(forwardbE), .y(writedataE));
    mux2 #(32) srcbmuxE (.d0(writedataE), .d1(signimmE), .s(alusrcE), .y(srcbE));
    mux2 #(5)  regdstmuxE (.d0(rtE), .d1(rdE), .s(regdstE), .y(writeregE));

    alu alu_inst (
        .clk(clk), .a(srcaE), .b(srcbE), .alucontrol(alucontrolE),
        .result(aluoutE), .zero(zeroE)
    );

    // --- EX/MEM Pipeline Register ---
    flopenrc #(32) r1M (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_exc), .d(aluoutE), .q(aluoutM));
    flopenrc #(32) r2M (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_exc), .d(writedataE), .q(writedataM));
    flopenrc #(5)  r3M (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_exc), .d(writeregE), .q(writeregM));
    flopenrc #(32) r4M (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_exc), .d(pcE), .q(pcM));
    flopenrc #(5)  r5M (.clk(clk), .reset(reset), .en(~mem_stall), .clear(flush_exc), .d(rdE), .q(rdM));

    // --- MEM Stage ---
    // Coprocessor 0
    cp0 cp0_inst (
        .clk(clk), .reset(reset),
        .we(mtc0M & ~mem_stall),
        .a(rdM),
        .wd(writedataM),
        .rd(cp0_rdM),
        
        .hw_exc(syscallM),
        .hw_exc_epc(pcM),
        .hw_exc_cause(32'd8), // Syscall cause = 8
        
        .hw_int(hw_int),
        .pc_id(pcD), // The instruction we are interrupting/squashing
        .int_pending(int_pending),
        
        .epc(epc)
    );

    // --- MEM/WB Pipeline Register ---
    flopenrc #(32) r1W (.clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0), .d(aluoutM), .q(aluoutW));
    flopenrc #(32) r2W (.clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0), .d(readdataM), .q(readdataW));
    flopenrc #(5)  r3W (.clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0), .d(writeregM), .q(writeregW));
    flopenrc #(32) r4W (.clk(clk), .reset(reset), .en(~mem_stall), .clear(1'b0), .d(cp0_rdM), .q(cp0_rdW));

    // --- WB Stage ---
    mux2 #(32) resmuxW (.d0(aluoutW), .d1(readdataW), .s(memtoregW), .y(resultW));
    mux2 #(32) c0muxW  (.d0(resultW), .d1(cp0_rdW), .s(mfc0W), .y(resultW_final));

endmodule
