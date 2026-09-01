`timescale 1ns/1ps

module mac_array_4x4 (
    input  wire clk,
    input  wire rst_n,
    input  wire valid_in,
    input  wire signed [127:0] weight_in,
    input  wire signed [127:0] act_in,
    input  wire acc_clear,

    output wire signed [511:0] acc_out,
    output wire [15:0] skipped,
    output wire [15:0] mac_valid
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : PE_ARRAY

            pe pe_inst (
                .clk       (clk),
                .rst_n     (rst_n),
                .valid_in  (valid_in),
                .weight_in (weight_in[i*8 +: 8]),
                .act_in    (act_in[i*8 +: 8]),
                .acc_clear (acc_clear),
                .acc_out   (acc_out[i*32 +: 32]),
                .skipped   (skipped[i]),
                .mac_valid (mac_valid[i])
            );

        end
    endgenerate

endmodule
