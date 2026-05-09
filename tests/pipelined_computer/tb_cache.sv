`timescale 1ns/1ps

module tb_cache();
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
        $dumpfile("tb_cache.vcd");
        $dumpvars(0, tb_cache);
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
            if (dataadr === 32'hc8) begin
                if (writedata === 32'd480) begin
                    $display("------------------------------------------------");
                    $display("L1 CACHE TEST PASSED!");
                    $display("Total Execution Cycles: %d", cycle_count);
                    $display("------------------------------------------------");
                    $finish;
                end else begin
                    $display("FAILED: wrote %d instead of 480", writedata);
                    $finish;
                end
            end
        end
    end
    
    initial begin
        #5000000;
        $display("Simulation Failed: Timeout reached.");
        $finish;
    end

endmodule
