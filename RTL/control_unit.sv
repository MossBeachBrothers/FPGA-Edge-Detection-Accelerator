module control_unit (
    input wire clk,
    input wire reset_n,
    input wire enable,


    output wire gaussian_enable,
    input wire gaussian_done,
    output wire filter_enable,
    input wire filter_done,
    output wire suppress_enable,
    input wire suppress_done,
    output wire threshold_enable,
    input wire threshold_done,
    output wire hysterisis_enable,
    input wire hysterisis_done

); endmodule 



//Control Unit State machine 


typdef enum {
    IDLE,
    GAUSSIAN,
    SOBEL_FILTERING,
    SUPPRESSION,
    THRESHOLDING,
    HYSTERISIS, 
    DONE,
} pipeline_stages;


pipeline_stages current_state, next_state;

wire 



always_comb begin
    //Define what the next state is based on values
    case () endcase; 

end;


always_ff (@posdege clk) begin 
    //Determine whether to move to the next state, or stay in current state
    //Define output control variables to interface with other units
end 


;


