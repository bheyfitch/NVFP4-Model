`timescale 1ns/1ps

module tb_conv_nvfp4tobf16;

//Inputs
logic i_clk;
logic [3:0] i_mx_vec [16];
logic [7:0] i_mx_exp;

//Outputs
logic [15:0] o_bf16_vec [16];

conv_nvfp4tobf16 uut (
    .i_clk(i_clk),
    .i_mx_vec(i_mx_vec),
    .i_mx_exp(i_mx_exp),
    .o_bf16_vec(o_bf16_vec)
);

// Clock generation
initial begin
    i_clk = 0;
    forever #10 i_clk = ~i_clk;
end

initial begin
    // Test 1: all 1.0 (NVFP4 = 0110, shared_exp = 125)
    i_mx_exp = 125;
    for (int i = 0; i < 16; i++) i_mx_vec[i] = 4'b0110;
    @(posedge i_clk); #1;
    $display("Test 1 - Expected: 0x3F80, Got: 0x%04X, Pass: %0d", o_bf16_vec[0], o_bf16_vec[0] == 16'h3F80);

    // Test 2: all 1.5 (NVFP4 = 0111, shared_exp = 125)
    i_mx_exp = 125;
    for (int i = 0; i < 16; i++) i_mx_vec[i] = 4'b0111;
    @(posedge i_clk); #1;
    $display("Test 2 - Expected: 0x3FC0, Got: 0x%04X, Pass: %0d", o_bf16_vec[0], o_bf16_vec[0] == 16'h3FC0);

    // Test 3: all 2.0 (NVFP4 = 0110, shared_exp = 126)
    i_mx_exp = 126;
    for (int i = 0; i < 16; i++) i_mx_vec[i] = 4'b0110;
    @(posedge i_clk); #1;
    $display("Test 3 - Expected: 0x4000, Got: 0x%04X, Pass: %0d", o_bf16_vec[0], o_bf16_vec[0] == 16'h4000);

    // Test 4: zero element (NVFP4 = 0000)
    i_mx_exp = 125;
    for (int i = 0; i < 16; i++) i_mx_vec[i] = 4'b0000;
    @(posedge i_clk); #1;
    $display("Test 4 - Expected: 0x0000, Got: 0x%04X, Pass: %0d", o_bf16_vec[0], o_bf16_vec[0] == 16'h0000);

    $stop;
end

endmodule