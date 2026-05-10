`timescale 1ns/1ps

module computer(
    input  logic        clk, reset,
    
    // Original Testbench ports
    output logic [31:0] writedata, dataadr,
    output logic        memwrite,
    
    // UART MMIO ports (for Verilator)
    input  logic [7:0]  rx_data,
    input  logic        rx_valid,
    output logic        rx_ack,
    output logic [7:0]  tx_data,
    output logic        tx_write
);

    logic [31:0] pc, instr;
    
    // CPU to Memory Hierarchy connections
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
    logic [31:0]  mem_read_word;
    logic         mem_ready;

    // --- MMIO Address Decoder ---
    // Memory map:
    // 0x00000000 - 0x00001FFF : Regular Data Memory
    // 0x00007F00 : UART RX Status (Read: bit 0 = rx_valid)
    // 0x00007F04 : UART RX Data (Read clears rx_valid)
    // 0x00007F08 : UART TX Status (Read: bit 0 = always 1 for ready)
    // 0x00007F0C : UART TX Data (Write sends char to terminal)
    
    wire is_mmio = (cpu_req_addr[31:16] == 16'h0000) && (cpu_req_addr[15:8] == 8'h7F);
    
    // Cache masking (don't cache MMIO)
    wire cache_req_read  = cpu_req_read  & ~is_mmio;
    wire cache_req_write = cpu_req_write & ~is_mmio;
    
    logic        cache_ready;
    logic [31:0] cache_read_data;
    
    // MMIO Read Multiplexing
    logic [31:0] mmio_read_data;
    
    always_comb begin
        mmio_read_data = 32'b0;
        if (cpu_req_read && is_mmio) begin
            case (cpu_req_addr[7:0])
                8'h00: mmio_read_data = {31'b0, rx_valid};
                8'h04: mmio_read_data = {24'b0, rx_data};
                8'h08: mmio_read_data = 32'h1; // TX always ready
                default: mmio_read_data = 32'b0;
            endcase
        end
    end

    // Top level read data and ready multiplexing
    assign cpu_read_data = is_mmio ? mmio_read_data : cache_read_data;
    assign cpu_ready     = is_mmio ? 1'b1           : cache_ready;

    // MMIO Writes and Acks
    assign tx_data  = cpu_req_data[7:0];
    assign tx_write = (cpu_req_write && cpu_req_addr == 32'h00007F0C);
    
    // Pulse rx_ack when reading RX data
    assign rx_ack = (cpu_req_read && cpu_req_addr == 32'h00007F04);

    // Outputs for old testbenches
    assign writedata = cpu_req_data;
    assign dataadr   = cpu_req_addr;
    assign memwrite  = cpu_req_write;

    // Hardware Interrupt Generation
    wire hw_int = rx_valid;

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
        .mem_ready(cpu_ready),
        .hw_int(hw_int)
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
        .cpu_req_read(cache_req_read),
        .cpu_req_write(cache_req_write),
        .cpu_read_data(cache_read_data),
        .cpu_ready(cache_ready),
        
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
