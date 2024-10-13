`timescale 1ns/1ps


module control_unit (
    input  wire              clk,
    input  wire              reset_n,
    input  wire              enable,

    output reg               gaussian_enable,
    input  wire              gaussian_done,
    output reg               conv_enable,
    input  wire              conv_done,
    output reg               filter_enable,
    input  wire              filter_done,
    output reg               suppress_enable,
    input  wire              suppress_done,
    output reg               threshold_enable,
    input  wire              threshold_done,
    output reg               hysterisis_enable,
    input  wire              hysterisis_done
);

    typedef enum logic [2:0] {
        IDLE            = 3'd0,
        GAUSSIAN        = 3'd1,
        CONVOLUTION     = 3'd2,
        SOBEL_FILTERING = 3'd3,
        SUPPRESSION     = 3'd4,
        THRESHOLDING    = 3'd5,
        HYSTERISIS      = 3'd6,
        DONE            = 3'd7
    } pipeline_stages_t;

    pipeline_stages_t current_state, next_state;

    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (enable)
                    next_state = GAUSSIAN;
            end

            GAUSSIAN: begin
                if (gaussian_done)
                    next_state = CONVOLUTION;
            end

            CONVOLUTION: begin
                if (conv_done)
                    next_state = SOBEL_FILTERING;
            end

            SOBEL_FILTERING: begin
                if (filter_done)
                    next_state = SUPPRESSION;
            end

            SUPPRESSION: begin
                if (suppress_done)
                    next_state = THRESHOLDING;
            end

            THRESHOLDING: begin
                if (threshold_done)
                    next_state = HYSTERISIS;
            end

            HYSTERISIS: begin
                if (hysterisis_done)
                    next_state = DONE;
            end

            DONE: begin
                if (!enable)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        gaussian_enable      = 1'b0;
        conv_enable          = 1'b0;
        filter_enable        = 1'b0;
        suppress_enable      = 1'b0;
        threshold_enable     = 1'b0;
        hysterisis_enable    = 1'b0;

        case (current_state)
            GAUSSIAN:        gaussian_enable   = 1'b1;
            CONVOLUTION:     conv_enable       = 1'b1;
            SOBEL_FILTERING: filter_enable     = 1'b1;
            SUPPRESSION:     suppress_enable   = 1'b1;
            THRESHOLDING:    threshold_enable  = 1'b1;
            HYSTERISIS:      hysterisis_enable = 1'b1;
        endcase
    end

endmodule
