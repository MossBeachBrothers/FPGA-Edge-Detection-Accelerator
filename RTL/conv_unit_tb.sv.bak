// Testbench for Convolution Unit

module conv_unit_tb;

    // Parameters
    parameter int IMAGE_HEIGHT = 5;
    parameter int IMAGE_WIDTH  = 5;
    parameter int KERNEL_SIZE  = 3;
    parameter int DATA_WIDTH   = 16; // Total bits for fixed-point representation
    parameter int FRAC_BITS    = 8;  // Number of fractional bits

    // Clock and control signals
    logic clk;
    logic resetn;
    logic enable;
    logic done;

    // Input and output images
    logic [DATA_WIDTH-1:0] input_image [IMAGE_HEIGHT-1:0][IMAGE_WIDTH-1:0];
    logic signed [DATA_WIDTH-1:0] kernel_matrix [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
    logic signed [DATA_WIDTH-1:0] output_image [IMAGE_HEIGHT-1:0][IMAGE_WIDTH-1:0];

    // Expected output image
    real expected_output [IMAGE_HEIGHT-1:0][IMAGE_WIDTH-1:0];

    // Instantiate the convolution unit
    conv_unit #(
        .IMAGE_HEIGHT(IMAGE_HEIGHT),
        .IMAGE_WIDTH(IMAGE_WIDTH),
        .KERNEL_SIZE(KERNEL_SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .FRAC_BITS(FRAC_BITS)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .done(done),
        .input_image(input_image),
        .kernel(kernel_matrix),
        .output_image(output_image)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Function to convert real to fixed-point
    function logic signed [DATA_WIDTH-1:0] real_to_fixed(real value);
        begin
            real scaled_value;
            scaled_value = value * (1 << FRAC_BITS);
            real_to_fixed = $rtoi(scaled_value);
        end
    endfunction

    // Function to convert fixed-point to real
    function real fixed_to_real(logic signed [DATA_WIDTH-1:0] value);
        begin
            fixed_to_real = value / real'(1 << FRAC_BITS);
        end
    endfunction

    // Initialize inputs
    initial begin
        // Reset the system
        resetn = 0;
        enable = 0;
        #20;
        resetn = 1;
        #10;

        // Load test image (scaled to fixed-point)
        input_image[0] = '{ real_to_fixed(10.0), real_to_fixed(10.0), real_to_fixed(10.0), real_to_fixed(10.0), real_to_fixed(10.0) };
        input_image[1] = '{ real_to_fixed(10.0), real_to_fixed(50.0), real_to_fixed(50.0), real_to_fixed(50.0), real_to_fixed(10.0) };
        input_image[2] = '{ real_to_fixed(10.0), real_to_fixed(50.0), real_to_fixed(100.0), real_to_fixed(50.0), real_to_fixed(10.0) };
        input_image[3] = '{ real_to_fixed(10.0), real_to_fixed(50.0), real_to_fixed(50.0), real_to_fixed(50.0), real_to_fixed(10.0) };
        input_image[4] = '{ real_to_fixed(10.0), real_to_fixed(10.0), real_to_fixed(10.0), real_to_fixed(10.0), real_to_fixed(10.0) };

        // Load Gaussian kernel (scaled to fixed-point)
        kernel_matrix[0] = '{ real_to_fixed(0.07511361), real_to_fixed(0.1238414),  real_to_fixed(0.07511361) };
        kernel_matrix[1] = '{ real_to_fixed(0.1238414),  real_to_fixed(0.20417996), real_to_fixed(0.1238414) };
        kernel_matrix[2] = '{ real_to_fixed(0.07511361), real_to_fixed(0.1238414),  real_to_fixed(0.07511361) };

        // Expected convolved image (unchanged)
        expected_output[0] = '{22.01817727, 25.91640089, 31.92548952, 25.91640089, 22.01817727};
        expected_output[1] = '{25.91640089, 34.83473519, 45.2293254,  34.83473519, 25.91640089};
        expected_output[2] = '{31.92548952, 45.2293254,  60.20899778, 45.2293254,  31.92548952};
        expected_output[3] = '{25.91640089, 34.83473519, 45.2293254,  34.83473519, 25.91640089};
        expected_output[4] = '{22.01817727, 25.91640089, 31.92548952, 25.91640089, 22.01817727};

        // Wait for a few clock cycles
        #20;

        // Start the convolution
        enable = 1;

        // Wait until done
        wait(done);
        enable = 0;

        // Compare the output with expected values
        check_results();

        // Finish simulation
        $finish;
    end

    // Task to check results
    task automatic check_results;
        real tolerance = 0.1; // Adjusted tolerance for fixed-point precision
        int errors = 0;
        real output_value;
        real expected_value;
        real diff;

        begin
            for (int i = 0; i < IMAGE_HEIGHT; i++) begin
                for (int j = 0; j < IMAGE_WIDTH; j++) begin
                    output_value   = fixed_to_real(output_image[i][j]);
                    expected_value = expected_output[i][j];
                    diff = output_value - expected_value;
                    if (diff < 0) diff = -diff;
                    if (diff > tolerance) begin
                        $display("Mismatch at pixel (%0d, %0d): Expected = %f, Got = %f", i, j, expected_value, output_value);
                        errors = errors + 1;
                    end else begin
                        $display("Match at pixel (%0d, %0d): Expected = %f, Got = %f", i, j, expected_value, output_value);
                    end
                end
            end
            if (errors == 0) begin
                $display("Test PASSED: All output values match expected results within tolerance.");
            end else begin
                $display("Test FAILED: %0d mismatches found.", errors);
            end
        end
    endtask

endmodule
