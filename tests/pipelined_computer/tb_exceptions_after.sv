`timescale 1ns/1ps

module tb_exceptions_after();
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
        $dumpfile("tb_exceptions_after.vcd");
        $dumpvars(0, tb_exceptions_after);
        
        // Load the memory
        $readmemh("programs/memfile_exc_after.dat", dut.imem.RAM);
        $readmemh("programs/memfile_exc_after.dat", dut.dmem.RAM);
        
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
            if (dataadr === 32'hc8) begin // 200 = 0xC8
                if (writedata === 32'd101) begin
                    $display("------------------------------------------------");
                    $display("EXCEPTION AFTER TEST PASSED!");
                    $display("Syscall successfully trapped and returned. Result = 101");
                    $display("Total Execution Cycles: %d", cycle_count);
                    $display("------------------------------------------------");
                    $finish;
                end else begin
                    $display("FAILED: wrote %d instead of 101", writedata);
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
