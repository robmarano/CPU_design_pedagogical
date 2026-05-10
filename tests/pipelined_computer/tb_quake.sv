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
        .memwrite(memwrite),
        .rx_data(8'h0),
        .rx_valid(1'b0)
    );

    initial begin
        $dumpfile("tb_quake.vcd");
        $dumpvars(0, tb_quake);
        
        $readmemh("memfile.dat", dut.imem.RAM);
        $readmemh("memfile.dat", dut.dmem.RAM);
        
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

    integer cycle = 0;
    always @(posedge clk) begin
        if (!reset) cycle <= cycle + 1;
    end

    always @(negedge clk) begin
        if (memwrite && dut.dcache.cpu_ready) begin 
            if (dataadr === 32'h10) begin // 16 = 0x10
                if (writedata === 32'h3f34f95e || writedata === 32'h3f34f95f) begin
                    $display("------------------------------------------------");
                    $display("[1;32mQUAKE III FAST INVERSE SQUARE ROOT PASSED![0m");
                    $display("Hardware correctly executed the Carmack magic number algorithm!");
                    $display("Result Float Hex: %h (~0.706929)", writedata);
                    $display("Total Execution Cycles: %d", cycle);
                    $display("");
                    $display("[1;37mWHY DOES THIS PROVE IT WORKED?[0m");
                    $display("1. The pipeline correctly bypassed data between the integer ALU and FPU.");
                    $display("2. The unified register file successfully type-punned floats to integers.");
                    $display("3. The hardware executed the Quake 3 Fast Inverse Square Root algorithm:");
                    $display("     y = y * (1.5 - (x2 * y * y))");
                    $display("");
                    $display("This demonstrates full pipeline, memory, and FPU integration.");
                    $display("------------------------------------------------");
                    $finish;
                end else begin
                    $display("[1;31mFAILED: wrote %h instead of 3f34f95e[0m", writedata);
                    $finish;
                end
            end
        end
    end
    
    initial begin
        #50000;
        $display("[1;31mSimulation Failed: Timeout reached.[0m");
        $finish;
    end

endmodule
