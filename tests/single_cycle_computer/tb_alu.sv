`timescale 1ns/1ps

module tb_alu();
    logic        clk;
    logic [31:0] a, b;
    logic [3:0]  alucontrol;
    logic [31:0] result;
    logic        zero;
    int          errors;

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
        errors = 0;
        
        // Test ADD
        a = 32'd10; b = 32'd5; alucontrol = 4'b0010; #10;
        if (result !== 32'd15) begin $error("ADD failed"); errors++; end

        // Test SUB
        a = 32'd10; b = 32'd5; alucontrol = 4'b0110; #10;
        if (result !== 32'd5) begin $error("SUB failed"); errors++; end

        // Test AND
        a = 32'hFFFF0000; b = 32'h00FFFF00; alucontrol = 4'b0000; #10;
        if (result !== 32'h00FF0000) begin $error("AND failed"); errors++; end

        // Test OR
        a = 32'hFFFF0000; b = 32'h0000FFFF; alucontrol = 4'b0001; #10;
        if (result !== 32'hFFFFFFFF) begin $error("OR failed"); errors++; end

        // Test NOR
        a = 32'h00000000; b = 32'h00000000; alucontrol = 4'b0011; #10;
        if (result !== 32'hFFFFFFFF) begin $error("NOR failed"); errors++; end

        // Test SLT (Positive)
        a = 32'd5; b = 32'd10; alucontrol = 4'b0111; #10;
        if (result !== 32'd1) begin $error("SLT (pos) failed"); errors++; end

        // Test SLT (Negative)
        a = 32'hFFFFFFFF; // -1
        b = 32'd0; 
        alucontrol = 4'b0111; #10;
        if (result !== 32'd1) begin $error("SLT (neg) failed"); errors++; end

        // Test MULT (Sequential on negedge)
        a = 32'hFFFFFFFF; // -1
        b = 32'd5; 
        alucontrol = 4'b1000; // MULT
        #10; // Wait for clock edge
        
        alucontrol = 4'b0100; // MFLO
        #10;
        if (result !== 32'hFFFFFFFB) begin $error("MFLO failed for MULT. Expected -5, got %h", result); errors++; end
        
        alucontrol = 4'b0101; // MFHI
        #10;
        if (result !== 32'hFFFFFFFF) begin $error("MFHI failed for MULT. Expected -1 (sign extension), got %h", result); errors++; end

        // Test DIV (Sequential on negedge)
        a = 32'd17; b = 32'd3; 
        alucontrol = 4'b1001; // DIV
        #10;
        
        alucontrol = 4'b0100; // MFLO (Quotient)
        #10;
        if (result !== 32'd5) begin $error("MFLO failed for DIV. Expected 5, got %d", result); errors++; end

        alucontrol = 4'b0101; // MFHI (Remainder)
        #10;
        if (result !== 32'd2) begin $error("MFHI failed for DIV. Expected 2, got %d", result); errors++; end

        if (errors == 0) begin
            $display("All ALU tests passed.");
        end else begin
            $display("%d tests failed.", errors);
        end
        
        $finish;
    end
endmodule
