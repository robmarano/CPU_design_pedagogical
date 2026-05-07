`timescale 1ns/1ps

module tb_regfile();
    logic        clk;
    logic        we3;
    logic [4:0]  ra1, ra2, wa3;
    logic [31:0] wd3;
    logic [31:0] rd1, rd2;

    regfile dut (
        .clk(clk),
        .we3(we3),
        .ra1(ra1),
        .ra2(ra2),
        .wa3(wa3),
        .wd3(wd3),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_regfile.vcd");
        $dumpvars(0, tb_regfile);

        // Initialize
        clk = 0;
        we3 = 0;
        ra1 = 0; ra2 = 0; wa3 = 0; wd3 = 0;

        // Test 1: Read Register 0 (Should be 0)
        #10;
        ra1 = 5'd0;
        #1;
        if (rd1 !== 32'b0) $error("Register 0 is not hardwired to 0!");

        // Test 2: Write to Register 1
        we3 = 1; wa3 = 5'd1; wd3 = 32'hDEADBEEF;
        #10; // Wait for posedge
        we3 = 0;
        ra1 = 5'd1;
        #1;
        if (rd1 !== 32'hDEADBEEF) $error("Write to Register 1 failed. Expected DEADBEEF, got %h", rd1);

        // Test 3: Write to Register 0 (Should still be 0)
        we3 = 1; wa3 = 5'd0; wd3 = 32'hFFFFFFFF;
        #10;
        we3 = 0;
        ra2 = 5'd0;
        #1;
        if (rd2 !== 32'b0) $error("Register 0 was overwritten! It must remain 0.");

        // Test 4: Dual Read
        // Write to Register 2
        we3 = 1; wa3 = 5'd2; wd3 = 32'hCAFEBABE;
        #10;
        we3 = 0;
        ra1 = 5'd1; ra2 = 5'd2;
        #1;
        if (rd1 !== 32'hDEADBEEF || rd2 !== 32'hCAFEBABE) $error("Dual read failed.");

        $display("All Register File tests passed.");
        $finish;
    end
endmodule
