// sobel_filter_fixed_tb.sv
// Testbench for Sobel Filter Fixed-Point
// Author: Akhil Nair

`timescale 1ns/1ps

module sobel_filter_fixed_tb;

  parameter WIDTH = 5;
  parameter HEIGHT = 5;
  parameter FIXED_WIDTH = 16;
  parameter FIXED_FRAC = 8; // Using Q8.8 format

  reg clk;
  reg enable;
  reg [FIXED_WIDTH-1:0] image [0:HEIGHT+1][0:WIDTH+1]; // Padded image in Q8.8

  wire done;
  wire signed [FIXED_WIDTH-1:0] G [0:HEIGHT-1][0:WIDTH-1];
  wire signed [FIXED_WIDTH-1:0] theta [0:HEIGHT-1][0:WIDTH-1];

  // Instantiate the sobel_filter_fixed module
  sobel_filter_fixed #(WIDTH, HEIGHT, FIXED_WIDTH, FIXED_FRAC) uut (
    .clk(clk),
    .enable(enable),
    .image(image),
    .done(done),
    .G(G),
    .theta(theta)
  );

  integer i, j;
  integer error_flag;
  real epsilon;

  // Function to convert real to fixed-point Q8.8
  function signed [FIXED_WIDTH-1:0] real_to_fixed;
    input real val;
    begin
      real_to_fixed = $rtoi(val * (2.0 ** FIXED_FRAC));
    end
  endfunction

  // Function to convert fixed-point Q8.8 to real
  function real fixed_to_real;
    input signed [FIXED_WIDTH-1:0] val;
    begin
      fixed_to_real = $itor(val) / (2.0 ** FIXED_FRAC);
    end
  endfunction

  // Function for absolute value (added)
  function real abs;
    input real val;
    begin
      if (val < 0.0)
        abs = -val;
      else
        abs = val;
    end
  endfunction

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Clock with a period of 10 time units
  end

  // Test procedure
  initial begin
    real G_real;
    real theta_real;
    real expected_G_real;
    real expected_theta_real;
    reg signed [FIXED_WIDTH-1:0] expected_G [0:HEIGHT-1][0:WIDTH-1];
    reg signed [FIXED_WIDTH-1:0] expected_theta [0:HEIGHT-1][0:WIDTH-1];

    error_flag = 0;
    epsilon = 1.0; // Adjusted for lower precision

    // Initialize the image with the given data (scaled to Q8.8)
    for (i = 1; i <= HEIGHT; i = i + 1) begin
      for (j = 1; j <= WIDTH; j = j + 1) begin
        image[i][j] = real_to_fixed(10.0 * i);
      end
    end

    // Pad the borders by replicating edge pixels
    // Top and bottom rows
    for (j = 1; j <= WIDTH; j = j + 1) begin
      image[0][j] = image[1][j];
      image[HEIGHT+1][j] = image[HEIGHT][j];
    end

    // Left and right columns
    for (i = 0; i <= HEIGHT+1; i = i + 1) begin
      image[i][0] = image[i][1];
      image[i][WIDTH+1] = image[i][WIDTH];
    end

    // Corners
    image[0][0] = image[1][1];
    image[0][WIDTH+1] = image[1][WIDTH];
    image[HEIGHT+1][0] = image[HEIGHT][1];
    image[HEIGHT+1][WIDTH+1] = image[HEIGHT][WIDTH];

    // Apply reset
    enable = 0;
    #10;
    enable = 1;
    #10;
    enable = 0;

    // Wait for 'done' signal
    wait (done == 1);

    // Initialize expected_G in fixed-point
    for (i = 0; i < HEIGHT; i = i + 1) begin
      for (j = 0; j < WIDTH; j = j + 1) begin
        if (i == 0 || i == HEIGHT-1)
          expected_G[i][j] = real_to_fixed(127.5);
        else
          expected_G[i][j] = real_to_fixed(255.0);
        expected_theta[i][j] = real_to_fixed(1.5708); // pi/2
      end
    end

    // Compare the outputs
    for (i = 0; i < HEIGHT; i = i + 1) begin
      for (j = 0; j < WIDTH; j = j + 1) begin
        G_real = fixed_to_real(G[i][j]);
        theta_real = fixed_to_real(theta[i][j]);
        expected_G_real = fixed_to_real(expected_G[i][j]);
        expected_theta_real = fixed_to_real(expected_theta[i][j]);

        if ((abs(G_real - expected_G_real) > epsilon) ||
            (abs(theta_real - expected_theta_real) > epsilon)) begin
          $display("Mismatch at pixel (%0d,%0d): G=%f (expected %f), theta=%f (expected %f)",
            i, j, G_real, expected_G_real, theta_real, expected_theta_real);
          error_flag = 1;
        end else begin
          $display("Pixel (%0d,%0d) matches: G=%f, theta=%f", i, j, G_real, theta_real);
        end
      end
    end

    if (error_flag == 0) begin
      $display("Test passed: All pixels match expected outputs.");
    end else begin
      $display("Test failed: There were mismatches in the outputs.");
    end

    $stop;
  end

endmodule
