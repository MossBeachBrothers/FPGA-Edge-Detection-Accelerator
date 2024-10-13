// sobel_filter.sv

//Sobel Filter: discrete differentiation operator. Computes approximation of gradient. Filter uses 3x3 conv kernels, one for horizontal and for vertical (Kx and Ky)
//Akhil Nair 
`timescale 1ns/1ps

module sobel_filter #(
    parameter WIDTH = 5,
    parameter HEIGHT = 5
)(
    input  wire                   clk,
    input  wire                   enable,
    input  wire [31:0]            image [0:HEIGHT+1][0:WIDTH+1], // Padded image
    output reg                    done,
    output var real               G [0:HEIGHT-1][0:WIDTH-1],
    output var real               theta [0:HEIGHT-1][0:WIDTH-1]
);
    real Kx [0:2][0:2] = '{
        '{ -1.0, 0.0, 1.0 },
        '{ -2.0, 0.0, 2.0 },
        '{ -1.0, 0.0, 1.0 }
    };
    real Ky [0:2][0:2] = '{
        '{ 1.0, 2.0, 1.0 },
        '{ 0.0, 0.0, 0.0 },
        '{ -1.0, -2.0, -1.0 }
    };

    real Ix [0:HEIGHT-1][0:WIDTH-1];
    real Iy [0:HEIGHT-1][0:WIDTH-1];
    real G_max;

    integer i, j, m, n;

    // Function for absolute value
    function real abs;
        input real val;
        begin
            if (val < 0.0)
                abs = -val;
            else
                abs = val;
        end
    endfunction

    // Custom square root function using Newton-Raphson method
    function real mysqrt;
        input real x;
        real y, y_prev;
        begin
            if (x <= 0.0) begin
                mysqrt = 0.0;
            end else begin
                y = x / 2.0;
                repeat (10) begin
                    y_prev = y;
                    y = (y + x / y) / 2.0;
                    if (abs(y - y_prev) < 1e-6)
                        break;
                end
                mysqrt = y;
            end
        end
    endfunction

    always @(posedge clk) begin
        if (enable) begin
            done <= 0;
            G_max = 0.0;

            // Compute Ix, Iy, and G
            for (i = 1; i <= HEIGHT; i = i + 1) begin
                for (j = 1; j <= WIDTH; j = j + 1) begin
                    Ix[i-1][j-1] = 0.0;
                    Iy[i-1][j-1] = 0.0;

                    for (m = 0; m < 3; m = m + 1) begin
                        for (n = 0; n < 3; n = n + 1) begin
                            Ix[i-1][j-1] += Kx[m][n] * image[i + m - 1][j + n - 1];
                            Iy[i-1][j-1] += Ky[m][n] * image[i + m - 1][j + n - 1];
                        end
                    end

                    G[i-1][j-1] = mysqrt(Ix[i-1][j-1] ** 2 + Iy[i-1][j-1] ** 2);
                    if (G[i-1][j-1] > G_max)
                        G_max = G[i-1][j-1];
                end
            end

            // Normalize G and set theta to pi/2
            for (i = 0; i < HEIGHT; i = i + 1) begin
                for (j = 0; j < WIDTH; j = j + 1) begin
                    G[i][j] = (G[i][j] / G_max) * 255.0;
                    theta[i][j] = 1.5707964; // Approximately π/2
                end
            end

            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule
