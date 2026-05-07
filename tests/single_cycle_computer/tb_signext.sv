`timescale 1ns/1ps

module tb_signext();
    logic [15:0] a;
    logic [31:0] y;

    signext dut (
        .a(a),
        .y(y)
    );

    initial begin
        $dumpfile("tb_signext.vcd");
        $dumpvars(0, tb_signext);

        // Test Positive Number (0x0005) -> should pad with 0s
        a = 16'h0005; #10;
        if (y !== 32'h00000005) $error("Positive sign extension failed. Got %h", y);

        // Test Largest Positive Number (0x7FFF)
        a = 16'h7FFF; #10;
        if (y !== 32'h00007FFF) $error("Largest positive sign extension failed. Got %h", y);

        // Test Negative Number (0xFFFB = -5) -> should pad with Fs
        a = 16'hFFFB; #10;
        if (y !== 32'hFFFFFFFB) $error("Negative sign extension failed. Got %h", y);

        // Test Largest Negative Number (0x8000)
        a = 16'h8000; #10;
        if (y !== 32'hFFFF8000) $error("Largest negative sign extension failed. Got %h", y);

        $display("All Sign Extender tests passed.");
        $finish;
    end
endmodule
