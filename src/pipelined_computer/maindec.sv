`timescale 1ns/1ps

module maindec(
    input  logic [5:0] op,
    output logic       memtoreg, memwrite, memread,
    output logic       branch, alusrc,
    output logic       regdst, regwrite,
    output logic       jump,
    output logic [1:0] aluop
);

    logic [9:0] controls;

    assign {regwrite, regdst, alusrc, branch, memwrite, memread, memtoreg, jump, aluop} = controls;

    always_comb begin
        case(op)
            //                                    rw_rd_as_br_mw_mr_mt_jp_aluop
            6'b000000: controls = 10'b1_1_0_0_0_0_0_0_10; // R-type
            6'b100011: controls = 10'b1_0_1_0_0_1_1_0_00; // lw
            6'b101011: controls = 10'b0_0_1_0_1_0_0_0_00; // sw
            6'b000100: controls = 10'b0_0_0_1_0_0_0_0_01; // beq
            6'b000101: controls = 10'b0_0_0_1_0_0_0_0_01; // bne (CPU adds ~zero)
            6'b001000: controls = 10'b1_0_1_0_0_0_0_0_00; // addi
            6'b000010: controls = 10'b0_0_0_0_0_0_0_1_00; // j
            default:   controls = 10'b0_0_0_0_0_0_0_0_00; // Default
        endcase
    end

endmodule
