`timescale 1ns/1ps

module tb_flopenr();
    logic        clk;
    logic        reset;
    logic        en;
    logic [31:0] d;
    logic [31:0] q;

    flopenr dut(.*);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_flopenr.vcd");
        $dumpvars(0, tb_flopenr);

        clk = 0; reset = 1; en = 0; d = 32'hAAAA_BBBB; #15;
        reset = 0;
        if (q !== 32'b0) $error("Reset failed.");

        // Should not write because en=0
        #10;
        if (q !== 32'b0) $error("Wrote while en=0.");

        // Enable write
        en = 1; #10;
        if (q !== 32'hAAAA_BBBB) $error("Write failed while en=1.");

        // Disable write, change D
        en = 0; d = 32'hDEAD_BEEF; #10;
        if (q !== 32'hAAAA_BBBB) $error("Wrote while en=0 (Hold failed).");

        $display("All flopenr tests passed.");
        $finish;
    end
endmodule
