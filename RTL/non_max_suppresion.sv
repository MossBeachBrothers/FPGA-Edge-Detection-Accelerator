// non_max_suppression.sv
//Non Max Suppresion is

//Akhil Nair 
module non_max_suppression #(
    parameter WIDTH = 5,
    parameter HEIGHT = 5
)(
    input wire                  clk,
    input wire                  enable,
    input real                  G [0:HEIGHT-1][0:WIDTH-1],
    input real                  theta [0:HEIGHT-1][0:WIDTH-1],
    output reg                  done,
    output var int              Z [0:HEIGHT-1][0:WIDTH-1]
);
    real angle [0:HEIGHT-1][0:WIDTH-1];
    integer i, j;
    real q, r;

    always @(posedge clk) begin
        if (enable) begin
            done <= 0;

            // Convert theta to degrees and adjust angles less than 0
            for (i = 0; i < HEIGHT; i = i + 1) begin
                for (j = 0; j < WIDTH; j = j + 1) begin
                    angle[i][j] = theta[i][j] * 180.0 / 3.14159265;
                    if (angle[i][j] < 0)
                        angle[i][j] = angle[i][j] + 180.0;
                end
            end

            // Initialize Z to zeros
            for (i = 0; i < HEIGHT; i = i + 1) begin
                for (j = 0; j < WIDTH; j = j + 1) begin
                    Z[i][j] = 0;
                end
            end

            // Perform non-maximum suppression
            for (i = 1; i < HEIGHT - 1; i = i + 1) begin
                for (j = 1; j < WIDTH - 1; j = j + 1) begin
                    q = 255;
                    r = 255;

                    // Angle 0 degrees
                    if ((angle[i][j] >= 0 && angle[i][j] < 22.5) || (angle[i][j] >= 157.5 && angle[i][j] <= 180)) begin
                        q = G[i][j + 1];
                        r = G[i][j - 1];
                    end
                    // Angle 45 degrees
                    else if (angle[i][j] >= 22.5 && angle[i][j] < 67.5) begin
                        q = G[i + 1][j - 1];
                        r = G[i - 1][j + 1];
                    end
                    // Angle 90 degrees
                    else if (angle[i][j] >= 67.5 && angle[i][j] < 112.5) begin
                        q = G[i + 1][j];
                        r = G[i - 1][j];
                    end
                    // Angle 135 degrees
                    else if (angle[i][j] >= 112.5 && angle[i][j] < 157.5) begin
                        q = G[i - 1][j - 1];
                        r = G[i + 1][j + 1];
                    end

                    if ((G[i][j] >= q) && (G[i][j] >= r)) begin
                        Z[i][j] = G[i][j];
                    end else begin
                        Z[i][j] = 0;
                    end
                end
            end

            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule
