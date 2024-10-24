`timescale 1ns/1ps

module gaussian_kernel_tb;
    parameter SIZE = 5;
    parameter SIGMA = 1.0;
    parameter INTEGER_BITS = 2;
    parameter FRACTIONAL_BITS = 14;

    // Fixed-point scaling factor
    localparam SCALE = (1 << FRACTIONAL_BITS); // e.g., 2^14 = 16384

    // Signals
    reg clk;
    reg reset;
    reg enable;
    wire done;
    wire signed [15:0] kernel_matrix [SIZE-1:0][SIZE-1:0];  // Output kernel matrix

    // Instantiate the Gaussian Kernel Module
    gaussian_kernel #(
        .SIZE(SIZE),
        .SIGMA(SIGMA),
        .INTEGER_BITS(INTEGER_BITS),
        .FRACTIONAL_BITS(FRACTIONAL_BITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .done(done),
        .kernel_matrix(kernel_matrix)
    );

    // Clock generation
    initial begin
        clk = 0;
    end
    always #5 clk = ~clk;  // 100MHz clock

    // Expected kernel values (precomputed)
    integer expected_kernel_int [SIZE-1:0][SIZE-1:0];

    // Compute expected_kernel_int before enabling the module
    initial begin
        // Variable declarations must come before any statements
        integer m;
        integer n;
        integer x;
        integer y;
        real gaussian_real [SIZE-1:0][SIZE-1:0];
        real sum_real;
        real normalization_factor;
        real normalized;

        // Wait for a short time to ensure no race conditions
        #1;

        // Compute raw Gaussian values
        sum_real = 0.0;
        for (m = 0; m < SIZE; m = m +1) begin
            for (n = 0; n < SIZE; n = n +1) begin
                x = m - (SIZE-1)/2;
                y = n - (SIZE-1)/2;
                gaussian_real[m][n] = (1.0 / (2.0 * 3.14159265359 * SIGMA * SIGMA)) * $exp(-(x*x + y*y)/(2.0 * SIGMA * SIGMA));
                sum_real = sum_real + gaussian_real[m][n];
            end
        end

        // Normalize and scale
        normalization_factor = SCALE / sum_real;

        for (m = 0; m < SIZE; m = m +1) begin
            for (n = 0; n < SIZE; n = n +1) begin
                normalized = gaussian_real[m][n] * normalization_factor;
                expected_kernel_int[m][n] = $rtoi(normalized + 0.5); // Round to nearest integer
            end
        end

        // Display Expected Kernel for Reference
        $display("Expected Kernel Matrix (Fixed-Point):");
        for (m = 0; m < SIZE; m = m +1) begin
            for (n = 0; n < SIZE; n = n +1) begin
                $write("%d\t", expected_kernel_int[m][n]);
            end
            $write("\n");
        end
    end

    // Test procedure
    initial begin
        // Variable declarations must come before any statements
        integer errors;
        integer m;
        integer n;

        // Initialize signals
        reset = 1;
        enable = 0;
        #10;
        reset = 0;
        enable = 1;
        #10; // Ensure enable is high

        // Wait for computation to complete
        wait (done == 1);

        // Allow one more clock cycle for normalization
        @(posedge clk);

        // Compare kernel_matrix with expected_kernel_int
        errors = 0;
        for (m = 0; m < SIZE; m = m +1) begin
            for (n = 0; n < SIZE; n = n +1) begin
                if (kernel_matrix[m][n] !== expected_kernel_int[m][n]) begin
                    $display("Mismatch at [%0d][%0d]: Expected=%0d, Got=%0d", 
                             m, n, expected_kernel_int[m][n], kernel_matrix[m][n]);
                    errors = errors + 1;
                end
            end
        end

        // Display test result
        if (errors == 0) begin
            $display("Test PASSED!");
        end else begin
            $display("Test FAILED with %0d errors!", errors);
        end

        $stop;
    end

endmodule
