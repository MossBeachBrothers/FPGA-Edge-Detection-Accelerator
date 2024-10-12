// Convolution Unit Module matching the Python function

module conv_unit #(
    parameter int IMAGE_HEIGHT = 5,
    parameter int IMAGE_WIDTH  = 5,
    parameter int KERNEL_SIZE  = 3,
    parameter int DATA_WIDTH   = 16, // Total bits for fixed-point representation
    parameter int FRAC_BITS    = 8   // Number of fractional bits
)(
    input  logic clk,
    input  logic resetn,
    input  logic enable,
    output logic done,
    input  logic [DATA_WIDTH-1:0] input_image [IMAGE_HEIGHT-1:0][IMAGE_WIDTH-1:0],
    input  logic signed [DATA_WIDTH-1:0] kernel [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0],
    output logic signed [DATA_WIDTH-1:0] output_image [IMAGE_HEIGHT-1:0][IMAGE_WIDTH-1:0]
);

    localparam int pad_height    = KERNEL_SIZE / 2;
    localparam int pad_width     = KERNEL_SIZE / 2;
    localparam int PADDED_HEIGHT = IMAGE_HEIGHT + 2 * pad_height;
    localparam int PADDED_WIDTH  = IMAGE_WIDTH  + 2 * pad_width;

    // Internal variables
    logic signed [DATA_WIDTH-1:0] padded_input [0:PADDED_HEIGHT-1][0:PADDED_WIDTH-1];
    logic signed [DATA_WIDTH-1:0] kernel_flipped [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
    int  i, j, m, n;
    logic signed [2*DATA_WIDTH-1:0] sum_reg;
    logic signed [2*DATA_WIDTH-1:0] mult_result;

    typedef enum logic [2:0] {
        IDLE,
        FLIP_KERNEL,
        PAD_INPUT,
        CONVOLUTION,
        DONE
    } state_t;

    state_t state;

    // Main process
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Reset state
            state    <= IDLE;
            done     <= 0;
            i        <= 0;
            j        <= 0;
            m        <= 0;
            n        <= 0;
            sum_reg  <= 0;
            // Initialize arrays to zero
            for (int p = 0; p < PADDED_HEIGHT; p++) begin
                for (int q = 0; q < PADDED_WIDTH; q++) begin
                    padded_input[p][q] <= '0;
                end
            end
        end else begin
            case (state)
                IDLE: begin
                    if (enable) begin
                        done  <= 0;
                        i     <= 0;
                        j     <= 0;
                        state <= FLIP_KERNEL;
                    end
                end
                FLIP_KERNEL: begin
                    // Flip the kernel both horizontally and vertically
                    for (int x = 0; x < KERNEL_SIZE; x++) begin
                        for (int y = 0; y < KERNEL_SIZE; y++) begin
                            kernel_flipped[x][y] <= kernel[KERNEL_SIZE - 1 - x][KERNEL_SIZE - 1 - y];
                        end
                    end
                    state <= PAD_INPUT;
                    i     <= 0;
                end
                PAD_INPUT: begin
                    if (i < IMAGE_HEIGHT) begin
                        // Copy input_image into the center of padded_input
                        for (int q = 0; q < IMAGE_WIDTH; q++) begin
                            padded_input[i + pad_height][q + pad_width] <= input_image[i][q];
                        end
                        i <= i + 1;
                    end else begin
                        // Apply 'reflect' padding
                        // Reflect padding on top and bottom
                        for (int p = 0; p < pad_height; p++) begin
                            for (int q = 0; q < PADDED_WIDTH; q++) begin
                                // Top padding
                                padded_input[p][q] <= padded_input[2 * pad_height - p][q];
                                // Bottom padding
                                padded_input[PADDED_HEIGHT - 1 - p][q] <= padded_input[PADDED_HEIGHT - 1 - (2 * pad_height - p)][q];
                            end
                        end
                        // Reflect padding on left and right
                        for (int p = 0; p < PADDED_HEIGHT; p++) begin
                            for (int q = 0; q < pad_width; q++) begin
                                // Left padding
                                padded_input[p][q] <= padded_input[p][2 * pad_width - q];
                                // Right padding
                                padded_input[p][PADDED_WIDTH - 1 - q] <= padded_input[p][PADDED_WIDTH - 1 - (2 * pad_width - q)];
                            end
                        end
                        state <= CONVOLUTION;
                        i     <= 0;
                        j     <= 0;
                    end
                end
                CONVOLUTION: begin
                    if (i < IMAGE_HEIGHT) begin
                        if (j < IMAGE_WIDTH) begin
                            sum_reg = 0;
                            for (int m = 0; m < KERNEL_SIZE; m++) begin
                                for (int n = 0; n < KERNEL_SIZE; n++) begin
                                    // Multiply and accumulate
                                    mult_result = padded_input[i + m][j + n] * kernel_flipped[m][n];
                                    sum_reg = sum_reg + mult_result;
                                end
                            end
                            // Adjust sum_reg back to fixed-point format by right-shifting
                            output_image[i][j] <= sum_reg[2*DATA_WIDTH-1:FRAC_BITS];
                            j <= j + 1;
                        end else begin
                            j <= 0;
                            i <= i + 1;
                        end
                    end else begin
                        state <= DONE;
                    end
                end
                DONE: begin
                    done <= 1;
                    if (!enable) begin
                        state <= IDLE;
                        done  <= 0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
