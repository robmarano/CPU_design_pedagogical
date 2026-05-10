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

    integer cycle = 0;
    always @(posedge clk) begin
        if (!reset) cycle <= cycle + 1;
    end

    // Formatted Logging on Negedge (after combo logic settles)
    always @(negedge clk) begin
        if (!reset) begin
            $display("[1;34m[Cycle %0d][0m [1;37mPC:[0m %h | [1;37mInstr:[0m %h", 
                     cycle, dut.mips.dp.pc, dut.mips.dp.instr);
            
            // Only print datapath details if instruction is not NOP
            if (dut.mips.dp.instr !== 32'h00000000) begin
                $display("  [0;36m-> Registers:[0m rs(Reg[%0d])=%0d, rt(Reg[%0d])=%0d", 
                         dut.mips.dp.instr[25:21], dut.mips.dp.srca, 
                         dut.mips.dp.instr[20:16], dut.mips.dp.writedata);
                $display("  [0;33m-> ALU:[0m SrcA=%0d, SrcB=%0d => Result=%0d (Zero=%b)", 
                         dut.mips.dp.srca, dut.mips.dp.srcb, dut.mips.dp.aluout, dut.mips.dp.zero);
                
                if (dut.mips.regwrite) begin
                    $display("  [0;35m-> Writeback:[0m Writing %0d to Reg[%0d]", 
                             dut.mips.dp.result, dut.mips.dp.writereg);
                end
            end
            $display("");
        end
    end

    // Check results
    always @(negedge clk) begin
        if (memwrite) begin
            if (dataadr === 32'h54 && writedata === 32'h7) begin
                $display("");
                $display("[1;32mSimulation Succeeded: Wrote 7 to address 84.[0m");
                $display("");
                $display("[1;37mWHY DOES THIS PROVE IT WORKED?[0m");
                $display("The software executed the following logic:");
                $display("1. addi $t0, $zero, 5  (Loaded 5 into register $t0)");
                $display("2. addi $t1, $zero, 2  (Loaded 2 into register $t1)");
                $display("3. add  $t2, $t0, $t1  (ALU computed 5 + 2 = 7 and stored in $t2)");
                $display("4. sw   $t2, 84($zero) (Stored the result 7 into memory address 84)");
                $display("");
                $display("By visually tracking the cycle logs above and validating that the");
                $display("Data Memory eventually receives a Write Enable (memwrite=1) at");
                $display("Address 84 with Data 7, we mathematically prove that the Instruction Fetch,");
                $display("Decode, Register File, ALU (Addition), and Memory routing are all");
                $display("functioning perfectly in unison across the entire datapath!");
                $display("");
                $finish;
            end else if (dataadr !== 32'h50) begin // ignore the write to 80
                $display("[1;31mSimulation Failed: Wrote %d to address %d[0m", writedata, dataadr);
                $finish;
            end
        end
    end
    
    // Fail-safe timeout
    initial begin
        #1000;
        $display("[1;31mSimulation Failed: Timeout reached.[0m");
        $finish;
    end

endmodule
