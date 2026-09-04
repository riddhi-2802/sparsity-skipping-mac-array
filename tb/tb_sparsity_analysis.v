`timescale 1ns/1ps

module tb_sparsity_analysis;

    reg clk;
    reg rst_n;
    reg valid_in;
    reg acc_clear;

    reg signed [127:0] weight_in;
    reg signed [127:0] act_in;

    wire signed [511:0] acc_out;
    wire [15:0] skipped;
    wire [15:0] mac_valid;

    integer i;
    integer mac_count;
    integer skip_count;

    mac_array_4x4 dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .weight_in (weight_in),
        .act_in    (act_in),
        .acc_clear (acc_clear),
        .acc_out   (acc_out),
        .skipped   (skipped),
        .mac_valid (mac_valid)
    );

    always #5 clk = ~clk;

    task run_test;
        input integer nonzero_count;
        begin

            weight_in = 128'b0;
            act_in = 128'b0;

            // First 'nonzero_count' PEs receive non-zero operands
            for (i = 0; i < 16; i = i + 1) begin
                if (i < nonzero_count) begin
                    weight_in[i*8 +: 8] = 8'd2;
                    act_in[i*8 +: 8] = 8'd1;
                end
                else begin
                    weight_in[i*8 +: 8] = 8'd0;
                    act_in[i*8 +: 8] = 8'd1;
                end
            end

            @(posedge clk);
            #1;

            mac_count = 0;
            skip_count = 0;

            for (i = 0; i < 16; i = i + 1) begin
                if (mac_valid[i])
                    mac_count = mac_count + 1;

                if (skipped[i])
                    skip_count = skip_count + 1;
            end

            $display("Non-zero operands = %0d / 16", nonzero_count);
            $display("MACs              = %0d", mac_count);
            $display("Skips             = %0d", skip_count);
            $display("---------------------------------");

            acc_clear = 1'b1;
            @(posedge clk);
            #1;
            acc_clear = 1'b0;

        end
    endtask

    initial begin

        clk = 0;
        rst_n = 0;
        valid_in = 0;
        acc_clear = 0;
        weight_in = 0;
        act_in = 0;

        #20;
        rst_n = 1;
        valid_in = 1;

        $display("=================================");
        $display("  SPARSITY ANALYSIS");
        $display("=================================");

        // 0% sparsity
        run_test(16);

        // 25% sparsity
        run_test(12);

        // 50% sparsity
        run_test(8);

        // 75% sparsity
        run_test(4);

        // 100% sparsity
        run_test(0);

        $display("=================================");

        $finish;

    end

endmodule
