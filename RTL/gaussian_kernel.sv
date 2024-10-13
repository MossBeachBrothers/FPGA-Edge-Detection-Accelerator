// Calculates Gaussian function. The Gaussian at point X,Y is represented as  G(x, y) = (1 / (2πσ²)) * e^(-(x² + y²) / (2σ²))
//Akhil Nair 
`timescale 1ns/1ps

module gaussian_kernel #(
    parameter int SIZE = 5,         //Kernel Size 
    parameter real SIGMA = 1.0
)(
    input  logic clk,
    input  logic reset,
    input  logic enable,
    output logic done,
    output real  kernel_matrix [SIZE-1:0][SIZE-1:0]
);



    int i;
    int j;
    int half_size;

    function real calc_gaussian_element(int x, int y, real sigma);
        real normal;
        real exponent;
        normal = 1.0 / (2.0 * 3.14159265359 * sigma**2);
        exponent = -((x**2 + y**2) / (2.0 * sigma**2));
        calc_gaussian_element = normal * $exp(exponent);  
    endfunction

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            i         <= 0;
            j         <= 0;
            done      <= 0;
            half_size <= (SIZE - 1) / 2;
        end else if (enable && !done) begin
            kernel_matrix[i][j] <= calc_gaussian_element(i - half_size, j - half_size, SIGMA);
            if (j == SIZE - 1) begin
                j <= 0;
                if (i == SIZE - 1) begin
                    i    <= 0;
                    done <= 1;
                end else begin
                    i <= i + 1;
                end
            end else begin
                j <= j + 1;
            end
        end
    end

endmodule
