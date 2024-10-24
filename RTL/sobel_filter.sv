// sobel_filter_fixed.sv
// Sobel Filter Fixed-Point Implementation
// Author: Akhil Nair

`timescale 1ns/1ps

module sobel_filter_fixed #(
    parameter WIDTH = 5,
    parameter HEIGHT = 5,
    parameter FIXED_WIDTH = 16,
    parameter FIXED_FRAC = 8  // Using Q8.8 format for lower precision
)(
    input  wire                       clk,
    input  wire                       enable,
    input  wire [FIXED_WIDTH-1:0]     image [0:HEIGHT+1][0:WIDTH+1], // Padded image in Q8.8
    output reg                        done,
    output reg signed [FIXED_WIDTH-1:0] G [0:HEIGHT-1][0:WIDTH-1],
    output reg signed [FIXED_WIDTH-1:0] theta [0:HEIGHT-1][0:WIDTH-1]
);
    // Fixed-point representation of Kx and Ky kernels (Q8.8)
    reg signed [FIXED_WIDTH-1:0] Kx [0:2][0:2];
    reg signed [FIXED_WIDTH-1:0] Ky [0:2][0:2];

    // Constants in Q8.8 format
    localparam signed [FIXED_WIDTH-1:0] CONST_255 = 16'sd65280;     // 255.0 * 2^8
    localparam signed [FIXED_WIDTH-1:0] CONST_PI_OVER_2 = 16'sd402; // pi/2 * 2^8 ≈ 1.5708 * 256

    initial begin
        // Initialize Kx kernel
        Kx[0][0] = -16'sd256;  // -1.0 * 256
        Kx[0][1] =  16'sd0;    //  0.0
        Kx[0][2] =  16'sd256;  //  1.0
        Kx[1][0] = -16'sd512;  // -2.0 * 256
        Kx[1][1] =  16'sd0;    //  0.0
        Kx[1][2] =  16'sd512;  //  2.0 * 256
        Kx[2][0] = -16'sd256;  // -1.0 * 256
        Kx[2][1] =  16'sd0;    //  0.0
        Kx[2][2] =  16'sd256;  //  1.0 * 256

        // Initialize Ky kernel
        Ky[0][0] =  16'sd256;   //  1.0 * 256
        Ky[0][1] =  16'sd512;   //  2.0 * 256
        Ky[0][2] =  16'sd256;   //  1.0 * 256
        Ky[1][0] =  16'sd0;     //  0.0
        Ky[1][1] =  16'sd0;     //  0.0
        Ky[1][2] =  16'sd0;     //  0.0
        Ky[2][0] = -16'sd256;   // -1.0 * 256
        Ky[2][1] = -16'sd512;   // -2.0 * 256
        Ky[2][2] = -16'sd256;   // -1.0 * 256
    end

    integer i, j, m, n;
    reg signed [47:0] Ix [0:HEIGHT-1][0:WIDTH-1]; // Increased bit-width for higher precision
    reg signed [47:0] Iy [0:HEIGHT-1][0:WIDTH-1];
    reg signed [63:0] G_temp [0:HEIGHT-1][0:WIDTH-1]; // Sum of squares
    reg signed [63:0] G_max_temp; // Max of G_temp

    reg signed [31:0] G_max_sqrt;
    reg signed [31:0] G_sqrt;
    reg signed [47:0] G_scaled;
    reg signed [31:0] G_normalized;

    // Fixed-point square root function
    function [31:0] fixed_sqrt;
        input [63:0] x; // x in Q16.16 format squared
        reg [31:0] y;    // Result in Q16.16 format
        reg [63:0] y_squared;
        integer k;
        begin
            y = x[63:32]; // Initial guess
            if (y == 0) y = 32'd1;
            for (k = 0; k < 16; k = k + 1) begin
                y_squared = y * y;
                y = (y + (x / y)) >> 1;
            end
            fixed_sqrt = y;
        end
    endfunction

    always @(posedge clk) begin
        if (enable) begin
            done <= 0;
            G_max_temp <= 0;

            // Compute Ix and Iy
            for (i = 1; i <= HEIGHT; i = i + 1) begin
                for (j = 1; j <= WIDTH; j = j + 1) begin
                    Ix[i-1][j-1] = 48'sd0;
                    Iy[i-1][j-1] = 48'sd0;

                    for (m = 0; m < 3; m = m + 1) begin
                        for (n = 0; n < 3; n = n + 1) begin
                            // Multiply and accumulate without shifting
                            Ix[i-1][j-1] = Ix[i-1][j-1] + (Kx[m][n] * image[i + m - 1][j + n - 1]);
                            Iy[i-1][j-1] = Iy[i-1][j-1] + (Ky[m][n] * image[i + m - 1][j + n - 1]);
                        end
                    end

                    // Right-shift after accumulation to bring back to Q16.16 format
                    Ix[i-1][j-1] = Ix[i-1][j-1] >>> FIXED_FRAC;
                    Iy[i-1][j-1] = Iy[i-1][j-1] >>> FIXED_FRAC;

                    // Compute Ix^2 + Iy^2 in Q32.32 format
                    G_temp[i-1][j-1] = (Ix[i-1][j-1] * Ix[i-1][j-1]) + (Iy[i-1][j-1] * Iy[i-1][j-1]);

                    // Update G_max_temp if necessary
                    if (G_temp[i-1][j-1] > G_max_temp)
                        G_max_temp = G_temp[i-1][j-1];
                end
            end

            // Compute G[i][j] = sqrt(G_temp[i][j]), and normalize
            G_max_sqrt = fixed_sqrt(G_max_temp); // Q16.16

            for (i = 0; i < HEIGHT; i = i + 1) begin
                for (j = 0; j < WIDTH; j = j + 1) begin
                    // Compute sqrt(G_temp[i][j])
                    G_sqrt = fixed_sqrt(G_temp[i][j]); // Q16.16

                    // Multiply G_sqrt by CONST_255 (Q8.8), result in Q24.24
                    G_scaled = G_sqrt * CONST_255; // Q16.16 * Q8.8 = Q24.24

                    // Divide by G_max_sqrt (Q16.16), result in Q8.8
                    G_normalized = G_scaled / G_max_sqrt; // Q24.24 / Q16.16 = Q8.8

                    // Assign to output G[i][j] (Q8.8)
                    G[i][j] = G_normalized[23:8]; // Convert from Q24.24 to Q8.8

                    // Set theta[i][j] = pi/2 in Q8.8
                    theta[i][j] = CONST_PI_OVER_2;
                end
            end

            done <= 1;
        end else begin
            done <= 0;
        end
    end

endmodule
