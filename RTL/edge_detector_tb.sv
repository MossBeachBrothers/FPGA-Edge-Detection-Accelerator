module tb_edge_detector;

  // Parameters
  parameter int HEIGHT = 50;
  parameter int WIDTH = 50;

  // Inputs
  reg clk;
  reg reset_n;
  reg enable;
  reg [7:0] image_in [HEIGHT-1:0][WIDTH-1:0];
  reg image_in_valid;

  // Outputs
  wire [7:0] image_out [HEIGHT-1:0][WIDTH-1:0];
  wire image_out_valid;

  // Debug Signals
  wire gaussian_enable, conv_enable, filter_enable, suppress_enable, threshold_enable, hysteresis_enable;
  wire gaussian_done, conv_done, filter_done, suppress_done, threshold_done, hysteresis_done;

  // Instantiate the Unit Under Test (UUT)
  edge_detector #(
    .HEIGHT(HEIGHT),
    .WIDTH(WIDTH)
  ) uut (
    .clk(clk),
    .reset_n(reset_n),
    .enable(enable),
    .image_in(image_in),
    .image_in_valid(image_in_valid),
    .image_out(image_out),
    .image_out_valid(image_out_valid)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Task to load the image from a text file
  task load_image_from_file(input string filename);
    integer file, r, i, j;
    file = $fopen(filename, "r");
    if (file == 0) begin
      $display("Error opening file %s", filename);
      $finish;
    end
    for (i = 0; i < HEIGHT; i = i + 1) begin
      for (j = 0; j < WIDTH; j = j + 1) begin
        r = $fscanf(file, "%d\n", image_in[i][j]);
        if (r != 1) begin
          $display("Error reading pixel data at (%0d, %0d)", i, j);
          $finish;
        end
      end
    end
    $fclose(file);
    $display("Image loaded successfully from %s", filename);
  endtask

  // Task to save the output image to a text file
  task save_image_to_file(input string filename);
    integer file, i, j;
    file = $fopen(filename, "w");
    if (file == 0) begin
      $display("Error opening file %s", filename);
      $finish;
    end
    for (i = 0; i < HEIGHT; i = i + 1) begin
      for (j = 0; j < WIDTH; j = j + 1) begin
        $fwrite(file, "%d\n", image_out[i][j]);
      end
    end
    $fclose(file);
    $display("Output image saved to %s", filename);
  endtask

  // Task to display debug signals for each stage of the module
  task display_debug_signals();
    $display("Gaussian Enable: %b, Done: %b", gaussian_enable, gaussian_done);
    $display("Convolution Enable: %b, Done: %b", conv_enable, conv_done);
    $display("Sobel Filter Enable: %b, Done: %b", filter_enable, filter_done);
    $display("Non-Max Suppression Enable: %b, Done: %b", suppress_enable, suppress_done);
    $display("Threshold Enable: %b, Done: %b", threshold_enable, threshold_done);
    $display("Hysteresis Enable: %b, Done: %b", hysteresis_enable, hysteresis_done);
  endtask

  // Control and status signal monitoring for debugging
  initial begin
    // Monitor the state of control signals during the simulation
    $monitor("Time: %0t, Gaussian Done: %b, Conv Done: %b, Filter Done: %b, Suppress Done: %b, Threshold Done: %b, Hysteresis Done: %b, Image Out Valid: %b",
             $time, gaussian_done, conv_done, filter_done, suppress_done, threshold_done, hysteresis_done, image_out_valid);
  end

  // Clock, reset, and simulation control
  initial begin
    // Initialize inputs
    clk = 0;
    reset_n = 0;
    enable = 0;
    image_in_valid = 0;

    // Load the input image from file
    load_image_from_file("input_image.txt");

    // Reset the system
    #10 reset_n = 1;
    enable = 1;
    image_in_valid = 1;

    // Wait for the edge detection process to start
    #10;
    display_debug_signals();

    // Wait for the edge detection process to complete
    wait(image_out_valid);

    // Save the output image to a file
    save_image_to_file("output_image.txt");

    // Display the final state of debug signals
    display_debug_signals();

    // End simulation
    $finish;
  end

  // Assertions to check correct signal transitions
  always @(posedge clk) begin
    if (reset_n) begin
      // Assert that once enabled, the image_in_valid signal stays high until the output is valid
      assert(image_in_valid || image_out_valid) else $fatal("Image input should be valid while processing!");

      // Assert that the output valid signal is asserted only after hysteresis is done
      assert(!image_out_valid || hysteresis_done) else $fatal("Output valid should only be high after hysteresis is done!");
    end
  end

endmodule
