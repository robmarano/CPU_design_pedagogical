`timescale 1ns/1ps

module aludec(
    input  logic [5:0] funct,
    input  logic [1:0] aluop,
    output logic [3:0] alucontrol
);

    always_comb begin
        case(aluop)
            2'b00: alucontrol = 4'b0010;  // add (for lw/sw/addi)
            2'b01: alucontrol = 4'b0110;  // sub (for beq)
            2'b10: case(funct)          // R-type instructions
                6'b100000: alucontrol = 4'b0010; // add
                6'b100010: alucontrol = 4'b0110; // sub
                6'b100100: alucontrol = 4'b0000; // and
                6'b100101: alucontrol = 4'b0001; // or
                6'b101010: alucontrol = 4'b0111; // slt
                6'b100111: alucontrol = 4'b0011; // nor
                6'b011000: alucontrol = 4'b1000; // mult
                6'b011010: alucontrol = 4'b1001; // div
                6'b010000: alucontrol = 4'b0101; // mfhi
                6'b010010: alucontrol = 4'b0100; // mflo
                default:   alucontrol = 4'bxxxx; // ???
            endcase
            default: alucontrol = 4'bxxxx;
        endcase
    end

endmodule
