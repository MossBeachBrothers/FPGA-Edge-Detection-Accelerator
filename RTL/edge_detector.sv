module edge_detector #(
    parameter IMAGE_HEIGHT=500,
    parameter IMAGE_WIDTH=400
)(
    input wire clk,
    input wire reset_n
    input wire enable,
    input wire image_in,
    output wire image_out,
    output wire image_valid,
); 


//intermediate signals
wire input_image
wire kernel_matrix
wire output_image
wire gradient_matrix
wire theta_matrix
wire non_max_image_z
wire threshold_result
wire hysterisis_result 
wire output_image 

//control signals
wire gaussian_enable, filter_enable, suppress_enable, threshold_enable, hysterisis_enable


//status signals
wire gaussian_done, filter_done, suppress_done, threshold_done, hsyerisis_done

control_unit cu_inst (
    .clk(),
    .reset_n(),
    .enable(),
    .gaussian_enable(),
    .gaussian_done(),
    .filter_enable(),
    .filter_done(),
    .suppress_enable(),
    .suppress_done(),
    .threshold_enable(),
    .threshold_done(),
    .hysterisis_enable(),
    .hysterisis_done()
);

gaussian_kernel gaussian_inst (
    .clk(clk),
    .reset(),
    .enable(),
    .done(),
    kernel_matrix()
);

sobel_filter filter_inst (
    .clk(clk),
    .enable(),
    .image(),
    .done(),
    .G(),
    .theta()
);

non_max_suppression #(
    WIDTH=5,
    HEIGHT=5
) suppression_inst(
    .clk(clk),
    .enable(),
    .G(),
    .theta(),
    .done(),
    .Z()
);

double_threshold_unit threshold_inst(
    .clk(),
    .reset(),
    .enable(),
    .done(),
    .Z(),
    .res()
);

hysterisis_unit hysterisis_inst(
    .clk(clk),
    .reset(),
    .enable(),
    .done(),
    .img(),
    .res()
);

peripheral input_peripheral_inst();

peripheral output_peripheral_inst();

endmodule





