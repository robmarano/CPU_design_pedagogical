`timescale 1ns/1ps

module tb_baseline();
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
        $dumpfile("tb_baseline.vcd");
        $dumpvars(0, tb_baseline);
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    integer cycle_count = 0;
    integer instr_count = 0;
    always @(posedge clk) begin
        if (!reset) cycle_count <= cycle_count + 1;
        
        // Count instruction execution in WB stage
        if (!reset && dut.mips.dp.instrF !== 32'h0 && ~dut.mips.mem_stall) begin
            // We can approximate instruction count by measuring how many times a non-stall cycle happens?
            // Actually it's easier to just count how many times WB completes a valid instruction
            // We will just let the loop run.
        end
    end

    always @(negedge clk) begin
        if (memwrite && dut.mips.mem_ready) begin
            if (dataadr === 32'hc8) begin
                if (writedata === 32'd480) begin
                    $display("------------------------------------------------");
                    $display("NO CACHE BASELINE TEST PASSED!");
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
