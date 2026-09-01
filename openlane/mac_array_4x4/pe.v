module pe #(
    parameter DATA_WIDTH=8,
    parameter ACC_WIDTH=32
)(
    input wire clk,
    input wire rst_n,

    input wire signed [DATA_WIDTH-1:0] weight_in,
    input wire signed [DATA_WIDTH-1:0] act_in,
    input wire valid_in,
    input wire acc_clear,

    output reg signed [ACC_WIDTH-1:0] acc_out,
    output reg skipped,
    output reg mac_valid
);

wire is_weight_zero;
wire is_act_zero;
assign is_weight_zero=(weight_in==0);
assign is_act_zero=(act_in==0);
wire do_skip;
assign do_skip=valid_in && (is_weight_zero||is_act_zero);
wire do_mac;
assign do_mac=valid_in && !do_skip;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        acc_out<=0;
        skipped   <= 0;
        mac_valid <= 0;
    end
    else begin
        if (acc_clear) begin
            acc_out<=0;
        end
         else if (do_mac) begin
            acc_out<=acc_out + (weight_in * act_in);
        end
        skipped   <= do_skip;
        mac_valid <= do_mac;
    end
end


endmodule