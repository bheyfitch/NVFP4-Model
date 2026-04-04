`timescale 1ns/1ps

module tb_quantization_error_datapath;

// Inputs
logic i_clk;
logic [15:0] i_bf16_vec [16];

// Outputs
logic [15:0] o_original_bf16_vec   [16];
logic [15:0] o_dequantized_bf16_vec [16];

quantization_error_datapath uut (
    .i_clk(i_clk),
    .i_bf16_vec(i_bf16_vec),
    .o_original_bf16_vec(o_original_bf16_vec),
    .o_dequantized_bf16_vec(o_dequantized_bf16_vec)
);

// Clock generation
initial begin
    i_clk = 0;
    forever #10 i_clk = ~i_clk;
end

initial begin

    // Test 1: all 1.0 - expect zero quantization error
    for (int i = 0; i < 16; i++) i_bf16_vec[i] = 16'h3F80;
    repeat(6) @(posedge i_clk); #1;
    $display("Test 1 - Original: 0x%04X, Dequantized: 0x%04X, Match: %0d", 
              o_original_bf16_vec[0], o_dequantized_bf16_vec[0], 
              o_original_bf16_vec[0] == o_dequantized_bf16_vec[0]);

    // Test 2: all 1.5 - expect zero quantization error
    for (int i = 0; i < 16; i++) i_bf16_vec[i] = 16'h3FC0;
    repeat(6) @(posedge i_clk); #1;
    $display("Test 2 - Original: 0x%04X, Dequantized: 0x%04X, Match: %0d", 
              o_original_bf16_vec[0], o_dequantized_bf16_vec[0], 
              o_original_bf16_vec[0] == o_dequantized_bf16_vec[0]);

    // Test 3: all 2.0 - expect zero quantization error
    for (int i = 0; i < 16; i++) i_bf16_vec[i] = 16'h4000;
    repeat(6) @(posedge i_clk); #1;
    $display("Test 3 - Original: 0x%04X, Dequantized: 0x%04X, Match: %0d", 
              o_original_bf16_vec[0], o_dequantized_bf16_vec[0], 
              o_original_bf16_vec[0] == o_dequantized_bf16_vec[0]);

    // Test 4: mixed values - expect nonzero quantization error
    for (int i = 0; i < 16; i++) i_bf16_vec[i] = (i % 2 == 0) ? 16'h3F80 : 16'h3E00;
    repeat(6) @(posedge i_clk); #1;
    $display("Test 4 - Original[0]: 0x%04X, Dequantized[0]: 0x%04X, Match: %0d", 
              o_original_bf16_vec[0], o_dequantized_bf16_vec[0],
              o_original_bf16_vec[0] == o_dequantized_bf16_vec[0]);
    $display("Test 4 - Original[1]: 0x%04X, Dequantized[1]: 0x%04X, Match: %0d", 
              o_original_bf16_vec[1], o_dequantized_bf16_vec[1],
              o_original_bf16_vec[1] == o_dequantized_bf16_vec[1]);

    $stop;

end

endmodule