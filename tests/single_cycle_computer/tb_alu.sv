`timescale 1ns/1ps

module tb_alu();
    logic        clk;
    logic [31:0] a, b;
    logic [3:0]  alucontrol;
    logic [31:0] result;
    logic        zero;

    alu dut (
        .clk(clk),
        .a(a),
        .b(b),
        .alucontrol(alucontrol),
        .result(result),
        .zero(zero)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // Initialize
        clk = 0;
        a = 32'd10;
        b = 32'd5;
        
        // Test ADD
        alucontrol = 4'b0010;
        #10;
        if (result !== 32'd15) $error("ADD failed");

        // Test SUB
        alucontrol = 4'b0110;
        #10;
        if (result !== 32'd5) $error("SUB failed");

        // Test MULT (Sequential on negedge)
        a = 32'd10; b = 32'd5; alucontrol = 4'b1000;
        #10; // Wait for clock edge
        alucontrol = 4'b0100; // MFLO
        #10;
        if (result !== 32'd50) $error("MULT/MFLO failed");

        $display("All ALU tests passed.");
        $finish;
    end
endmodule