// double_threshold_unit.sv
// Applies double thresholding to classify pixels into strong and weak edges based on gradient values, facilitating the differentiation of significant edges from noise.
//Written By: Akhil Nair 


`timescale 1ns/1ps

module double_threshold_unit #(
    // Parameters
    parameter integer HEIGHT = 5,
    parameter integer WIDTH  = 5,
    parameter integer HIGH_THRESHOLD_NUM = 3, // Represents 0.15
    parameter integer HIGH_THRESHOLD_DEN = 20,
    parameter integer LOW_THRESHOLD_NUM  = 1, // Represents 0.05
    parameter integer LOW_THRESHOLD_DEN  = 20,
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
    input  logic [7:0]        Z [0:HEIGHT*WIDTH-1],
    
    // Output Image
    output logic [7:0]        res [0:HEIGHT*WIDTH-1]
);

    // State Encoding
    typedef enum logic [2:0] {
        IDLE = 3'd0,
        FIND_MAX = 3'd1,
        COMPUTE_THRESHOLDS = 3'd2,
        APPLY_THRESHOLD = 3'd3,
        DONE_STATE = 3'd4
    } state_t;
    
    state_t current_state, next_state;
    
    // Internal Registers
    logic [7:0] max_value;
    logic [15:0] highThreshold_temp; // To prevent overflow during multiplication
    logic [15:0] lowThreshold_temp;
    logic [7:0] highThreshold;
    logic [7:0] lowThreshold;
    
    integer pixel_idx;
    
    // Sequential Logic for State Transition and Processing
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            max_value     <= 8'd0;
            highThreshold <= 8'd0;
            lowThreshold  <= 8'd0;
            pixel_idx     <= 0;
            done          <= 1'b0;
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
                        max_value <= 8'd0;
                        pixel_idx <= 0;
                    end
                end
                
                FIND_MAX: begin
                    if (pixel_idx < HEIGHT*WIDTH) begin
                        if (Z[pixel_idx] > max_value) begin
                            max_value <= Z[pixel_idx];
                        end
                        pixel_idx <= pixel_idx + 1;
                    end
                    else begin
                        pixel_idx <= 0;
                    end
                end
                
                COMPUTE_THRESHOLDS: begin
                    // Compute highThreshold = (max_value * HIGH_THRESHOLD_NUM) / HIGH_THRESHOLD_DEN
                    highThreshold_temp = (max_value * HIGH_THRESHOLD_NUM);
                    highThreshold = highThreshold_temp / HIGH_THRESHOLD_DEN;
                    
                    // Compute lowThreshold = (highThreshold * LOW_THRESHOLD_NUM) / LOW_THRESHOLD_DEN
                    lowThreshold_temp = (highThreshold * LOW_THRESHOLD_NUM);
                    lowThreshold = lowThreshold_temp / LOW_THRESHOLD_DEN;
                end
                
                APPLY_THRESHOLD: begin
                    if (pixel_idx < HEIGHT*WIDTH) begin
                        if (Z[pixel_idx] >= highThreshold) begin
                            res[pixel_idx] <= STRONG_PIXEL;
                        end
                        else if (Z[pixel_idx] >= lowThreshold) begin
                            res[pixel_idx] <= WEAK_PIXEL;
                        end
                        else begin
                            res[pixel_idx] <= 8'd0;
                        end
                        pixel_idx <= pixel_idx + 1;
                    end
                    else begin
                        done <= 1'b1;
                        pixel_idx <= 0;
                    end
                end
                
                DONE_STATE: begin
                    // Remain in DONE_STATE until reset or next enable
                    done <= 1'b1;
                end
                
                default: begin
                    // Default to IDLE
                    current_state <= IDLE;
                end
            endcase
        end
    end
    
    // Combinational Logic for Next State
    always_comb begin
        case (current_state)
            IDLE: begin
                if (enable)
                    next_state = FIND_MAX;
                else
                    next_state = IDLE;
            end
            
            FIND_MAX: begin
                if (pixel_idx < HEIGHT*WIDTH)
                    next_state = FIND_MAX;
                else
                    next_state = COMPUTE_THRESHOLDS;
            end
            
            COMPUTE_THRESHOLDS: begin
                next_state = APPLY_THRESHOLD;
            end
            
            APPLY_THRESHOLD: begin
                if (pixel_idx < HEIGHT*WIDTH)
                    next_state = APPLY_THRESHOLD;
                else
                    next_state = DONE_STATE;
            end
            
            DONE_STATE: begin
                if (enable)
                    next_state = FIND_MAX;
                else
                    next_state = DONE_STATE;
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule
