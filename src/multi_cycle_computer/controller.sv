`timescale 1ns/1ps

module controller(
    input  logic       clk, reset,
    input  logic [5:0] op, funct,
    input  logic       zero,
    output logic       pcen, memread, memwrite,
    output logic       irwrite, regwrite,
    output logic       alusrca, iord, memtoreg, regdst,
    output logic [1:0] alusrcb, pcsource,
    output logic [3:0] alucontrol
);

    logic [1:0] aluop;
    logic       branch, pcwrite;

    // Instantiate Main FSM
    mainfsm fsm (
        .clk(clk),
        .reset(reset),
        .op(op),
        .memread(memread),
        .memwrite(memwrite),
        .alusrca(alusrca),
        .iord(iord),
        .irwrite(irwrite),
        .regwrite(regwrite),
        .regdst(regdst),
        .memtoreg(memtoreg),
        .branch(branch),
        .pcwrite(pcwrite),
        .alusrcb(alusrcb),
        .aluop(aluop),
        .pcsource(pcsource)
    );

    // Reuse the ALU Control Decoder from the Single-Cycle build!
    aludec ad (
        .funct(funct),
        .aluop(aluop),
        .alucontrol(alucontrol)
    );

    // PC Enable Logic: PC writes on a direct PCWrite (e.g. Fetch or Jump) OR a successful Branch
    assign pcen = pcwrite | (branch & zero);

endmodule
