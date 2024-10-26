// non_max_suppression_corrected_final.sv
// Non-Maximum Suppression with boundary handling and accurate neighbor selection
`timescale 1ns/1ps

module non_max_suppression #(
    parameter WIDTH = 5,
    parameter HEIGHT = 5,
    parameter INTEGER_BITS = 8,
    parameter FRACTION_BITS = 8
)(
    input wire clk,
    input wire enable,
    input wire signed [15:0] gradient [HEIGHT-1:0][WIDTH-1:0],
    input wire signed [15:0] theta [HEIGHT-1:0][WIDTH-1:0],
    output reg done,
    output reg signed [15:0] non_max_pixel [HEIGHT-1:0][WIDTH-1:0]
);

    // Constants for angle conversion
    localparam signed [15:0] PI = 16'd804; // PI in Q8.8 format
    localparam signed [15:0] ANGLE_SCALE = (16'd180 << FRACTION_BITS);

    // State machine definitions
    typedef enum logic [2:0] {
        IDLE,
        INIT_PIXEL,
        CONVERT_ANGLE,
        CALCULATE_NEIGHBORS,
        APPLY_SUPPRESSION,
        COMPLETE
    } state_t;

    state_t state;

    // Registers for tracking pixel coordinates and intermediate values
    reg [9:0] row, col;
    reg signed [15:0] angle, q, r;

    // State machine with final adjustments to handle boundaries and neighbor selection
    always @(posedge clk) begin
        if (enable) begin
            case (state)
                IDLE: begin
                    done <= 0;
                    row <= 0;
                    col <= 0;
                    state <= INIT_PIXEL;
                end

                INIT_PIXEL: begin
                    // Set boundary pixels to 0 directly
                    if (row == 0 || row == HEIGHT - 1 || col == 0 || col == WIDTH - 1) begin
                        non_max_pixel[row][col] <= 16'd0;
                        state <= COMPLETE;
                    end else begin
                        non_max_pixel[row][col] <= 16'd0; // Initialize output pixel to zero
                        state <= CONVERT_ANGLE;
                    end
                end

                CONVERT_ANGLE: begin
                    // Convert theta to degrees and ensure non-negative
                    angle <= (theta[row][col] * ANGLE_SCALE) / PI;
                    if (angle < 0)
                        angle <= angle + (16'd180 << FRACTION_BITS);
                    state <= CALCULATE_NEIGHBORS;
                end

                CALCULATE_NEIGHBORS: begin
                    // Set default neighbors to 255 (maximum value)
                    q = 16'd255;
                    r = 16'd255;

                    // Select neighbors based on the calculated angle
                    if ((angle >= 0 && angle < (16'd22_5 << FRACTION_BITS)) || 
                        (angle >= (16'd157_5 << FRACTION_BITS) && angle <= (16'd180 << FRACTION_BITS))) begin
                        q <= gradient[row][col + 1];
                        r <= gradient[row][col - 1];
                    end
                    else if (angle >= (16'd22_5 << FRACTION_BITS) && angle < (16'd67_5 << FRACTION_BITS)) begin
                        q <= gradient[row + 1][col - 1];
                        r <= gradient[row - 1][col + 1];
                    end
                    else if (angle >= (16'd67_5 << FRACTION_BITS) && angle < (16'd112_5 << FRACTION_BITS)) begin
                        q <= gradient[row + 1][col];
                        r <= gradient[row - 1][col];
                    end
                    else if (angle >= (16'd112_5 << FRACTION_BITS) && angle < (16'd157_5 << FRACTION_BITS)) begin
                        q <= gradient[row - 1][col - 1];
                        r <= gradient[row + 1][col + 1];
                    end
                    state <= APPLY_SUPPRESSION;
                end

                APPLY_SUPPRESSION: begin
                    // Apply suppression logic to keep only local maxima
                    if ((gradient[row][col] >= q) && (gradient[row][col] >= r)) begin
                        non_max_pixel[row][col] <= gradient[row][col];
                    end else begin
                        non_max_pixel[row][col] <= 16'd0;
                    end
                    state <= COMPLETE;
                end

                COMPLETE: begin
                    // Move to the next pixel in a pipelined fashion
                    if (col < WIDTH - 1) begin
                        col <= col + 1;
                        state <= INIT_PIXEL;
                    end else if (row < HEIGHT - 1) begin
                        col <= 0;
                        row <= row + 1;
                        state <= INIT_PIXEL;
                    end else begin
                        done <= 1;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end else begin
            done <= 0;
            state <= IDLE;
        end
    end
endmodule
