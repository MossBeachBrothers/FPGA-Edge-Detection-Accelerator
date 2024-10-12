//Test bench for Gaussian Kernel
//Akhil Nair 
module gaussian_kernel_tb;
    parameter int SIZE = 5;
    parameter real SIGMA = 1.0;

    logic clk;
    logic reset;
    logic enable;
    logic done;
    real kernel_matrix[SIZE-1:0][SIZE-1:0];

    // Instantiate the module
    gaussian_kernel #(.SIZE(SIZE), .SIGMA(SIGMA)) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .done(done),
        .kernel_matrix(kernel_matrix)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    // Expected values
    real expected_kernel[SIZE-1:0][SIZE-1:0];
    initial begin
        expected_kernel[0][0] = 0.002915;
        expected_kernel[0][1] = 0.013064;
        expected_kernel[0][2] = 0.021539;
        expected_kernel[0][3] = 0.013064;
        expected_kernel[0][4] = 0.002915;
        
        expected_kernel[1][0] = 0.013064;
        expected_kernel[1][1] = 0.058550;
        expected_kernel[1][2] = 0.096532;
        expected_kernel[1][3] = 0.058550;
        expected_kernel[1][4] = 0.013064;
        
        expected_kernel[2][0] = 0.021539;
        expected_kernel[2][1] = 0.096532;
        expected_kernel[2][2] = 0.159155;
        expected_kernel[2][3] = 0.096532;
        expected_kernel[2][4] = 0.021539;
        
        expected_kernel[3][0] = 0.013064;
        expected_kernel[3][1] = 0.058550;
        expected_kernel[3][2] = 0.096532;
        expected_kernel[3][3] = 0.058550;
        expected_kernel[3][4] = 0.013064;
        
        expected_kernel[4][0] = 0.002915;
        expected_kernel[4][1] = 0.013064;
        expected_kernel[4][2] = 0.021539;
        expected_kernel[4][3] = 0.013064;
        expected_kernel[4][4] = 0.002915;
    end

    // Test procedure
    initial begin
        // Declarations
        int errors;
        real tolerance;
        int i, j;
        real diff;

        // Initialize variables
        errors = 0;
        tolerance = 0.0001;  // Tolerance for comparison

        // Initialize signals
        reset = 1;
        enable = 0;
        #20;
        reset = 0;
        enable = 1;
        wait (done == 1);

        // Check results
        for (i = 0; i < SIZE; i++) begin
            for (j = 0; j < SIZE; j++) begin
                diff = expected_kernel[i][j] - kernel_matrix[i][j];
                if (diff < 0) diff = -diff;
                if (diff > tolerance) begin
                    $display("Mismatch at [%0d][%0d]: Expected=%f, Got=%f", i, j, expected_kernel[i][j], kernel_matrix[i][j]);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0) begin
            $display("Test PASSED!");
        end else begin
            $display("Test FAILED with %0d errors!", errors);
        end

        $stop;
    end

endmodule
