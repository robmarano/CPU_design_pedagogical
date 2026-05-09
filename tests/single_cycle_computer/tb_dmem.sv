`timescale 1ns/1ps

module tb_dmem();
    logic        clk;
    logic        we;
    logic [31:0] a, wd;
    logic [31:0] rd;

    dmem dut (
        .clk(clk),
        .we(we),
        .a(a),
        .wd(wd),
        .rd(rd)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_dmem.vcd");
        $dumpvars(0, tb_dmem);

        // Initialize
        clk = 0;
        we = 0;
        a = 32'd0;
        wd = 32'd0;

        // Test 1: Write to Address 0x10 (Word 4)
        we = 1;
        a = 32'h00000010;
        wd = 32'hDEADBEEF;
        #10; // Wait for posedge clk
        we = 0;

        // Test 2: Read from Address 0x10
        #10;
        if (rd !== 32'hDEADBEEF) $error("DMEM Read failed at 0x10. Got %h", rd);

        // Test 3: Write to Address 0x24 (Word 9)
        we = 1;
        a = 32'h00000024;
        wd = 32'hCAFEBABE;
        #10;
        we = 0;

        // Test 4: Verify previous write remained intact and new write succeeded
        a = 32'h00000010; #10;
        if (rd !== 32'hDEADBEEF) $error("DMEM Data corrupted at 0x10. Got %h", rd);

        a = 32'h00000024; #10;
        if (rd !== 32'hCAFEBABE) $error("DMEM Read failed at 0x24. Got %h", rd);

        $display("All DMEM tests passed.");
        $finish;
    end
endmodule
