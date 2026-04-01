`timescale 1ns/1ps

module tb_nvfp4_datapath_top;

// Inputs
logic i_clk;
logic signed [15:0] i_bf16_vec_a [16];
logic signed [15:0] i_bf16_vec_b [16];

// Outputs
logic signed [13:0] o_dp;

// UUT
nvfp4_datapath_top uut (
    .i_clk(i_clk),
    .i_bf16_vec_a(i_bf16_vec_a),
    .i_bf16_vec_b(i_bf16_vec_b),
    .o_dp(o_dp)
);

// Clock generation
initial begin
    i_clk = 0;
    forever #10 i_clk = ~i_clk;
end

initial begin

    for(int i = 0; i < 16; i++) begin
        i_bf16_vec_a[i] = 16'h3F80;
    end

    for(int i = 0; i < 16; i++) begin
        i_bf16_vec_b[i] = 16'h3FC0;
    end

    #400;

    $display("Dotted output: %d", o_dp);

end

endmodule