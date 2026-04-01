module conv_bf16tomxfp #(
    parameter exp_width = 2,
    parameter man_width = 1,
    parameter bit_width = 1 + exp_width + man_width,
    parameter k = 16,          // Length of input vector.
    parameter freq_mhz = 400   // Target frequency, [0, 400].
)(
    input  logic i_clk,

    input  logic         [15:0] i_bf16_vec [k],    //input array of 16 bit values.
    output logic [bit_width-1:0] o_mx_vec   [k],    //output array of rounded 4 bit values after max shared exponent was factored out.
    output logic           [7:0] o_mx_exp           //shared exponent (which is the max exponent) that was factored out.
);

	 genvar i,j;
	 
	
                                                            //We add registers if the clock frequency is large to meet timing constraints.
    localparam pl_pre_shift_rnd = freq_mhz > 200 ? 1 : 0;   // Insert flops before u_shift_rnd.
    localparam max_flop_output = freq_mhz > 100 ? 1 : 0;    // Add output flops after u_exp_max.
    localparam max_pl_freq  = (freq_mhz > 200) ? 2 :        // Insert flops within u_exp_max.
                             ((freq_mhz > 100) ? 4 : 8);
    // Number of pipeline stages in u_exp_max.
    localparam max_pl_depth = ($clog2(k) / max_pl_freq) + max_flop_output;

    localparam max_exp_elem = 1 << (exp_width-1);

    // Split input into sgn, exp, man fields.
    logic                p0_sgns [k];
    logic unsigned [7:0] p0_exps [k];
    logic unsigned [6:0] p0_mans [k];

    generate

    always_comb begin
        for (int i=0; i<k; i++) begin
            p0_sgns[i] = i_bf16_vec[i][15];
            p0_exps[i] = i_bf16_vec[i][14:7];
            p0_mans[i] = i_bf16_vec[i][6:0];
        end
    end

    // Find E_max, the largest exponent in inputs.
    logic [7:0] p0_e_max;
    logic [7:0] p1_e_max;

    unsigned_max #(
        .width(8),
        .length(k),
        .pl_freq(max_pl_freq),
        .flop_output(0)
    ) u0_exp_max (
        .i_clk(i_clk),
        .i_exps(p0_exps),
        .o_e_max(p0_e_max)
    );

    if(max_flop_output) begin : name1

        always_ff @(posedge i_clk) begin
            p1_e_max <= (p0_e_max >= max_exp_elem) ? p0_e_max : max_exp_elem;
        end

    end else begin : name2
        assign p1_e_max = (p0_e_max >= max_exp_elem) ? p0_e_max : max_exp_elem;
    end

    // Flop inputs to match delay of max component.
    logic                p1_sgns [k];
    logic unsigned [7:0] p1_exps [k];
    logic unsigned [6:0] p1_mans [k];

    for(i=0; i<(max_pl_depth > 0 ? max_pl_depth : 0); i++) begin : max_dly
        
        logic [15:0] p0_bf16_vec [k];

        for(j=0; j<k; j++) begin : name4
            if(i != 0) begin : name45
                always_ff @(posedge i_clk) begin
                    p0_bf16_vec[j] <= max_dly[i-1].p0_bf16_vec[j];
                end

            end else begin : name55
                always_ff @(posedge i_clk) begin
                    p0_bf16_vec[j] <= i_bf16_vec[j];
                end
            end
        end
    end
    
    if(max_pl_depth != 0) begin : name14
        always_comb begin
            for (int i=0; i<k; i++) begin : name6
                p1_sgns[i] = max_dly[max_pl_depth-1].p0_bf16_vec[i][15];
                p1_exps[i] = max_dly[max_pl_depth-1].p0_bf16_vec[i][14:7];
                p1_mans[i] = max_dly[max_pl_depth-1].p0_bf16_vec[i][6:0];
            end
        end
    end
    
    else begin : name7
        always_comb begin
            for (int i=0; i<k; i++) begin : name8
                p1_sgns[i] = i_bf16_vec[i][15];
                p1_exps[i] = i_bf16_vec[i][14:7];
                p1_mans[i] = i_bf16_vec[i][6:0];
            end
        end
    end

    // Second pipeline stage. Calculate amount to shift by.
    logic [7:0] p2_e_max;
    logic [8:0] p2_sh_exp;
    logic [7:0] p2_d_shifts [k];
    logic                p2_sgns [k];
    logic unsigned [7:0] p2_man_exts [k];

    if(pl_pre_shift_rnd) begin : name80
        always_ff @(posedge i_clk) begin
            p2_e_max  <= p1_e_max;
            p2_sh_exp <= p1_e_max - max_exp_elem;

            for (int i=0; i<k; i++) begin : name9
                p2_d_shifts[i] <= p1_e_max - p1_exps[i];
                p2_sgns[i] <= p1_sgns[i];
                p2_man_exts[i] <= |p1_exps[i] ? {1'b1, p1_mans[i]} : {p1_mans[i], 1'b0};
            end
        end

    end else begin : name10
        assign p2_e_max  = p1_e_max;
        assign p2_sh_exp = p1_e_max - max_exp_elem;

        for (i=0; i<k; i++) begin : name11
            assign p2_d_shifts[i] = p1_e_max - p1_exps[i];
            assign p2_sgns[i] = p1_sgns[i];
            assign p2_man_exts[i] = |p1_exps[i] ? {1'b1, p1_mans[i]} : {p1_mans[i], 1'b0};
        end
    end

    // Shift and round output elements.
    logic [bit_width-2:0] p2_elems [k];

    for(i=0; i<k; i++) begin : name12
        fp_rnd_rne # (
            .width_i(8),
            .width_o_exp(exp_width),
            .width_o_man(man_width),
            .width_shift(8)
        ) u0_fp_rnd (
            .i_num(p2_man_exts[i]),
            .i_shift(p2_d_shifts[i]),
            .o_exp(p2_elems[i][man_width+exp_width-1:man_width]),
            .o_man(p2_elems[i][man_width-1:0])
        );
    end

    // Assign outputs.
    always_ff @(posedge i_clk) begin
        o_mx_exp <= (p2_e_max == 8'hff) ? 8'hff : p2_sh_exp;

        for (int i=0; i<k; i++) begin : name13
            o_mx_vec[i] <= {p2_sgns[i], p2_elems[i]};
        end
    end
	 
	 endgenerate

endmodule
