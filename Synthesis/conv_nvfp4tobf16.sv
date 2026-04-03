module conv_nvfp4tobf16 #(
    parameter exp_width = 2,
    parameter man_width = 1,
    parameter bit_width = 1 + exp_width + man_width,
    parameter k = 16
)(
    input  logic i_clk,

    input  logic [bit_width-1:0] i_mx_vec [k],
    input  logic           [7:0] i_mx_exp,
    output logic          [15:0] o_bf16_vec [k]
);

    genvar i;

    // Split NVFP4 inputs into sign, exp, man fields.
    logic        p0_sgns [k];
    logic [1:0]  p0_exps [k];
    logic        p0_mans [k];

    generate

    always_comb begin
        for (int i = 0; i < k; i++) begin
            p0_sgns[i] = i_mx_vec[i][3];
            p0_exps[i] = i_mx_vec[i][2:1];
            p0_mans[i] = i_mx_vec[i][0];
        end
    end

    // Compute BF16 exponent: shared_exp + 2 - 3 + elem_exp = shared_exp - 1 + elem_exp
    logic [7:0] p0_bf16_exps [k];

    always_comb begin
        for (int i = 0; i < k; i++) begin
            p0_bf16_exps[i] = i_mx_exp + 8'd1 + {6'b0, p0_exps[i]};  // shared_exp + 2 - 3 + elem_exp
        end
    end

    // Compute BF16 mantissa: man=0 -> 0b0000000, man=1 -> 0b1000000
    logic [6:0] p0_bf16_mans [k];

    always_comb begin
        for (int i = 0; i < k; i++) begin
            p0_bf16_mans[i] = p0_mans[i] ? 7'b1000000 : 7'b0000000;
        end
    end

    // Pack into BF16, zero out if exp=0 and man=0.
    always_ff @(posedge i_clk) begin
        for (int i = 0; i < k; i++) begin
            if (p0_exps[i] == 2'b00 && p0_mans[i] == 1'b0) begin
                o_bf16_vec[i] <= 16'h0000;
            end else begin
                o_bf16_vec[i] <= {p0_sgns[i], p0_bf16_exps[i], p0_bf16_mans[i]};
            end
        end
    end

    endgenerate

endmodule