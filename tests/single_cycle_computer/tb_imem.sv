`timescale 1ns/1ps

module tb_imem();
    logic [31:0] a;
    logic [31:0] rd;

    imem dut (
        .a(a),
        .rd(rd)
    );

    initial begin
        $dumpfile("tb_imem.vcd");
        $dumpvars(0, tb_imem);

        // Address 0x00 (Word 0)
        a = 32'h00000000; #10;
        if (rd !== 32'h00000000) $error("IMEM Read failed at 0x00. Got %h", rd);

        // Address 0x04 (Word 1) -> byte addressable, so jump by 4
        a = 32'h00000004; #10;
        if (rd !== 32'h20080005) $error("IMEM Read failed at 0x04. Got %h", rd);

        // Address 0x08 (Word 2)
        a = 32'h00000008; #10;
        if (rd !== 32'h2009000a) $error("IMEM Read failed at 0x08. Got %h", rd);

        // Address 0x1C (Word 7)
        a = 32'h0000001C; #10;
        if (rd !== 32'hFFFFFFFF) $error("IMEM Read failed at 0x1C. Got %h", rd);

        $display("All IMEM tests passed.");
        $finish;
    end
endmodule
