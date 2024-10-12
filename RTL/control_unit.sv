module control_unit (
    input  wire              clk,
    input  wire              reset_n,
    input  wire              enable,

    output reg               gaussian_enable,
    input  wire              gaussian_done,
    output reg               filter_enable,
    input  wire              filter_done,
    output reg               suppress_enable,
    input  wire              suppress_done,
    output reg               threshold_enable,
    input  wire              threshold_done,
    output reg               hysterisis_enable,
    input  wire              hysterisis_done
);

    // Define the state encoding using typedef enum
    typedef enum logic [2:0] {
        IDLE            = 3'd0,
        GAUSSIAN        = 3'd1,
        SOBEL_FILTERING = 3'd2,
        SUPPRESSION     = 3'd3,
        THRESHOLDING    = 3'd4,
        HYSTERISIS      = 3'd5,
        DONE            = 3'd6
    } pipeline_stages_t;

    // Current and next state registers
    pipeline_stages_t current_state, next_state;

    // Combinational logic for state transition
    always_comb begin
        // Default next state is the current state
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (enable)
                    next_state = GAUSSIAN;
                else
                    next_state = IDLE;
            end

            GAUSSIAN: begin
                if (gaussian_done)
                    next_state = SOBEL_FILTERING;
                else
                    next_state = GAUSSIAN;
            end

            SOBEL_FILTERING: begin
                if (filter_done)
                    next_state = SUPPRESSION;
                else
                    next_state = SOBEL_FILTERING;
            end

            SUPPRESSION: begin
                if (suppress_done)
                    next_state = THRESHOLDING;
                else
                    next_state = SUPPRESSION;
            end

            THRESHOLDING: begin
                if (threshold_done)
                    next_state = HYSTERISIS;
                else
                    next_state = THRESHOLDING;
            end

            HYSTERISIS: begin
                if (hysterisis_done)
                    next_state = DONE;
                else
                    next_state = HYSTERISIS;
            end

            DONE: begin
                if (!enable)
                    next_state = IDLE;
                else
                    next_state = DONE;
            end

            default: next_state = IDLE;
        endcase
    end

    // Sequential logic for state updating
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Combinational logic for output control signals
    always_comb begin
        // Default all enable signals to low
        gaussian_enable      = 1'b0;
        filter_enable        = 1'b0;
        suppress_enable      = 1'b0;
        threshold_enable     = 1'b0;
        hysterisis_enable    = 1'b0;

        case (current_state)
            GAUSSIAN:        gaussian_enable   = 1'b1;
            SOBEL_FILTERING: filter_enable     = 1'b1;
            SUPPRESSION:     suppress_enable   = 1'b1;
            THRESHOLDING:    threshold_enable  = 1'b1;
            HYSTERISIS:      hysterisis_enable = 1'b1;
            default: ;
        endcase
    end

endmodule
