`timescale 1ns/1ps

module fpu(
    input  logic [31:0] a, b,
    input  logic        is_mul, // 1 for mul.s, 0 for sub.s
    output logic [31:0] result
);

    // --- Subtraction (a - b) ---
    logic        sign_a, sign_b_inv;
    logic [7:0]  exp_a, exp_b;
    logic [23:0] frac_a, frac_b; 
    
    assign sign_a = a[31];
    assign exp_a  = a[30:23];
    assign frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
    
    assign sign_b_inv = ~b[31]; 
    assign exp_b  = b[30:23];
    assign frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};

    logic [7:0]  exp_diff;
    logic [23:0] frac_a_shifted, frac_b_shifted;
    logic [7:0]  exp_sub;
    logic [24:0] frac_sub_res; 
    logic        sign_sub;
    
    always @(*) begin
        if (exp_a > exp_b) begin
            exp_diff = exp_a - exp_b;
            frac_a_shifted = frac_a;
            frac_b_shifted = frac_b >> exp_diff;
            exp_sub = exp_a;
        end else begin
            exp_diff = exp_b - exp_a;
            frac_a_shifted = frac_a >> exp_diff;
            frac_b_shifted = frac_b;
            exp_sub = exp_b;
        end
        
        if (sign_a == sign_b_inv) begin
            frac_sub_res = frac_a_shifted + frac_b_shifted;
            sign_sub = sign_a;
        end else begin
            if (frac_a_shifted >= frac_b_shifted) begin
                frac_sub_res = frac_a_shifted - frac_b_shifted;
                sign_sub = sign_a;
            end else begin
                frac_sub_res = frac_b_shifted - frac_a_shifted;
                sign_sub = sign_b_inv;
            end
        end
    end
    
    logic [22:0] frac_sub_norm;
    logic [7:0]  exp_sub_norm;
    
    always @(*) begin
        if (frac_sub_res[24]) begin
            frac_sub_norm = frac_sub_res[23:1];
            exp_sub_norm = exp_sub + 1;
        end else if (frac_sub_res[23]) begin
            frac_sub_norm = frac_sub_res[22:0];
            exp_sub_norm = exp_sub;
        end else if (frac_sub_res[22]) begin
            frac_sub_norm = frac_sub_res[21:0] << 1;
            exp_sub_norm = exp_sub - 1;
        end else if (frac_sub_res[21]) begin
            frac_sub_norm = frac_sub_res[20:0] << 2;
            exp_sub_norm = exp_sub - 2;
        end else if (frac_sub_res[20]) begin
            frac_sub_norm = frac_sub_res[19:0] << 3;
            exp_sub_norm = exp_sub - 3;
        end else if (frac_sub_res[19]) begin
            frac_sub_norm = frac_sub_res[18:0] << 4;
            exp_sub_norm = exp_sub - 4;
        end else if (frac_sub_res[18]) begin
            frac_sub_norm = frac_sub_res[17:0] << 5;
            exp_sub_norm = exp_sub - 5;
        end else if (frac_sub_res[17]) begin
            frac_sub_norm = frac_sub_res[16:0] << 6;
            exp_sub_norm = exp_sub - 6;
        end else begin
            frac_sub_norm = 0;
            exp_sub_norm = 0;
        end
        if (frac_sub_res == 0) begin
            exp_sub_norm = 0;
            frac_sub_norm = 0;
            sign_sub = 0;
        end
    end

    // --- Multiplication (a * b) ---
    logic        sign_mul;
    logic [8:0]  exp_mul_temp; 
    logic [7:0]  exp_mul_norm;
    logic [47:0] frac_mul;     
    logic [22:0] frac_mul_norm;
    
    assign exp_mul_temp = exp_a + exp_b - 127;
    assign frac_mul = frac_a * frac_b;
    
    always @(*) begin
        sign_mul = a[31] ^ b[31];
        if (frac_mul[47]) begin
            frac_mul_norm = frac_mul[46:24]; 
            exp_mul_norm = exp_mul_temp[7:0] + 1;
        end else begin
            frac_mul_norm = frac_mul[45:23];
            exp_mul_norm = exp_mul_temp[7:0];
        end
        
        // Use a bitwise OR reduction instead of equality to avoid warning
        if ((|a[30:0] == 0) || (|b[30:0] == 0)) begin
            exp_mul_norm = 0;
            frac_mul_norm = 0;
            sign_mul = 0;
        end
    end

    assign result = is_mul ? {sign_mul, exp_mul_norm, frac_mul_norm} : 
                             {sign_sub, exp_sub_norm, frac_sub_norm};

endmodule
