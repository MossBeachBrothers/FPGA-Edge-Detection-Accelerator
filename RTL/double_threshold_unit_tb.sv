// double_threshold_unit_tb.sv
//Testbench
//Written By: Akhil Nair 


`timescale 1ns/1ps

module double_threshold_unit_tb;

    // Parameters
    localparam integer HEIGHT = 5;
    localparam integer WIDTH  = 5;
    localparam integer HIGH_THRESHOLD_NUM = 3; // Represents 0.15
    localparam integer HIGH_THRESHOLD_DEN = 20;
    localparam integer LOW_THRESHOLD_NUM  = 1; // Represents 0.05
    localparam integer LOW_THRESHOLD_DEN  = 20;
    localparam integer IMG_SIZE = HEIGHT * WIDTH;

    // Inputs
    logic clk;
    logic reset;
    logic enable;
    logic [7:0] Z [0:IMG_SIZE-1];

    // Outputs
    logic [7:0] res [0:IMG_SIZE-1];
    logic done;

    // Instantiate the Unit Under Test (UUT) with parameter overrides
    double_threshold_unit #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .HIGH_THRESHOLD_NUM(HIGH_THRESHOLD_NUM),
        .HIGH_THRESHOLD_DEN(HIGH_THRESHOLD_DEN),
        .LOW_THRESHOLD_NUM(LOW_THRESHOLD_NUM),
        .LOW_THRESHOLD_DEN(LOW_THRESHOLD_DEN),
        .WEAK_PIXEL(8'd75),
        .STRONG_PIXEL(8'd255)
    ) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .Z(Z),
        .res(res),
        .done(done)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test Vector
    initial begin
        // Declare variables at the beginning of the procedural block
        logic [7:0] expected_res [0:IMG_SIZE-1];
        integer i; // Loop variable

        // Initialize Inputs
        reset = 1;
        enable = 0;
        for (i = 0; i < IMG_SIZE; i++) begin
            Z[i] = 8'd0;
            res[i] = 8'd0;
        end

        // Apply Reset
        #12; // Ensure reset is asserted during a clock edge
        reset = 0;

        // Apply Enable and Input Image
        #8; // Wait for a stable period before enabling
        enable = 1;

        // Define the input image as per the sample
        // Image:
        // [[  0,   0,   0,   0,   0],
        //  [  0, 100, 100, 100,   0],
        //  [  0, 100, 255, 100,   0],
        //  [  0, 100, 100, 100,   0],
        //  [  0,   0,   0,   0,   0]]
        Z[0]  = 8'd0;   Z[1]  = 8'd0;   Z[2]  = 8'd0;   Z[3]  = 8'd0;   Z[4]  = 8'd0;
        Z[5]  = 8'd0;   Z[6]  = 8'd100; Z[7]  = 8'd100; Z[8]  = 8'd100; Z[9]  = 8'd0;
        Z[10] = 8'd0;   Z[11] = 8'd100; Z[12] = 8'd255; Z[13] = 8'd100; Z[14] = 8'd0;
        Z[15] = 8'd0;   Z[16] = 8'd100; Z[17] = 8'd100; Z[18] = 8'd100; Z[19] = 8'd0;
        Z[20] = 8'd0;   Z[21] = 8'd0;   Z[22] = 8'd0;   Z[23] = 8'd0;   Z[24] = 8'd0;

        // De-assert Enable after loading
        #10;
        enable = 0;

        // Define expected output based on Python function
        // Given highThreshold=0.15*255=38.25 (~38), lowThreshold=38*0.05=1.9 (~2)
        // Thus:
        // Pixels >=38:255
        // Pixels >=2 and <38:75
        // Pixels <2:0
        // For the sample input:
        // Pixels=0:0
        // Pixels=100:255
        // Pixels=255:255
        expected_res[0]  = 8'd0;   expected_res[1]  = 8'd0;   expected_res[2]  = 8'd0;   expected_res[3]  = 8'd0;   expected_res[4]  = 8'd0;
        expected_res[5]  = 8'd0;   expected_res[6]  = 8'd255; expected_res[7]  = 8'd255; expected_res[8]  = 8'd255; expected_res[9]  = 8'd0;
        expected_res[10] = 8'd0;   expected_res[11] = 8'd255; expected_res[12] = 8'd255; expected_res[13] = 8'd255; expected_res[14] = 8'd0;
        expected_res[15] = 8'd0;   expected_res[16] = 8'd255; expected_res[17] = 8'd255; expected_res[18] = 8'd255; expected_res[19] = 8'd0;
        expected_res[20] = 8'd0;   expected_res[21] = 8'd0;   expected_res[22] = 8'd0;   expected_res[23] = 8'd0;   expected_res[24] = 8'd0;

        // Wait for processing to complete
        wait (done);

        // Display the results
        $display("Thresholding Output:");
        for (integer row = 0; row < HEIGHT; row++) begin
            for (integer col = 0; col < WIDTH; col++) begin
                $write("%3d ", res[row*WIDTH + col]);
            end
            $write("\n");
        end

        // Verify the results
        for (i = 0; i < IMG_SIZE; i++) begin
            if (res[i] !== expected_res[i]) begin
                $display("Test Failed at index %0d: Expected %0d, Got %0d", i, expected_res[i], res[i]);
                $stop;
            end
        end

        $display("Test Passed Successfully!");
        $finish;
    end

endmodule
