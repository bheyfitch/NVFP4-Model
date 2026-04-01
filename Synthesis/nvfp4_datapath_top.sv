module nvfp4_datapath_top (
    input logic i_clk,
    input logic signed [15:0] i_bf16_vec_a [16],
    input logic signed [15:0] i_bf16_vec_b [16],

    output logic signed [13:0] o_dp
);

logic signed [3:0] nvfp4_out_a [16];
logic signed [3:0] nvfp4_out_b [16];

logic [7:0] factored_out_exp_a;
logic [7:0] factored_out_exp_b;

conv_bf16tomxfp u_conv_a (
    .i_clk(i_clk),
    .i_bf16_vec(i_bf16_vec_a),
    .o_mx_vec(nvfp4_out_a),
    .o_mx_exp(factored_out_exp_a)
);

conv_bf16tomxfp u_conv_b (
    .i_clk(i_clk),
    .i_bf16_vec(i_bf16_vec_b),
    .o_mx_vec(nvfp4_out_b),
    .o_mx_exp(factored_out_exp_b)
);

dot_fp u_dot (
    .i_vec_a(nvfp4_out_a),
    .i_vec_b(nvfp4_out_b),
    .o_dp(o_dp)
);

endmodule