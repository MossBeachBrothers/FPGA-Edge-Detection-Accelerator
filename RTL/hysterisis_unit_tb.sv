// hysteresis_unit_tb.sv
//Testbench for Hysteris Unit 
//Written By: Akhil Nair 
`timescale 1ns/1ps

module hysteresis_unit_tb;

    // Parameters
    localparam integer HEIGHT = 5;
    localparam integer WIDTH  = 5;
    localparam integer IMG_SIZE = HEIGHT * WIDTH;
    localparam [7:0] WEAK_PIXEL   = 8'd75;
    localparam [7:0] STRONG_PIXEL = 8'd255;

    // Inputs
    logic clk;
    logic reset;
    logic enable;
    logic [7:0] img [0:IMG_SIZE-1];

    // Outputs
    logic [7:0] res [0:IMG_SIZE-1];
    logic done;

    // Instantiate the Unit Under Test (UUT)
    hysteresis_unit #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .WEAK_PIXEL(WEAK_PIXEL),
        .STRONG_PIXEL(STRONG_PIXEL)
    ) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .img(img),
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
            img[i] = 8'd0;
            res[i] = 8'd0;
            expected_res[i] = 8'd0;
        end

        // Apply Reset
        #12; // Ensure reset is asserted during a clock edge
        reset = 0;

        // Apply Enable and Input Image
        #8; // Wait for a stable period before enabling
        enable = 1;

        // Define the input image as per the sample
        // Original Image:
        // [[  0   0   0   0   0],
        //  [  0 255   0   0   0],
        //  [  0  75   0   0   0],
        //  [  0   0   0   0   0],
        //  [  0   0   0   0   0]]
        img[0]  = 8'd0;    img[1]  = 8'd0;    img[2]  = 8'd0;    img[3]  = 8'd0;    img[4]  = 8'd0;
        img[5]  = 8'd0;    img[6]  = 8'd255;  img[7]  = 8'd0;    img[8]  = 8'd0;    img[9]  = 8'd0;
        img[10] = 8'd0;    img[11] = 8'd75;   img[12] = 8'd0;    img[13] = 8'd0;    img[14] = 8'd0;
        img[15] = 8'd0;    img[16] = 8'd0;    img[17] = 8'd0;    img[18] = 8'd0;    img[19] = 8'd0;
        img[20] = 8'd0;    img[21] = 8'd0;    img[22] = 8'd0;    img[23] = 8'd0;    img[24] = 8'd0;

        // De-assert Enable after loading
        #10;
        enable = 0;

        // Define expected output based on Hysteresis function
        // Original Image:
        // [[  0   0   0   0   0],
        //  [  0 255   0   0   0],
        //  [  0  75   0   0   0],
        //  [  0   0   0   0   0],
        //  [  0   0   0   0   0]]
        //
        // Resulting Image after Hysteresis:
        // [[  0   0   0   0   0],
        //  [  0 255   0   0   0],
        //  [  0 255   0   0   0],
        //  [  0   0   0   0   0],
        //  [  0   0   0   0   0]]
        expected_res[0]  = 8'd0;    expected_res[1]  = 8'd0;    expected_res[2]  = 8'd0;    expected_res[3]  = 8'd0;    expected_res[4]  = 8'd0;
        expected_res[5]  = 8'd0;    expected_res[6]  = 8'd255;  expected_res[7]  = 8'd0;    expected_res[8]  = 8'd0;    expected_res[9]  = 8'd0;
        expected_res[10] = 8'd0;    expected_res[11] = 8'd255;  expected_res[12] = 8'd0;    expected_res[13] = 8'd0;    expected_res[14] = 8'd0;
        expected_res[15] = 8'd0;    expected_res[16] = 8'd0;    expected_res[17] = 8'd0;    expected_res[18] = 8'd0;    expected_res[19] = 8'd0;
        expected_res[20] = 8'd0;    expected_res[21] = 8'd0;    expected_res[22] = 8'd0;    expected_res[23] = 8'd0;    expected_res[24] = 8'd0;

        // Wait for processing to complete
        wait (done);

        // Display the results
        $display("Hysteresis Output:");
        for (integer row_i = 0; row_i < HEIGHT; row_i++) begin
            for (integer col_i = 0; col_i < WIDTH; col_i++) begin
                $write("%3d ", res[row_i*WIDTH + col_i]);
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
