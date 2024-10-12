// sobel_filter_tb.sv
//Testbench for Sobel Filter
//Akhil Nair 
module sobel_filter_tb;

  parameter WIDTH = 5;
  parameter HEIGHT = 5;

  reg clk;
  reg enable;
  reg [31:0] image [0:HEIGHT+1][0:WIDTH+1]; // Padded image

  wire done;
  real G [0:HEIGHT-1][0:WIDTH-1];
  real theta [0:HEIGHT-1][0:WIDTH-1];

  // Instantiate the sobel_filter module
  sobel_filter #(WIDTH, HEIGHT) uut (
    .clk(clk),
    .enable(enable),
    .image(image),
    .done(done),
    .G(G),
    .theta(theta)
  );

  // Function for absolute value
  function real abs;
    input real val;
    begin
      if (val < 0.0)
        abs = -val;
      else
        abs = val;
    end
  endfunction

  integer i, j;
  integer error_flag;
  real epsilon;

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Clock with a period of 10 time units
  end

  // Test procedure
  initial begin
    real expected_G [0:HEIGHT-1][0:WIDTH-1];
    real expected_theta [0:HEIGHT-1][0:WIDTH-1];

    error_flag = 0;
    epsilon = 0.001;

    // Initialize the image with the given data
    // Set image[1][1] to image[5][5] with the given data
    image[1][1] = 32'd10;
    image[1][2] = 32'd10;
    image[1][3] = 32'd10;
    image[1][4] = 32'd10;
    image[1][5] = 32'd10;

    image[2][1] = 32'd20;
    image[2][2] = 32'd20;
    image[2][3] = 32'd20;
    image[2][4] = 32'd20;
    image[2][5] = 32'd20;

    image[3][1] = 32'd30;
    image[3][2] = 32'd30;
    image[3][3] = 32'd30;
    image[3][4] = 32'd30;
    image[3][5] = 32'd30;

    image[4][1] = 32'd40;
    image[4][2] = 32'd40;
    image[4][3] = 32'd40;
    image[4][4] = 32'd40;
    image[4][5] = 32'd40;

    image[5][1] = 32'd50;
    image[5][2] = 32'd50;
    image[5][3] = 32'd50;
    image[5][4] = 32'd50;
    image[5][5] = 32'd50;

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

    // Initialize expected_G
    expected_G[0] = '{127.5, 127.5, 127.5, 127.5, 127.5};
    expected_G[1] = '{255.0, 255.0, 255.0, 255.0, 255.0};
    expected_G[2] = '{255.0, 255.0, 255.0, 255.0, 255.0};
    expected_G[3] = '{255.0, 255.0, 255.0, 255.0, 255.0};
    expected_G[4] = '{127.5, 127.5, 127.5, 127.5, 127.5};

    // Initialize expected_theta
    for (i = 0; i < HEIGHT; i = i + 1) begin
      for (j = 0; j < WIDTH; j = j + 1) begin
        expected_theta[i][j] = 1.5707964; // Approximately pi/2
      end
    end

    // Compare the outputs
    for (i = 0; i < HEIGHT; i = i + 1) begin
      for (j = 0; j < WIDTH; j = j + 1) begin
        if ((abs(G[i][j] - expected_G[i][j]) > epsilon) || (abs(theta[i][j] - expected_theta[i][j]) > epsilon)) begin
          $display("Mismatch at pixel (%0d,%0d): G=%f (expected %f), theta=%f (expected %f)",
            i, j, G[i][j], expected_G[i][j], theta[i][j], expected_theta[i][j]);
          error_flag = 1;
        end else begin
          $display("Pixel (%0d,%0d) matches: G=%f, theta=%f", i, j, G[i][j], theta[i][j]);
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
