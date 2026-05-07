`timescale 1ns/1ps

module maindec(
    input  logic [5:0] op,
    output logic       memtoreg, memwrite,
    output logic       branch, alusrc,
    output logic       regdst, regwrite,
    output logic       jump,
    output logic [1:0] aluop
);

    logic [8:0] controls;

    // Split the 9-bit control bus into individual signals
    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

    always_comb begin
        case(op)
            6'b000000: controls = 9'b110000010; // R-type
            6'b100011: controls = 9'b101001000; // lw
            6'b101011: controls = 9'b001010000; // sw
            6'b000100: controls = 9'b000100001; // beq
            6'b001000: controls = 9'b101000000; // addi
            6'b000010: controls = 9'b000000100; // j
            default:   controls = 9'bxxxxxxxxx; // Illegal op
        endcase
    end

endmodule
