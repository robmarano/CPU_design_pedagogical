`timescale 1ns/1ps

module tb_quake();
    logic        clk;
    logic        reset;
    logic [31:0] writedata, dataadr;
    logic        memwrite;

    computer dut(
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );

    initial begin
        $dumpfile("tb_quake.vcd");
        $dumpvars(0, tb_quake);
        
        $readmemh("programs/memfile_quake3.dat", dut.imem.RAM);
        
        // Preload memory with Q3 constants
        dut.dmem.RAM[0] = 32'h40000000; // 2.0f
        dut.dmem.RAM[1] = 32'h3f000000; // 0.5f
        dut.dmem.RAM[2] = 32'h3fc00000; // 1.5f
        dut.dmem.RAM[3] = 32'h5f3759df; // Magic
        
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    integer cycle_count = 0;
    always @(posedge clk) begin
        if (!reset) cycle_count <= cycle_count + 1;
    end

    always @(negedge clk) begin
        if (memwrite && dut.dcache.cpu_ready) begin 
            if (dataadr === 32'h10) begin // 16 = 0x10
                if (writedata === 32'h3f34f95e || writedata === 32'h3f34f95f) begin
                    $display("------------------------------------------------");
                    $display("QUAKE III FAST INVERSE SQUARE ROOT PASSED!");
                    $display("Hardware correctly executed the Carmack magic number algorithm!");
                    $display("Result Float Hex: %h (~0.706929)", writedata);
                    $display("Total Execution Cycles: %d", cycle_count);
                    $display("------------------------------------------------");
                    $finish;
                end else begin
                    $display("FAILED: wrote %h instead of 3f34f95e", writedata);
                    $finish;
                end
            end
        end
    end
    
    initial begin
        #50000;
        $display("Simulation Failed: Timeout reached.");
        $finish;
    end

endmodule
