`timescale 1ns/1ps

module tb_computer();
    logic        clk;
    logic        reset;
    logic [31:0] writedata, dataadr;
    logic        memwrite;

    // Instantiate device to be tested
    computer dut(
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );

    // Initialize test
    initial begin
        $dumpfile("tb_computer.vcd");
        $dumpvars(0, tb_computer);
        
        reset <= 1; #22; reset <= 0;
    end

    // Generate clock to sequence tests
    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    // Check results
    always @(negedge clk) begin
        if (memwrite) begin
            if (dataadr === 32'h54 && writedata === 32'h7) begin
                $display("Simulation Succeeded: Wrote 7 to address 84.");
                $finish;
            end else if (dataadr !== 32'h50) begin // ignore the write to 80
                $display("Simulation Failed: Wrote %d to address %d", writedata, dataadr);
                $finish;
            end
        end
    end
    
    // Fail-safe timeout
    initial begin
        #1000;
        $display("Simulation Failed: Timeout reached.");
        $finish;
    end

endmodule
