`timescale 1ns/1ps

module tb_maindec();
    logic [5:0] op;
    logic       memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump;
    logic [1:0] aluop;

    maindec dut(.*); // Connect all ports by name implicitly

    initial begin
        $dumpfile("tb_maindec.vcd");
        $dumpvars(0, tb_maindec);

        // Test R-type
        op = 6'b000000; #10;
        if ({regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} !== 9'b110000010) 
            $error("R-type decoding failed.");

        // Test lw
        op = 6'b100011; #10;
        if ({regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} !== 9'b101001000) 
            $error("lw decoding failed.");

        // Test sw
        op = 6'b101011; #10;
        if ({regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} !== 9'b001010000) 
            $error("sw decoding failed.");

        // Test beq
        op = 6'b000100; #10;
        if ({regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} !== 9'b000100001) 
            $error("beq decoding failed.");

        // Test addi
        op = 6'b001000; #10;
        if ({regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} !== 9'b101000000) 
            $error("addi decoding failed.");

        // Test j
        op = 6'b000010; #10;
        if ({regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} !== 9'b000000100) 
            $error("j decoding failed.");

        $display("All Main Decoder tests passed.");
        $finish;
    end
endmodule
