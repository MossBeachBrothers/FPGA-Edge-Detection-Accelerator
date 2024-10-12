from PIL import Image

def resize_image(input_path, output_path, size=(500, 400)):
    """
    Resize an image to the specified size and save it in JPEG format.

    Parameters:
        input_path (str): The path to the input image (JPEG format).
        output_path (str): The path where the resized image will be saved.
        size (tuple): The desired size as a (width, height) tuple. Default is (500, 400).
    """
    try:
        # Open the input image
        with Image.open(input_path) as img:
            # Resize the image with high-quality resampling
            resized_img = img.resize(size, Image.LANCZOS)
            # Save the resized image in JPEG format
            resized_img.save(output_path, format='JPEG', quality=95)
            print(f"Image resized and saved to {output_path}")
    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
resize_image('5.jpg', 'output.jpg')
