`timescale 1ns/1ps

module cpu(
    input  logic        clk, reset,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic        memwrite,
    output logic [31:0] aluout, writedata,
    input  logic [31:0] readdata
);

    logic       memtoreg, alusrc, regdst, regwrite, jump, pcsrc, zero;
    logic [1:0] aluop;
    logic [3:0] alucontrol;
    logic       branch;
    logic       bne;

    assign bne = (instr[31:26] == 6'b000101);

    // Main Decoder
    maindec md (
        .op(instr[31:26]),
        .memtoreg(memtoreg),
        .memwrite(memwrite),
        .branch(branch),
        .alusrc(alusrc),
        .regdst(regdst),
        .regwrite(regwrite),
        .jump(jump),
        .aluop(aluop)
    );

    // ALU Control Decoder
    aludec ad (
        .funct(instr[5:0]),
        .aluop(aluop),
        .alucontrol(alucontrol)
    );

    // Branch logic
    assign pcsrc = branch & (bne ? ~zero : zero);

    // Datapath
    datapath dp (
        .clk(clk), 
        .reset(reset),
        .memtoreg(memtoreg), 
        .pcsrc(pcsrc),
        .alusrc(alusrc), 
        .regdst(regdst),
        .regwrite(regwrite), 
        .jump(jump),
        .alucontrol(alucontrol),
        .zero(zero),
        .pc(pc),
        .instr(instr),
        .aluout(aluout), 
        .writedata(writedata),
        .readdata(readdata)
    );

endmodule
