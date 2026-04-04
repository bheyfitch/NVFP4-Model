module quantization_error_datapath #(
    parameter freq_mhz = 400)
    (
    input logic i_clk,
    input logic [15:0] i_bf16_vec [16],

    output logic [15:0] o_original_bf16_vec   [16],
    output logic [15:0] o_dequantized_bf16_vec [16]
);

logic [3:0] nvfp4_vec [16];
logic [7:0] shared_exp;

// Pipeline registers from conv_bf16tonvfp4
localparam pl_pre_shift_rnd = freq_mhz > 200 ? 1 : 0;
localparam max_flop_output  = freq_mhz > 100 ? 1 : 0;
localparam max_pl_freq      = (freq_mhz > 200) ? 2 :
                             ((freq_mhz > 100) ? 4 : 8);
localparam max_pl_depth     = ($clog2(16) / max_pl_freq) + max_flop_output;

// Total number of registers including the output register in conv_bf16tonvfp4 and the singlular output register in conv_nvfp4tobf16 (not pipelined).
localparam PIPE_DEPTH       = max_pl_depth + pl_pre_shift_rnd + 1 + 1;

// This module has a 5 clk cycle delay (max_pl_depth + pl_pre_shift_rnd + 1 output flop).
conv_bf16tonvfp4 #(
    .freq_mhz(freq_mhz)
) u_quantize (
    .i_clk(i_clk),
    .i_bf16_vec(i_bf16_vec),
    .o_mx_vec(nvfp4_vec),
    .o_mx_exp(shared_exp)
);

// THis module has a 1 clk cycle delay (Has one always_ff block, and not pipelined).
conv_nvfp4tobf16 u_dequantize (
    .i_clk(i_clk),
    .i_mx_vec(nvfp4_vec),
    .i_mx_exp(shared_exp),
    .o_bf16_vec(o_dequantized_bf16_vec)
);

logic [15:0] delay_buf [PIPE_DEPTH][16];

// Creates a delay of PIPE_DEPTH clock cycles by creating a 2D array 
// and cascading the input vector (row) one row down the array per clock cycle.

// This is done to wait for the quantization logic to catch up before we sample its output.
always_ff @(posedge i_clk) begin
    for (int i = 0; i < 16; i++) begin
        delay_buf[0][i] <= i_bf16_vec[i];
    end
    for (int d = 1; d < PIPE_DEPTH; d++) begin
        for (int i = 0; i < 16; i++) begin
            delay_buf[d][i] <= delay_buf[d-1][i];
        end
    end
end

assign o_original_bf16_vec = delay_buf[PIPE_DEPTH-1];

endmodule