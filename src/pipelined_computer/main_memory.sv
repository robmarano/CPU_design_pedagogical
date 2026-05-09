`timescale 1ns/1ps

module main_memory(
    input  logic         clk, reset,
    input  logic         mem_read, mem_write,
    input  logic [31:0]  a, wd,
    output logic [31:0]  rd,       // Single word read (for baseline)
    output logic [127:0] rd_block, // 4-word block read (for L1 cache)
    output logic         mem_ready
);

    logic [31:0] RAM[0:255]; // 256 words (1024 bytes)
    
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            RAM[i] = 32'b0;
        end
        // NOTE: Make sure to change the file name for different tests!
        // $readmemh("programs/memfile_exc_before.dat", RAM);
        // We will read it from the testbench using hierarchical names to avoid hardcoding here!
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
            W4:   nextstate = IDLE;
            default: nextstate = IDLE;
        endcase
    end

    assign mem_ready = (state == W4);

    always_ff @(posedge clk) begin
        if (state == W4 && mem_write) begin
            RAM[a[31:2]] <= wd;
        end
    end

    // Single word read
    assign rd = RAM[a[31:2]];

    // Combinational block read aligned to 4-word boundaries.
    wire [31:0] base_addr = {a[31:4], 4'b0000};
    assign rd_block = {
        RAM[base_addr[31:2] + 3],
        RAM[base_addr[31:2] + 2],
        RAM[base_addr[31:2] + 1],
        RAM[base_addr[31:2] + 0]
    };

endmodule
