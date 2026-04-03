`timescale 1ns/1ps

module tb_conv_bf16tonvfp4;

//Inputs
logic i_clk;
logic [15:0] i_bf16_vec [16];

//Outputs
logic [3:0] o_mx_vec [16];
logic [7:0] o_mx_exp;

// Instantiate the Unit Under Test (UUT)
conv_bf16tonvfp4 uut (
    .i_clk(i_clk),
    .i_bf16_vec(i_bf16_vec),
    .o_mx_vec(o_mx_vec),
    .o_mx_exp(o_mx_exp)
);

//Clock generation
initial begin
    i_clk = 0;
    forever #10 i_clk = ~i_clk;
end

initial begin
    for(int i = 0; i < 16; i++) begin
        i_bf16_vec[i] = 16'h3F80;   // Set all values of the input array to the same number
    end

    #200;                       // Wait 10 clock cycles for output

    $display("Shared exponent: %d", o_mx_exp);

    for(int i=0; i<16; i++) begin
        $display("nvfp4_out[%0d] = %b", i, o_mx_vec[i]);
    end

    #200;

    for(int i = 0; i < 16; i++) begin
        i_bf16_vec[i] = 16'h4000;   // Set all values of the input array to the same number
    end

    #200;                       // Wait 10 clock cycles for output

    $display("Shared exponent: %d", o_mx_exp);

    for(int i=0; i<16; i++) begin
        $display("nvfp4_out[%0d] = %b", i, o_mx_vec[i]);
    end

    #200;

    for(int i = 0; i < 16; i++) begin
        i_bf16_vec[i] = 16'h4080;   // Set all values of the input array to the same number
    end

    #200;                       // Wait 10 clock cycles for output

    $display("Shared exponent: %d", o_mx_exp);

    for(int i=0; i<16; i++) begin
        $display("nvfp4_out[%0d] = %b", i, o_mx_vec[i]);
    end

    #200;

    for(int i = 0; i < 16; i++) begin
        i_bf16_vec[i] = 16'h4100;   // Set all values of the input array to the same number
    end

    #200;                       // Wait 10 clock cycles for output

    $display("Shared exponent: %d", o_mx_exp);

    for(int i=0; i<16; i++) begin
        $display("nvfp4_out[%0d] = %b", i, o_mx_vec[i]);
    end

    #200;

    $finish;
end

endmodule