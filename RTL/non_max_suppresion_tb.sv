// non_max_suppression_tb.sv
//Written By: Akhil Nair
module non_max_suppression_tb;

    parameter WIDTH = 5;
    parameter HEIGHT = 5;

    reg clk;
    reg enable;
    real G [0:HEIGHT-1][0:WIDTH-1];
    real theta [0:HEIGHT-1][0:WIDTH-1];
    wire done;
    int Z [0:HEIGHT-1][0:WIDTH-1];

    // Instantiate the module
    non_max_suppression #(WIDTH, HEIGHT) uut (
        .clk(clk),
        .enable(enable),
        .G(G),
        .theta(theta),
        .done(done),
        .Z(Z)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10 time units
    end

    // Test procedure
    initial begin
        integer i, j;
        integer error_flag;
        real epsilon;
        int expected_Z [0:HEIGHT-1][0:WIDTH-1];

        error_flag = 0;
        epsilon = 0.001;

        // Initialize G and theta with sample inputs
        // Input Image (Gradient Magnitude)
        G = '{
            '{ 0.0,   0.0,   0.0,   0.0,   0.0 },
            '{ 0.0, 100.0, 100.0, 100.0,   0.0 },
            '{ 0.0, 100.0, 255.0, 100.0,   0.0 },
            '{ 0.0, 100.0, 100.0, 100.0,   0.0 },
            '{ 0.0,   0.0,   0.0,   0.0,   0.0 }
        };

        // Input Angles (D)
        theta = '{
            '{ 0.0,       0.0,       0.0,       0.0,       0.0 },
            '{ 0.0, 0.7853982, 0.7853982, 0.0,       0.0 },
            '{ 0.0, 0.7853982, 0.0, 0.7853982, 0.0 },
            '{ 0.0, 0.7853982, 0.7853982, 0.0,       0.0 },
            '{ 0.0,       0.0,       0.0,       0.0,       0.0 }
        };

        // Expected Output
        expected_Z = '{
            '{   0,    0,    0,    0,    0 },
            '{   0,  100,  100,  100,    0 },
            '{   0,  100,  255,  100,    0 },
            '{   0,    0,  100,  100,    0 },
            '{   0,    0,    0,    0,    0 }
        };

        // Apply enable
        enable = 0;
        #10;
        enable = 1;
        #10;
        enable = 0;

        // Wait for done signal
        wait (done == 1);

        // Compare outputs
        for (i = 0; i < HEIGHT; i = i + 1) begin
            for (j = 0; j < WIDTH; j = j + 1) begin
                if (Z[i][j] !== expected_Z[i][j]) begin
                    $display("Mismatch at pixel (%0d,%0d): Z=%0d (expected %0d)", i, j, Z[i][j], expected_Z[i][j]);
                    error_flag = 1;
                end else begin
                    $display("Pixel (%0d,%0d) matches: Z=%0d", i, j, Z[i][j]);
                end
            end
        end

        if (error_flag == 0) begin
            $display("Test passed: All pixels match expected outputs.");
        end else begin
            $display("Test failed: There were mismatches in the outputs.");
        end

        $stop;
    end

endmodule
