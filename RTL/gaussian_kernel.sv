`timescale 1ns/1ps

module gaussian_kernel #(
    parameter SIZE = 5,                 // Kernel Size (must be odd)
    parameter SIGMA = 1.0,             // Standard deviation
    parameter INTEGER_BITS = 2,        // Number of integer bits in fixed-point
    parameter FRACTIONAL_BITS = 14      // Number of fractional bits in fixed-point
)(
    input clk,
    input reset,
    input enable,
    output reg done,
    output reg signed [15:0] kernel_matrix [SIZE-1:0][SIZE-1:0]  // Fixed-point kernel matrix
);

// Fixed-point scaling factor
localparam SCALE = (1 << FRACTIONAL_BITS); // e.g., 2^14 = 16384

// State machine states
parameter IDLE = 2'b00;
parameter COMPUTE_RAW = 2'b01;
parameter COMPUTE_NORM = 2'b10;
parameter DONE_STATE = 2'b11;

reg [1:0] state;

// Iteration counters
integer current_i, current_j;

// Raw kernel storage (temporary)
reg signed [31:0] raw_kernel [SIZE-1:0][SIZE-1:0];

// Sum of raw kernel elements
reg signed [63:0] sum;

// Temporary variables for computation
integer x, y;
real exponent;
real gaussian;
reg signed [63:0] temp;

// State machine for kernel computation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset all variables and states
        state = IDLE;
        done = 0;
        current_i = 0;
        current_j = 0;
        sum = 0;
        for (integer m = 0; m < SIZE; m = m +1) begin
            for (integer n = 0; n < SIZE; n = n +1) begin
                raw_kernel[m][n] = 0;
                kernel_matrix[m][n] = 0;
            end
        end
    end else begin
        case (state)
            IDLE: begin
                if (enable) begin
                    state = COMPUTE_RAW;
                    current_i = 0;
                    current_j = 0;
                    sum = 0;
                    // Initialize raw_kernel and kernel_matrix
                    for (integer m = 0; m < SIZE; m = m +1) begin
                        for (integer n = 0; n < SIZE; n = n +1) begin
                            raw_kernel[m][n] = 0;
                            kernel_matrix[m][n] = 0;
                        end
                    end
                end
            end

            COMPUTE_RAW: begin
                if (current_i < SIZE && current_j < SIZE) begin
                    // Compute coordinates relative to kernel center
                    x = current_i - (SIZE-1)/2;
                    y = current_j - (SIZE-1)/2;

                    // Calculate the exponent part of the Gaussian function
                    exponent = -((x*x + y*y) / (2.0 * SIGMA * SIGMA));

                    // Compute Gaussian value
                    gaussian = (1.0 / (2.0 * 3.14159265359 * SIGMA * SIGMA)) * $exp(exponent);

                    // Scale to fixed-point and store in raw_kernel with rounding
                    raw_kernel[current_i][current_j] = $rtoi(gaussian * SCALE + 0.5);

                    // Accumulate the sum for normalization
                    sum = sum + raw_kernel[current_i][current_j];

                    // Update indices for next element
                    if (current_j == SIZE-1) begin
                        current_j = 0;
                        current_i = current_i + 1;
                    end else begin
                        current_j = current_j + 1;
                    end
                end else begin
                    // Transition to normalization phase after raw computation
                    state = COMPUTE_NORM;
                    current_i = 0;
                    current_j = 0;
                end
            end

            COMPUTE_NORM: begin
                if (current_i < SIZE && current_j < SIZE) begin
                    // Normalize each kernel element
                    // Formula: kernel_matrix[i][j] = (raw_kernel[i][j] * SCALE + (sum/2)) / sum
                    // Adding (sum/2) for rounding
                    temp = (raw_kernel[current_i][current_j] * SCALE) + (sum >> 1);
                    kernel_matrix[current_i][current_j] = temp / sum;

                    // Update indices for next normalization
                    if (current_j == SIZE-1) begin
                        current_j = 0;
                        current_i = current_i + 1;
                    end else begin
                        current_j = current_j + 1;
                    end
                end else begin
                    // Normalization complete
                    state = DONE_STATE;
                    done = 1;
                end
            end

            DONE_STATE: begin
                // Remain in DONE_STATE until reset
            end

            default: state = IDLE;
        endcase
    end
end

endmodule
