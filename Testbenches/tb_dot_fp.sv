`timescale 1ns/1ps

module tb_dot_fp;

// Inputs
logic signed [3:0] i_vec_a [16];
logic signed [3:0] i_vec_b [16];

// Outputs
logic signed [13:0] o_dp;

// UUT
dot_fp uut (
    .i_vec_a(i_vec_a),
    .i_vec_b(i_vec_b),
    .o_dp(o_dp)
);

initial begin
    for(int i = 0; i < 16; i++) begin
        i_vec_a[i] = 4'b0110;
    end
    
    for(int i = 0; i < 16; i++) begin
        i_vec_b[i] = 4'b0110;
    end

    #20;

    $display("Dotted output: %d", o_dp);
end

endmodule