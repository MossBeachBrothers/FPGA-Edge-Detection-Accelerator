// non_max_suppression_tb.sv
// Testbench for Non-Maximum Suppression with fixed-point arithmetic
`timescale 1ns/1ps

module non_max_suppression_tb;

    parameter WIDTH = 5;
    parameter HEIGHT = 5;

    reg clk;
    reg enable;
    reg signed [15:0] G [0:HEIGHT-1][0:WIDTH-1];
    reg signed [15:0] theta [0:HEIGHT-1][0:WIDTH-1];
    wire done;
    wire signed [15:0] non_max_pixel [0:HEIGHT-1][0:WIDTH-1];

    // Instantiate the module
    non_max_suppression #(WIDTH, HEIGHT) uut (
        .clk(clk),
        .enable(enable),
        .gradient(G),
        .theta(theta),
        .done(done),
        .non_max_pixel(non_max_pixel)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10 time units
    end

    // Test procedure
    initial begin
        integer i, j;
        integer error_flag = 0;
        reg signed [15:0] expected_Z [0:HEIGHT-1][0:WIDTH-1];

        // Initialize G and theta with test values (in Q8.8 fixed-point format)
        G = '{
            '{ 16'd0,   16'd0,   16'd0,   16'd0,   16'd0 },
            '{ 16'd0, 16'd25600, 16'd25600, 16'd25600, 16'd0 },
            '{ 16'd0, 16'd25600, 16'd65536, 16'd25600, 16'd0 },
            '{ 16'd0, 16'd25600, 16'd25600, 16'd25600, 16'd0 },
            '{ 16'd0,   16'd0,   16'd0,   16'd0,   16'd0 }
        };

        theta = '{
            '{ 16'd0,       16'd0,       16'd0,       16'd0,       16'd0 },
            '{ 16'd0, 16'd201, 16'd201, 16'd0,       16'd0 },
            '{ 16'd0, 16'd201, 16'd0, 16'd201, 16'd0 },
            '{ 16'd0, 16'd201, 16'd201, 16'd0,       16'd0 },
            '{ 16'd0,       16'd0,       16'd0,       16'd0,       16'd0 }
        };

        // Expected Output
        expected_Z = '{
            '{ 16'd0, 16'd0, 16'd0, 16'd0, 16'd0 },
            '{ 16'd0, 16'd25600, 16'd25600, 16'd25600, 16'd0 },
            '{ 16'd0, 16'd25600, 16'd65536, 16'd25600, 16'd0 },
            '{ 16'd0, 16'd0, 16'd25600, 16'd25600, 16'd0 },
            '{ 16'd0, 16'd0, 16'd0, 16'd0, 16'd0 }
        };

        // Start the test by enabling the module
        enable = 1;

        // Wait for done signal
        wait (done == 1);

        // Verify output against expected values
        error_flag = 0; // Reset error flag
        for (i = 0; i < HEIGHT; i = i + 1) begin
            for (j = 0; j < WIDTH; j = j + 1) begin
                if (non_max_pixel[i][j] !== expected_Z[i][j]) begin
                    $display("Mismatch at pixel (%0d,%0d): non_max_pixel=%0d (expected %0d)", i, j, non_max_pixel[i][j], expected_Z[i][j]);
                    error_flag = 1;
                end else begin
                    $display("Pixel (%0d,%0d) matches: non_max_pixel=%0d", i, j, non_max_pixel[i][j]);
                end
            end
        end

        // Final test result
        if (error_flag == 0) begin
            $display("Test passed: All pixels match expected outputs.");
        end else begin
            $display("Test failed: There were mismatches in the outputs.");
        end

        $stop;
    end

endmodule
