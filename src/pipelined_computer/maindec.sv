`timescale 1ns/1ps

module maindec(
    input  logic [31:0] instr,
    output logic       memtoreg, memwrite, memread,
    output logic       branch, alusrc,
    output logic       regdst, regwrite,
    output logic       jump,
    output logic [1:0] aluop,
    output logic       syscall,
    output logic       eret,
    output logic       mfc0,
    output logic       mtc0
);

    logic [5:0] op;
    logic [5:0] funct;
    logic [4:0] rs;

    assign op    = instr[31:26];
    assign rs    = instr[25:21];
    assign funct = instr[5:0];

    logic [9:0] controls;
    assign {regwrite, regdst, alusrc, branch, memwrite, memread, memtoreg, jump, aluop} = controls;

    always_comb begin
        syscall = 1'b0;
        eret    = 1'b0;
        mfc0    = 1'b0;
        mtc0    = 1'b0;

        case(op)
            //                                    rw_rd_as_br_mw_mr_mt_jp_aluop
            6'b000000: begin
                controls = 10'b1_1_0_0_0_0_0_0_10; // R-type
                if (funct == 6'b001100) begin
                    syscall = 1'b1;
                    controls = 10'b0_0_0_0_0_0_0_0_00; // Do not write registers on syscall
                end
            end
            6'b100011: controls = 10'b1_0_1_0_0_1_1_0_00; // lw
            6'b101011: controls = 10'b0_0_1_0_1_0_0_0_00; // sw
            6'b000100: controls = 10'b0_0_0_1_0_0_0_0_01; // beq
            6'b000101: controls = 10'b0_0_0_1_0_0_0_0_01; // bne 
            6'b001000: controls = 10'b1_0_1_0_0_0_0_0_00; // addi
            6'b000010: controls = 10'b0_0_0_0_0_0_0_1_00; // j
            6'b010000: begin // Coprocessor 0
                if (rs == 5'b00000) begin
                    mfc0 = 1'b1;
                    // mfc0 writes to rt, so regwrite=1, regdst=0 (rt)
                    controls = 10'b1_0_0_0_0_0_0_0_00; 
                end else if (rs == 5'b00100) begin
                    mtc0 = 1'b1;
                    controls = 10'b0_0_0_0_0_0_0_0_00;
                end else if (funct == 6'b011000) begin
                    eret = 1'b1;
                    controls = 10'b0_0_0_0_0_0_0_0_00;
                end else begin
                    controls = 10'b0_0_0_0_0_0_0_0_00;
                end
            end
            default:   controls = 10'b0_0_0_0_0_0_0_0_00; // Default
        endcase
    end

endmodule
