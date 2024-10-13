`timescale 1ns/1ps

module edge_detector #(
    parameter int HEIGHT = 50,
    parameter int WIDTH = 50,
    parameter int KERNEL_HEIGHT = 5,
    parameter int KERNEL_WIDTH = 5
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

    // Control Signals
    wire gaussian_enable, conv_enable, filter_enable, suppress_enable, threshold_enable, hysteresis_enable;
    
    // Intermediate Signals
    wire [KERNEL_HEIGHT-1:0][KERNEL_WIDTH-1:0] kernel_matrix; // Gaussian kernel matrix
    wire [15:0] smoothed_pixel [HEIGHT-1:0][WIDTH-1:0];       // After convolution
    wire [15:0] gradient [HEIGHT-1:0][WIDTH-1:0];
    wire [15:0] theta [HEIGHT-1:0][WIDTH-1:0];
    wire [15:0] non_max_pixel [HEIGHT-1:0][WIDTH-1:0];
    wire [7:0] threshold_pixel [HEIGHT-1:0][WIDTH-1:0];
    wire [7:0] final_pixel [HEIGHT-1:0][WIDTH-1:0];
    
    // Control Unit Instance
    control_unit cu_inst (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .gaussian_enable(gaussian_enable),
        .gaussian_done(gaussian_done),
        .conv_enable(conv_enable),
        .conv_done(conv_done),
        .filter_enable(filter_enable),
        .filter_done(filter_done),
        .suppress_enable(suppress_enable),
        .suppress_done(suppress_done),
        .threshold_enable(threshold_enable),
        .threshold_done(threshold_done),
        .hysteresis_enable(hysteresis_enable),
        .hysteresis_done(hysteresis_done)
    );
    
    // Gaussian Filter
    gaussian_kernel  #(
        .SIZE(KERNEL_HEIGHT),
        .SIGMA(1)  // example sigma value, replace as needed
    ) gaussian_inst (
        .clk(clk),
        .reset(reset_n),
        .enable(gaussian_enable),
        .done(gaussian_done),
        .kernel_matrix(kernel_matrix)
    );
    
    // Convolution Unit 
    conv_unit #(
        .IMAGE_HEIGHT(HEIGHT),
        .IMAGE_WIDTH(WIDTH),
        .KERNEL_SIZE(KERNEL_HEIGHT),
        .DATA_WIDTH(16),
        .FRAC_BITS(8)  // example fractional bits
    ) conv_inst (
        .clk(clk),
        .resetn(reset_n),
        .enable(conv_enable),
        .done(conv_done),
        .input_image(image_in),
        .kernel(kernel_matrix),
        .output_image(smoothed_pixel)
    );

    // Sobel Filter
    sobel_filter #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT)
    ) filter_inst (
        .clk(clk),
        .enable(filter_enable),
        .image(smoothed_pixel),
        .done(filter_done),
        .G(gradient),
        .theta(theta)
    );

    // Non-Maximum Suppression
    non_max_suppression #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT)
    ) suppression_inst (
        .clk(clk),
        .enable(suppress_enable),
        .G(gradient),
        .theta(theta),
        .done(suppress_done),
        .Z(non_max_pixel)
    );
    
    // Thresholding
    double_threshold_unit #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .HIGH_THRESHOLD_NUM(3),
        .HIGH_THRESHOLD_DEN(20),
        .LOW_THRESHOLD_NUM(1),
        .LOW_THRESHOLD_DEN(20),
        .WEAK_PIXEL(8'd75),
        .STRONG_PIXEL(8'd255)
    ) threshold_inst (
        .clk(clk),
        .reset(reset_n),
        .enable(threshold_enable),
        .done(threshold_done),
        .Z(non_max_pixel),
        .res(threshold_pixel)
    );

    // Hysteresis
    hysteresis_unit #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .WEAK_PIXEL(8'd75),
        .STRONG_PIXEL(8'd255)
    ) hysteresis_inst (
        .clk(clk),
        .reset(reset_n),
        .enable(hysteresis_enable),
        .done(hysteresis_done),
        .img(threshold_pixel),
        .res(final_pixel)
    );
    
    // Output Assignment
    assign image_out = final_pixel;
    assign image_out_valid = hysteresis_done;
    
endmodule
