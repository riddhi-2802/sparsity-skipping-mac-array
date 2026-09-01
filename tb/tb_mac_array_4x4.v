`timescale 1ns/1ps

module tb_mac_array_4x4;

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
    integer errors;

    always #5 clk = ~clk;

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

    initial begin
        $dumpfile("tb_mac_array_4x4.vcd");
        $dumpvars(0, tb_mac_array_4x4);

        clk       = 0;
        rst_n     = 0;
        valid_in  = 0;
        acc_clear = 0;
        weight_in = 0;
        act_in    = 0;
        errors    = 0;

        // Reset
        repeat (2) @(negedge clk);
        rst_n = 1;

        // ================================================
        // DENSE INPUT TEST
        // ================================================

        @(negedge clk);

        for (i = 0; i < 16; i = i + 1) begin
            weight_in[i*8 +: 8] = i + 1;
            act_in[i*8 +: 8]    = 1;
        end

        valid_in = 1;

        @(posedge clk);
        #1;

        $display("=================================");
        $display("DENSE INPUT TEST");
        $display("=================================");

        mac_count  = 0;
        skip_count = 0;

        for (i = 0; i < 16; i = i + 1) begin
            if (mac_valid[i])
                mac_count = mac_count + 1;

            if (skipped[i])
                skip_count = skip_count + 1;

            $display("PE[%0d]: ACC=%0d MAC=%b SKIP=%b",
                     i,
                     acc_out[i*32 +: 32],
                     mac_valid[i],
                     skipped[i]);
        end

        $display("Dense MAC count  = %0d", mac_count);
        $display("Dense skip count = %0d", skip_count);

        if (mac_count != 16 || skip_count != 0) begin
            $display("FAIL: Dense test");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Dense test");
        end

        // ================================================
        // CLEAR ACCUMULATORS
        // ================================================

        valid_in  = 0;
        acc_clear = 1;

        @(posedge clk);
        #1;

        acc_clear = 0;

        // ================================================
        // SPARSE INPUT TEST
        // ================================================

        @(negedge clk);

        weight_in = 0;
        act_in    = 0;

        // Four non-zero weights
        weight_in[0*8 +: 8] = 2;
        weight_in[5*8 +: 8] = 3;
        weight_in[10*8 +: 8] = 4;
        weight_in[15*8 +: 8] = 5;

        // Activations = 1
        for (i = 0; i < 16; i = i + 1)
            act_in[i*8 +: 8] = 1;

        valid_in = 1;

        @(posedge clk);
        #1;

        $display("=================================");
        $display("SPARSE INPUT TEST");
        $display("=================================");

        mac_count  = 0;
        skip_count = 0;

        for (i = 0; i < 16; i = i + 1) begin
            if (mac_valid[i])
                mac_count = mac_count + 1;

            if (skipped[i])
                skip_count = skip_count + 1;

            $display("PE[%0d]: ACC=%0d MAC=%b SKIP=%b",
                     i,
                     acc_out[i*32 +: 32],
                     mac_valid[i],
                     skipped[i]);
        end

        $display("Sparse MAC count  = %0d", mac_count);
        $display("Sparse skip count = %0d", skip_count);

        if (mac_count != 4 || skip_count != 12) begin
            $display("FAIL: Sparse test");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Sparse test");
        end

        // ================================================
        // FINAL RESULT
        // ================================================

        $display("=================================");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);

        $display("=================================");

        $finish;
    end

endmodule
