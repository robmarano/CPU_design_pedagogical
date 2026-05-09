`timescale 1ns/1ps

module mainfsm(
    input  logic       clk, reset,
    input  logic [5:0] op,
    output logic       memread, memwrite, alusrca,
    output logic       iord, irwrite, regwrite, regdst, memtoreg,
    output logic       branch, pcwrite,
    output logic [1:0] alusrcb, aluop, pcsource
);

    typedef enum logic [3:0] {
        FETCH   = 4'd0,
        DECODE  = 4'd1,
        MEMADR  = 4'd2,
        MEMRD   = 4'd3,
        MEMWB   = 4'd4,
        MEMWR   = 4'd5,
        RTYPEEX = 4'd6,
        RTYPEWB = 4'd7,
        BEQEX   = 4'd8,
        ADDIEX  = 4'd9,
        ADDIWB  = 4'd10,
        JEX     = 4'd11
    } statetype;

    statetype state, nextstate;

    // State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= FETCH;
        else       state <= nextstate;
    end

    // Next State Logic
    always_comb begin
        case(state)
            FETCH:   nextstate = DECODE;
            DECODE:  case(op)
                        6'b100011: nextstate = MEMADR;  // lw
                        6'b101011: nextstate = MEMADR;  // sw
                        6'b000000: nextstate = RTYPEEX; // R-type
                        6'b000100: nextstate = BEQEX;   // beq
                        6'b001000: nextstate = ADDIEX;  // addi
                        6'b000010: nextstate = JEX;     // j
                        default:   nextstate = FETCH;   // fallback
                     endcase
            MEMADR:  case(op)
                        6'b100011: nextstate = MEMRD;   // lw
                        6'b101011: nextstate = MEMWR;   // sw
                        default:   nextstate = FETCH;
                     endcase
            MEMRD:   nextstate = MEMWB;
            MEMWB:   nextstate = FETCH;
            MEMWR:   nextstate = FETCH;
            RTYPEEX: nextstate = RTYPEWB;
            RTYPEWB: nextstate = FETCH;
            BEQEX:   nextstate = FETCH;
            ADDIEX:  nextstate = ADDIWB;
            ADDIWB:  nextstate = FETCH;
            JEX:     nextstate = FETCH;
            default: nextstate = FETCH;
        endcase
    end

    // Output Logic
    logic [15:0] controls; // 16 bits! 1+1+1+1+1+1+1+2+2+2+1+1+1 = 16
    assign {iord, memread, memwrite, memtoreg, irwrite, pcwrite, branch, 
            pcsource, aluop, alusrcb, alusrca, regwrite, regdst} = controls;

    always_comb begin
        case(state)
            //                                     mem mem ir  pc      pc   alu alu  alu  reg reg
            //                               iord  rd  wr  2r  wr  wr  br  src   op srcb srca wr  dst
            FETCH:   controls = 16'b0_1_0_0_1_1_0_00_00_01_0_0_0;
            DECODE:  controls = 16'b0_0_0_0_0_0_0_00_00_11_0_0_0;
            MEMADR:  controls = 16'b0_0_0_0_0_0_0_00_00_10_1_0_0;
            MEMRD:   controls = 16'b1_1_0_0_0_0_0_00_00_00_0_0_0;
            MEMWB:   controls = 16'b0_0_0_1_0_0_0_00_00_00_0_1_0;
            MEMWR:   controls = 16'b1_0_1_0_0_0_0_00_00_00_0_0_0;
            RTYPEEX: controls = 16'b0_0_0_0_0_0_0_00_10_00_1_0_0;
            RTYPEWB: controls = 16'b0_0_0_0_0_0_0_00_00_00_0_1_1;
            BEQEX:   controls = 16'b0_0_0_0_0_0_1_01_01_00_1_0_0;
            ADDIEX:  controls = 16'b0_0_0_0_0_0_0_00_00_10_1_0_0;
            ADDIWB:  controls = 16'b0_0_0_0_0_0_0_00_00_00_0_1_0;
            JEX:     controls = 16'b0_0_0_0_0_1_0_10_00_00_0_0_0;
            default: controls = 16'b0_0_0_0_0_0_0_00_00_00_0_0_0;
        endcase
    end

endmodule
