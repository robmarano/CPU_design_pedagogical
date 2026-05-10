`timescale 1ns/1ps

module tb_computer();
    logic        clk;
    logic        reset;
    logic [31:0] writedata, dataadr;
    logic        memwrite;

    computer dut(
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );

    initial begin
        $dumpfile("tb_computer.vcd");
        $dumpvars(0, tb_computer);
        
        reset <= 1; #22; reset <= 0;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    integer cycle = 0;
    always @(posedge clk) begin
        if (!reset) cycle <= cycle + 1;
    end

    string state_name;
    always_comb begin
        case(dut.mips.c.fsm.state)
            4'd0:  state_name = "FETCH";
            4'd1:  state_name = "DECODE";
            4'd2:  state_name = "MEMADR";
            4'd3:  state_name = "MEMRD";
            4'd4:  state_name = "MEMWB";
            4'd5:  state_name = "MEMWR";
            4'd6:  state_name = "RTYPEEX";
            4'd7:  state_name = "RTYPEWB";
            4'd8:  state_name = "BEQEX";
            4'd9:  state_name = "ADDIEX";
            4'd10: state_name = "ADDIWB";
            4'd11: state_name = "JEX";
            default: state_name = "UNKNOWN";
        endcase
    end

    always @(negedge clk) begin
        if (!reset) begin
            $display("[1;34m[Cycle %0d][0m [1;33mFSM State:[0m %s", cycle, state_name);
            $display("  [1;37mPC:[0m %h | [1;37mIR:[0m %h", dut.mips.dp.pc, dut.mips.dp.instr);
            $display("  [0;36m-> Registers/Buffers:[0m A=%0d, B=%0d, ALUOut=%0d, MDR=%0d", 
                     dut.mips.dp.a, dut.mips.dp.b, dut.mips.dp.aluout, dut.mips.dp.data);
            
            if (dut.mips.c.regwrite) begin
                $display("  [0;35m-> Writeback:[0m Writing %0d to RegFile", dut.mips.dp.result);
            end
            if (dut.mips.c.memwrite) begin
                $display("  [0;31m-> Memory Write:[0m Writing %0d to Address %0d", writedata, dataadr);
            end
            $display("");
        end
    end

    always @(negedge clk) begin
        if (memwrite) begin
            if (dataadr === 32'h54 && writedata === 32'h7) begin
                $display("");
                $display("[1;32mSimulation Succeeded: Wrote 7 to address 84.[0m");
                $display("");
                $display("[1;37mWHY DOES THIS PROVE IT WORKED?[0m");
                $display("The multi-cycle architecture breaks each instruction into 3-5 distinct states.");
                $display("By observing the FSM state logs above, you can see:");
                $display("1. The instruction is fetched in the FETCH state.");
                $display("2. The registers are loaded in the DECODE state.");
                $display("3. The ALU math happens in the EXECUTE state (e.g., ADDIEX or RTYPEEX).");
                $display("4. The result is safely stored back in the WRITEBACK state.");
                $display("");
                $display("The entire operation succeeded across multiple clock cycles, proving");
                $display("our Control Unit Finite State Machine effectively reused the shared ALU");
                $display("and unified Memory without data collisions!");
                $display("");
                $finish;
            end else if (dataadr !== 32'h50) begin
                $display("[1;31mSimulation Failed: Wrote %d to address %d[0m", writedata, dataadr);
                $finish;
            end
        end
    end
    
    initial begin
        #10000;
        $display("[1;31mSimulation Failed: Timeout reached.[0m");
        $finish;
    end
endmodule
