`timescale 1ns/1ps

module control_unit_tb;

    reg clk;
    reg reset_n;
    reg enable;

    reg gaussian_done;
    reg conv_done;
    reg filter_done;
    reg suppress_done;
    reg threshold_done;
    reg hysterisis_done;

    wire gaussian_enable;
    wire conv_enable;
    wire filter_enable;
    wire suppress_enable;
    wire threshold_enable;
    wire hysterisis_enable;

    control_unit uut (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .gaussian_enable(gaussian_enable),
        .gaussian_done(gaussian_done),
        .conv_enable(conv_enable),
        .conv_done(conv_done),
        .filter_enable(filter_enable),
        .filter_done(filter_done),
        .suppress_enable(suppress_enable),
        .suppress_done(suppress_done),
        .threshold_enable(threshold_enable),
        .threshold_done(threshold_done),
        .hysterisis_enable(hysterisis_enable),
        .hysterisis_done(hysterisis_done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        enable = 0;
        gaussian_done = 0;
        conv_done = 0;
        filter_done = 0;
        suppress_done = 0;
        threshold_done = 0;
        hysterisis_done = 0;

        #10;
        reset_n = 1;
        #10;

        enable = 1;

        wait (gaussian_enable);
        #15;
        gaussian_done = 1;
        #10;
        gaussian_done = 0;

        wait (conv_enable);
        #15;
        conv_done = 1;
        #10;
        conv_done = 0;

        wait (filter_enable);
        #15;
        filter_done = 1;
        #10;
        filter_done = 0;

        wait (suppress_enable);
        #15;
        suppress_done = 1;
        #10;
        suppress_done = 0;

        wait (threshold_enable);
        #15;
        threshold_done = 1;
        #10;
        threshold_done = 0;

        wait (hysterisis_enable);
        #15;
        hysterisis_done = 1;
        #10;
        hysterisis_done = 0;

        #10;
        enable = 0;
        #20;
        $finish;
    end

    initial begin
        $monitor("Time: %0t | GAUSSIAN: %b | CONVOLUTION: %b | FILTER: %b | SUPPRESS: %b | THRESHOLD: %b | HYSTERISIS: %b",
                 $time, gaussian_enable, conv_enable, filter_enable, suppress_enable, threshold_enable, hysterisis_enable);
    end

endmodule
