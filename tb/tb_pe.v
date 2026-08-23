`timescale 1ns/1ps

module tb_pe;

    reg rst_n;
    reg valid_in;
    reg signed [7:0] weight_in;
    reg signed [7:0] act_in;
    reg acc_clear;

    wire signed [31:0] acc_out;
    wire skipped;
    wire mac_valid;

    reg clk;
    integer errors;

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        // Waveform generation
        $dumpfile("tb_pe.vcd");
        $dumpvars(0, tb_pe);

        // Initial values
        clk       = 0;
        rst_n     = 0;
        valid_in  = 0;
        weight_in = 0;
        act_in    = 0;
        acc_clear = 0;
        errors    = 0;

        // ------------------------------------------------
        // Reset sequence
        // ------------------------------------------------
        repeat (2) @(negedge clk);
        rst_n = 1;

        // ------------------------------------------------
        // Test 1: Normal MAC - 3 × 4
        // Expected ACC = 12
        // ------------------------------------------------
        @(negedge clk);
        weight_in = 3;
        act_in    = 4;
        valid_in  = 1;

        @(posedge clk);
        #1;

        if (acc_out == 12)
            $display("PASS: 3 x 4 MAC produced ACC = 12");
        else begin
            $display("FAIL: expected ACC = 12, got %0d", acc_out);
            errors = errors + 1;
        end

        // ------------------------------------------------
        // Test 2: Zero weight - 0 × 7
        // Expected: SKIP, ACC remains 12
        // ------------------------------------------------
        @(negedge clk);
        weight_in = 0;
        act_in    = 7;
        valid_in  = 1;

        @(posedge clk);
        #1;

        if (skipped && !mac_valid && acc_out == 12)
            $display("PASS: zero-weight MAC correctly skipped, ACC remains 12");
        else begin
            $display("FAIL: zero-weight skip did not behave correctly");
            errors = errors + 1;
        end

        // ------------------------------------------------
        // Test 3: Zero activation - 9 × 0
        // Expected: SKIP, ACC remains 12
        // ------------------------------------------------
        @(negedge clk);
        weight_in = 9;
        act_in    = 0;
        valid_in  = 1;

        @(posedge clk);
        #1;

        if (skipped && !mac_valid && acc_out == 12)
            $display("PASS: zero-activation MAC correctly skipped, ACC remains 12");
        else begin
            $display("FAIL: zero-activation skip did not behave correctly");
            errors = errors + 1;
        end

        // ------------------------------------------------
        // Test 4: Normal MAC after skips - 10 × 10
        // Expected: 12 + 100 = 112
        // ------------------------------------------------
        @(negedge clk);
        weight_in = 10;
        act_in    = 10;
        valid_in  = 1;

        @(posedge clk);
        #1;

        if (mac_valid && !skipped && acc_out == 112)
            $display("PASS: MAC resumed correctly after skips, ACC = 112");
        else begin
            $display("FAIL: MAC after skips incorrect, ACC = %0d", acc_out);
            errors = errors + 1;
        end

        // ------------------------------------------------
        // Test 5: Accumulator clear
        // Expected ACC = 0
        // ------------------------------------------------
        @(negedge clk);
        acc_clear = 1;
        valid_in  = 0;

        @(posedge clk);
        #1;

        if (acc_out == 0)
            $display("PASS: accumulator clear reset ACC to 0");
        else begin
            $display("FAIL: accumulator clear failed, ACC = %0d", acc_out);
            errors = errors + 1;
        end

        acc_clear = 0;

        // ------------------------------------------------
        // Test 6: MAC after accumulator clear - 6 × 6
        // Expected ACC = 36
        // ------------------------------------------------
        @(negedge clk);
        weight_in = 6;
        act_in    = 6;
        valid_in  = 1;

        @(posedge clk);
        #1;

        if (mac_valid && !skipped && acc_out == 36)
            $display("PASS: MAC worked correctly after clear, ACC = 36");
        else begin
            $display("FAIL: MAC after clear incorrect, ACC = %0d", acc_out);
            errors = errors + 1;
        end

        // ------------------------------------------------
        // Final test summary
        // ------------------------------------------------
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);

        // End simulation
        $finish;
    end

    // Device Under Test
    pe dut (
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

endmodule