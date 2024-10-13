module edge_detector #(
    parameter int HEIGHT = 50,
    parameter int WIDTH = 50,
    parameter int KERNEL_HEIGHT=5,
    parameter int KERNEL_HEIGHT=5
)(
    input  wire              clk,
    input  wire              reset_n,
    input  wire              enable,
    
    // Input Image Stream
    input  wire [7:0]        image_in [HEIGHT-1:0][WIDTH-1:0],
    input  wire              image_in_valid,
    
    // Output Image Stream
    output wire [7:0]        image_out [HEIGHT-1:0][WIDTH-1:0],
    output wire              image_out_valid
);

    wire gaussian_done;
    wire kernel_matrix [KERNEL_HEIGHT-1: KERNEL_WIDTH-1:0];
    // Intermediate Signals for Partitioned Block (50x50 by default)
    wire conv_enable;
    wire [15:0]       smoothed_pixel [HEIGHT-1:0][WIDTH-1:0]; //output of conv 
    wire              smoothed_valid [HEIGHT-1:0][WIDTH-1:0];
    wire conv_done;
    
    wire [15:0]       gradient [HEIGHT-1:0][WIDTH-1:0];
    wire [15:0]       theta [HEIGHT-1:0][WIDTH-1:0];
    wire              gradient_valid [HEIGHT-1:0][WIDTH-1:0];
    wire              filter_done;
    
    wire [15:0]       non_max_pixel [HEIGHT-1:0][WIDTH-1:0];
    wire              non_max_valid [HEIGHT-1:0][WIDTH-1:0];
    wire              suppress_done;
    
    wire [7:0]        threshold_pixel [HEIGHT-1:0][WIDTH-1:0];
    wire              threshold_valid [HEIGHT-1:0][WIDTH-1:0];
    wire              threshold_done;
    
    wire [7:0]        final_pixel [HEIGHT-1:0][WIDTH-1:0];
    wire              final_valid [HEIGHT-1:0][WIDTH-1:0];
    wire              hysterisis_done;
    
    // Control Signals
    wire gaussian_enable, conv_enable, filter_enable, suppress_enable, threshold_enable, hysterisis_enable;
    
    
    // Control Unit Instance
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
    
    // Submodule Instances
    
    // Gaussian Filter
    gaussian_kernel  #(
        SIZE=,
        SIGMA=
    ) gaussian_inst (
        .clk(),
        .reset(),
        .enable(),
        .done(),
        .kernel_matrix()
    );
    

    //Conv Unit 
    conv_unit #(
        IMAGE_HEIGHT=,
        IMAGE_WIDTH=,
        KERNEL_SIZE=,
        DATA_WIDTH=,
        FRAC_BITS=
    ) conv_inst (
        .clk(),
        .resetn(),
        .enable(),
        .done(),
        .input_image(),
        .kernel(),
        .output_image()

    );
    // Sobel Filter
    sobel_filter #(
        WIDTH=,
        HEIGHT=,
    ) filter_inst (
        .clk(),
        .enable(),
        .image(),
        .done(),
        .G(),
        .theta()
    );

    // Non-Maximum Suppression
    non_max_suppression #(
        WIDTH=,
        HEIGHT=,
    ) suppression_inst (
        .clk(),
        .enable(),
        .G(),
        .theta(),
        .done(),
        .Z()
    );
    
    // Thresholding
    double_threshold_unit #(
        HEIGHT=,
        WIDTH=,
        HIGH_THRESHOLD_NUM=3,
        HIGH_THRESHOLD_DEN=20,
        LOW_THRESHOLD_NUM=1,
        LOW_THRESHOLD_DEN=20,
        WEAK_PIXEL=8'd75,
        STRONG_PIXEL=8'd255
    ) threshold_inst (
        .clk(),
        .reset(),
        .enable(),
        .done(),
        .Z(),
        .res()
    );
    // Hysteresis
    hysteresis_unit #(
        HEIGHT=,
        WIDTH=,
        WEAK_PIXEL=8'd75,
        STRONG_PIXEL=8'd255
    ) hysterisis_inst (
        .clk(),
        .reset(),
        .enable(),
        .done(),
        .img(),
        .res()
    );
    
    // Output Assignment
    assign image_out     = final_pixel;
    assign image_out_valid = final_valid;
    
endmodule
