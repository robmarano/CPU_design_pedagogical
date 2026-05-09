`timescale 1ns/1ps

module tb_exceptions_before();
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
        $dumpfile("tb_exceptions_before.vcd");
        $dumpvars(0, tb_exceptions_before);
        
        // Load the memory BEFORE the reset finishes
        $readmemh("programs/memfile_exc_before.dat", dut.imem.RAM);
        $readmemh("programs/memfile_exc_before.dat", dut.dmem.RAM);
        
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
        if (memwrite && dut.dcache.cpu_ready) begin // Assuming we are testing with cache
            if (dataadr === 32'hc8) begin
                if (writedata === 32'd99) begin
                    $display("------------------------------------------------");
                    $display("EXCEPTION BEFORE TEST PASSED!");
                    $display("Syscall was ignored as expected. Result = 99");
                    $display("Total Execution Cycles: %d", cycle_count);
                    $display("------------------------------------------------");
                    $finish;
                end else begin
                    $display("FAILED: wrote %d instead of 99", writedata);
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
