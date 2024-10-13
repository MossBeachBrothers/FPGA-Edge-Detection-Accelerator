import numpy as np
import cv2

def generate_noisy_square_image(image_size=(50, 50), square_size=(30, 30), noise_factor=0.02, filename="noisy_square.jpg", text_filename="image_data.txt"):
    # Create a black background
    image = np.zeros((image_size[0], image_size[1]), dtype=np.uint8)
    
    # Define the top-left corner of the white square
    start_x = (image_size[1] - square_size[1]) // 2
    start_y = (image_size[0] - square_size[0]) // 2
    
    # Draw the white square
    image[start_y:start_y+square_size[0], start_x:start_x+square_size[1]] = 255
    
    # Generate noise only for the black areas (background)
    noise = np.random.normal(0, 255 * noise_factor, image_size).astype(np.int16)
    
    # Apply noise only to the background (black areas) and clip to avoid high-intensity noise
    noisy_image = np.where(image == 0, np.clip(image + noise, 0, 100), image).astype(np.uint8)
    
    # Save the noisy image as a JPEG file
    cv2.imwrite(filename, noisy_image)
    
    # Write pixel intensities to a text file
    with open(text_filename, "w") as f:
        for row in noisy_image:
            for pixel in row:
                f.write(f"{pixel}\n")

# Example usage
generate_noisy_square_image(image_size=(50, 50), square_size=(30, 30), noise_factor=0.05, filename="noisy_square.jpg", text_filename="image_data.txt")
