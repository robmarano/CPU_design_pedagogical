`timescale 1ns/1ps

module computer(
    input  logic        clk, reset,
    output logic [31:0] writedata, dataadr,
    output logic        memwrite
);

    logic [31:0] pc, instr;
    
    // CPU to Cache connections
    logic [31:0] cpu_req_addr;
    logic [31:0] cpu_req_data;
    logic        cpu_req_read;
    logic        cpu_req_write;
    logic [31:0] cpu_read_data;
    logic        cpu_ready;
    
    // Cache to Memory connections
    logic [31:0]  mem_req_addr;
    logic [31:0]  mem_req_data;
    logic         mem_req_read;
    logic         mem_req_write;
    logic [127:0] mem_read_block;
    logic [31:0]  mem_read_word; // Not used by cache, but output by main_memory
    logic         mem_ready;

    // Output assignments for testbench
    assign writedata = cpu_req_data;
    assign dataadr   = cpu_req_addr;
    assign memwrite  = cpu_req_write;

    // Instantiate the Pipelined CPU
    cpu mips (
        .clk(clk), 
        .reset(reset), 
        .pcF(pc), 
        .instrF(instr), 
        .memwriteM(cpu_req_write), 
        .memreadM(cpu_req_read),
        .aluoutM(cpu_req_addr), 
        .writedataM(cpu_req_data), 
        .readdataM(cpu_read_data),
        .mem_ready(cpu_ready) // CPU now waits for cache ready
    );

    // Instantiate Instruction Memory (Fetch Stage)
    imem imem (
        .a(pc), 
        .rd(instr)
    );
    
    // Instantiate L1 Direct-Mapped Cache
    l1_cache dcache (
        .clk(clk),
        .reset(reset),
        
        .cpu_req_addr(cpu_req_addr),
        .cpu_req_data(cpu_req_data),
        .cpu_req_read(cpu_req_read),
        .cpu_req_write(cpu_req_write),
        .cpu_read_data(cpu_read_data),
        .cpu_ready(cpu_ready),
        
        .mem_req_addr(mem_req_addr),
        .mem_req_data(mem_req_data),
        .mem_req_read(mem_req_read),
        .mem_req_write(mem_req_write),
        .mem_read_block(mem_read_block),
        .mem_ready(mem_ready)
    );

    // Instantiate Main Data Memory with 5-cycle Latency
    main_memory dmem (
        .clk(clk), 
        .reset(reset),
        .mem_write(mem_req_write), 
        .mem_read(mem_req_read),
        .a(mem_req_addr), 
        .wd(mem_req_data), 
        .rd(mem_read_word), 
        .rd_block(mem_read_block),
        .mem_ready(mem_ready)
    );

endmodule
