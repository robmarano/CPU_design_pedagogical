`timescale 1ns/1ps

module l1_cache(
    input  logic         clk, reset,
    
    // CPU Interface
    input  logic [31:0]  cpu_req_addr,
    input  logic [31:0]  cpu_req_data,
    input  logic         cpu_req_read,
    input  logic         cpu_req_write,
    output logic [31:0]  cpu_read_data,
    output logic         cpu_ready,
    
    // Main Memory Interface
    output logic [31:0]  mem_req_addr,
    output logic [31:0]  mem_req_data,
    output logic         mem_req_read,
    output logic         mem_req_write,
    input  logic [127:0] mem_read_block,
    input  logic         mem_ready
);

    // Cache structure
    // 4 sets (2 bits index)
    // Block size: 4 words (16 bytes, 4 bits offset)
    // Tag: 32 - 2 - 4 = 26 bits
    
    // Cache arrays
    logic [25:0]  tag_array   [3:0];
    logic         valid_array [3:0];
    logic [127:0] data_array  [3:0]; // 4 words per block
    
    // Wire parsing
    wire [1:0]  byte_offset = cpu_req_addr[1:0];
    wire [1:0]  word_offset = cpu_req_addr[3:2];
    wire [1:0]  index       = cpu_req_addr[5:4];
    wire [25:0] tag         = cpu_req_addr[31:6];
    
    // Hit Detection
    wire valid = valid_array[index];
    wire tag_match = (tag_array[index] == tag);
    wire cache_hit = valid & tag_match;
    
    // Data Extraction
    wire [127:0] selected_block = data_array[index];
    wire [31:0]  selected_word;
    assign selected_word = (word_offset == 2'b00) ? selected_block[31:0]   :
                           (word_offset == 2'b01) ? selected_block[63:32]  :
                           (word_offset == 2'b10) ? selected_block[95:64]  :
                                                    selected_block[127:96] ;
                                                    
    
    
    // Controller FSM
    typedef enum logic [1:0] {COMPARE, ALLOCATE} cache_state;
    cache_state state, nextstate;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= COMPARE;
        else       state <= nextstate;
    end
    
    always_comb begin
        case(state)
            COMPARE: begin
                if (cpu_req_read && !cache_hit) 
                    nextstate = ALLOCATE;
                else
                    nextstate = COMPARE;
            end
            ALLOCATE: begin
                if (mem_ready) nextstate = COMPARE;
                else           nextstate = ALLOCATE;
            end
            default: nextstate = COMPARE;
        endcase
    end
    
    // Memory Request Logic
    // Write-Through: pass writes directly to memory.
    assign mem_req_addr  = (state == ALLOCATE) ? {tag, index, 4'b0000} : cpu_req_addr; 
    assign mem_req_data  = cpu_req_data;
    
    assign mem_req_read  = (state == ALLOCATE) && cpu_req_read;
    assign mem_req_write = (state == COMPARE) && cpu_req_write; 
    
    // CPU Ready logic
    always_comb begin
        cpu_ready = 1'b1; // Default
        if (cpu_req_read) begin
            if (state == COMPARE && cache_hit) cpu_ready = 1'b1;
            else if (state == ALLOCATE && mem_ready) cpu_ready = 1'b1; // Bypass data directly
            else cpu_ready = 1'b0;
        end else if (cpu_req_write) begin
            if (state == COMPARE && mem_ready) cpu_ready = 1'b1;
            else cpu_ready = 1'b0;
        end
    end
    
    // Read Data Logic: if allocating and ready, bypass directly from mem_read_block
    wire [31:0] bypassed_word;
    assign bypassed_word = (word_offset == 2'b00) ? mem_read_block[31:0]   :
                           (word_offset == 2'b01) ? mem_read_block[63:32]  :
                           (word_offset == 2'b10) ? mem_read_block[95:64]  :
                                                    mem_read_block[127:96] ;
                                                    
    assign cpu_read_data = (state == ALLOCATE) ? bypassed_word : selected_word;
    
    // Cache Update Logic
    integer i;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<4; i=i+1) valid_array[i] <= 1'b0;
        end else begin
            // On a read miss, allocate the new block when memory is ready
            if (state == ALLOCATE && mem_ready && cpu_req_read) begin
                valid_array[index] <= 1'b1;
                tag_array[index]   <= tag;
                data_array[index]  <= mem_read_block;
            end
            // On a write hit, we must update the cache block to maintain coherence
            else if (state == COMPARE && cpu_req_write && cache_hit && mem_ready) begin
                if (word_offset == 2'b00) data_array[index][31:0]   <= cpu_req_data;
                if (word_offset == 2'b01) data_array[index][63:32]  <= cpu_req_data;
                if (word_offset == 2'b10) data_array[index][95:64]  <= cpu_req_data;
                if (word_offset == 2'b11) data_array[index][127:96] <= cpu_req_data;
            end
        end
    end

endmodule
