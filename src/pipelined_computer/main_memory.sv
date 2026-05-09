`timescale 1ns/1ps

module main_memory(
    input  logic        clk, reset,
    input  logic        mem_read, mem_write,
    input  logic [31:0] a, wd,
    output logic [31:0] rd,
    output logic        mem_ready
);

    logic [31:0] RAM[0:255]; // 256 words (1024 bytes)
    
    // Initialize registers to zero to prevent X propagation
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            RAM[i] = 32'b0;
        end
        // We do not readmemh. It's written directly by SW INIT.
    end

    // FSM to simulate 5-cycle memory latency
    logic [2:0] state, nextstate;
    localparam IDLE = 3'd0;
    localparam W1   = 3'd1;
    localparam W2   = 3'd2;
    localparam W3   = 3'd3;
    localparam W4   = 3'd4;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else       state <= nextstate;
    end

    always_comb begin
        case(state)
            IDLE: nextstate = (mem_read | mem_write) ? W1 : IDLE;
            W1:   nextstate = W2;
            W2:   nextstate = W3;
            W3:   nextstate = W4;
            W4:   nextstate = IDLE; // mem_ready is high in W4
            default: nextstate = IDLE;
        endcase
    end

    // mem_ready is combinational so the CPU captures data on the same clock edge it leaves W4
    assign mem_ready = (state == W4);

    // Synchronous write at the end of the wait period
    always_ff @(posedge clk) begin
        if (state == W4 && mem_write) begin
            RAM[a[31:2]] <= wd;
        end
    end

    // Combinational read
    assign rd = RAM[a[31:2]];

endmodule
