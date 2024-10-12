module edge_detector (
    input wire clk,
    input wire reset_n
    input wire enable,
    input wire image_in,
    output wire image_out,
    output wire image_valid,
); 


control_unit cu_inst ();

gaussian_kernel gaussian_inst ();

sobel_filter filter_inst ();

max_suppression_unit suppression_inst();

double_threshold_unit threshold_inst();

hysterisis_unit hysterisis_inst();

peripheral input_peripheral_inst();

peripheral output_peripheral_inst();

endmodule





