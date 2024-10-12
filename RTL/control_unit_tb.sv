`timescale 1ns/1ps

module control_unit_tb;

    // Clock and reset
    reg clk;
    reg reset_n;
    reg enable;

    // Module done signals
    reg gaussian_done;
    reg filter_done;
    reg suppress_done;
    reg threshold_done;
    reg hysterisis_done;

    // Control unit outputs
    wire gaussian_enable;
    wire filter_enable;
    wire suppress_enable;
    wire threshold_enable;
    wire hysterisis_enable;

    // Instantiate the DUT
    control_unit uut (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .gaussian_enable(gaussian_enable),
        .gaussian_done(gaussian_done),
        .filter_enable(filter_enable),
        .filter_done(filter_done),
        .suppress_enable(suppress_enable),
        .suppress_done(suppress_done),
        .threshold_enable(threshold_enable),
        .threshold_done(threshold_done),
        .hysterisis_enable(hysterisis_enable),
        .hysterisis_done(hysterisis_done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize signals
        reset_n = 0;
        enable = 0;
        gaussian_done = 0;
        filter_done = 0;
        suppress_done = 0;
        threshold_done = 0;
        hysterisis_done = 0;

        // Apply reset
        #10;
        reset_n = 1;
        #10;

        // Start pipeline
        enable = 1;

        // GAUSSIAN stage
        wait (gaussian_enable);
        #15;
        gaussian_done = 1;
        #10;
        gaussian_done = 0;

        // SOBEL_FILTERING stage
        wait (filter_enable);
        #15;
        filter_done = 1;
        #10;
        filter_done = 0;

        // SUPPRESSION stage
        wait (suppress_enable);
        #15;
        suppress_done = 1;
        #10;
        suppress_done = 0;

        // THRESHOLDING stage
        wait (threshold_enable);
        #15;
        threshold_done = 1;
        #10;
        threshold_done = 0;

        // HYSTERISIS stage
        wait (hysterisis_enable);
        #15;
        hysterisis_done = 1;
        #10;
        hysterisis_done = 0;

        // Complete pipeline
        #10;
        enable = 0;
        #20;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | GAUSSIAN: %b | FILTER: %b | SUPPRESS: %b | THRESHOLD: %b | HYSTERISIS: %b",
                 $time, gaussian_enable, filter_enable, suppress_enable, threshold_enable, hysterisis_enable);
    end

endmodule
