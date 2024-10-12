// hysteresis_unit.sv
// Finalizes edge detection by connecting weak edges to strong edges if they are adjacent, ensuring continuous and meaningful edge structures.
//Written By : Akhil Nair 
`timescale 1ns/1ps

module hysteresis_unit #(
    // Parameters
    parameter integer HEIGHT = 5,
    parameter integer WIDTH  = 5,
    parameter [7:0] WEAK_PIXEL   = 8'd75,
    parameter [7:0] STRONG_PIXEL = 8'd255
)(
    // Clock and Reset
    input  logic              clk,
    input  logic              reset,
    
    // Control Signals
    input  logic              enable,
    output logic              done,
    
    // Input Image
    input  logic [7:0]        img [0:HEIGHT*WIDTH-1],
    
    // Output Image
    output logic [7:0]        res [0:HEIGHT*WIDTH-1]
);

    // State Encoding
    typedef enum logic [2:0] {
        IDLE           = 3'd0,
        INITIALIZE     = 3'd1,
        PROCESS_PIXEL  = 3'd2,
        DONE_STATE     = 3'd3
    } state_t;
    
    state_t current_state, next_state;
    
    // Internal Registers
    integer pixel_idx;
    
    // Define row and col as combinational wires derived from pixel_idx
    wire [31:0] row = pixel_idx / WIDTH;
    wire [31:0] col = pixel_idx % WIDTH;
    
    // Calculate strong_found combinationally
    wire strong_found;
    assign strong_found = (row > 0 && row < HEIGHT-1 && col > 0 && col < WIDTH-1) && (
                              (img[(row+1)*WIDTH + (col-1)] == STRONG_PIXEL) ||
                              (img[(row+1)*WIDTH + col] == STRONG_PIXEL) ||
                              (img[(row+1)*WIDTH + (col+1)] == STRONG_PIXEL) ||
                              (img[row*WIDTH + (col-1)] == STRONG_PIXEL) ||
                              (img[row*WIDTH + (col+1)] == STRONG_PIXEL) ||
                              (img[(row-1)*WIDTH + (col-1)] == STRONG_PIXEL) ||
                              (img[(row-1)*WIDTH + col] == STRONG_PIXEL) ||
                              (img[(row-1)*WIDTH + (col+1)] == STRONG_PIXEL)
                          );
    
    // Sequential Logic for State Transition and Processing
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            done          <= 1'b0;
            pixel_idx     <= 0;
            // Initialize res to 0
            for (integer i = 0; i < HEIGHT*WIDTH; i++) begin
                res[i] <= 8'd0;
            end
        end
        else begin
            current_state <= next_state;
            
            case (current_state)
                IDLE: begin
                    done <= 1'b0;
                    if (enable) begin
                        pixel_idx <= 0;
                    end
                end
                
                INITIALIZE: begin
                    // Initialize res with img
                    for (integer i = 0; i < HEIGHT*WIDTH; i++) begin
                        res[i] <= img[i];
                    end
                end
                
                PROCESS_PIXEL: begin
                    if (pixel_idx < HEIGHT*WIDTH) begin
                        if (img[pixel_idx] == WEAK_PIXEL) begin
                            if (strong_found) begin
                                res[pixel_idx] <= STRONG_PIXEL;
                            end
                            else begin
                                res[pixel_idx] <= 8'd0;
                            end
                        end
                        pixel_idx <= pixel_idx + 1;
                    end
                end
                
                DONE_STATE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end
    
    // Combinational Logic for Next State
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (enable)
                    next_state = INITIALIZE;
                else
                    next_state = IDLE;
            end
            
            INITIALIZE: begin
                next_state = PROCESS_PIXEL;
            end
            
            PROCESS_PIXEL: begin
                if (pixel_idx < HEIGHT*WIDTH)
                    next_state = PROCESS_PIXEL;
                else
                    next_state = DONE_STATE;
            end
            
            DONE_STATE: begin
                if (enable)
                    next_state = INITIALIZE;
                else
                    next_state = DONE_STATE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
