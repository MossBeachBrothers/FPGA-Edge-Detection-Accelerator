import numpy as np
from scipy.ndimage import convolve as scipy_convolve
import matplotlib.pyplot as plt

def gaussian_kernel(size, sigma=1):
    if size % 2 == 0:
        raise ValueError("Kernel size must be odd.")
    size = size // 2
    x, y = np.mgrid[-size:size+1, -size:size+1]
    g = np.exp(-((x**2 + y**2) / (2.0 * sigma**2)))
    g /= g.sum()
    return g

def convolve_custom(input_array, kernel, mode='reflect', cval=0.0):
    kernel_flipped = np.flipud(np.fliplr(kernel))
    input_height, input_width = input_array.shape
    kernel_height, kernel_width = kernel.shape
    pad_height = kernel_height // 2
    pad_width = kernel_width // 2

    if mode == 'constant':
        padded_input = np.pad(input_array, 
                              ((pad_height, pad_height), (pad_width, pad_width)), 
                              mode=mode, constant_values=cval)
    else:
        padded_input = np.pad(input_array, 
                              ((pad_height, pad_height), (pad_width, pad_width)), 
                              mode=mode)

    convolved_array = np.zeros_like(input_array, dtype=np.float64)

    for i in range(input_height):
        for j in range(input_width):
            region = padded_input[i:i+kernel_height, j:j+kernel_width]
            convolved_value = np.sum(region * kernel_flipped)
            convolved_array[i, j] = convolved_value

    return convolved_array

def generate_test_image():
    return np.array([
        [10, 10, 10, 10, 10],
        [10, 50, 50, 50, 10],
        [10, 50,100, 50, 10],
        [10, 50, 50, 50, 10],
        [10, 10, 10, 10, 10]
    ], dtype=float)

def apply_convolutions(img, kernel, mode='reflect', cval=0.0):
    img_custom = convolve_custom(img, kernel, mode=mode, cval=cval)
    img_scipy = scipy_convolve(img, kernel, mode=mode, cval=cval)
    return img_custom, img_scipy

def compare_results(img_custom, img_scipy, tolerance=1e-6):
    print(f"CUSTOM{img_custom}")
    print(f"SCIPY{img_scipy}")

    difference = np.abs(img_custom - img_scipy)
    max_difference = np.max(difference)
    is_close = np.allclose(img_custom, img_scipy, atol=tolerance)
    return is_close, max_difference

def visualize_results(img, kernel, img_custom, img_scipy):
    plt.figure(figsize=(12, 8))

    plt.subplot(2, 2, 1)
    plt.title("Original Image")
    plt.imshow(img, cmap='gray', interpolation='nearest')
    plt.colorbar()

    plt.subplot(2, 2, 2)
    plt.title("Gaussian Kernel")
    plt.imshow(kernel, cmap='gray', interpolation='nearest')
    plt.colorbar()

    plt.subplot(2, 2, 3)
    plt.title("Custom Convolved Image")
    plt.imshow(img_custom, cmap='gray', interpolation='nearest')
    plt.colorbar()

    plt.subplot(2, 2, 4)
    plt.title("SciPy Convolved Image")
    plt.imshow(img_scipy, cmap='gray', interpolation='nearest')
    plt.colorbar()

    plt.tight_layout()
    plt.show()

def run_tests():
    kernel_size = 3
    sigma = 1.0
    mode = 'reflect'
    cval = 0.0

    img = generate_test_image()
    print("Test Image:\n", img)

    kernel = gaussian_kernel(kernel_size, sigma)
    print("\nGaussian Kernel:\n", kernel)

    img_custom, img_scipy = apply_convolutions(img, kernel, mode=mode, cval=cval)

    print("\nCustom Convolved Image:\n", img_custom)
    print("\nSciPy Convolved Image:\n", img_scipy)

    is_close, max_diff = compare_results(img_custom, img_scipy)
    print("\nComparison Result:")
    if is_close:
        print("Success! The custom convolution matches SciPy's convolution within the tolerance.")
    else:
        print(f"Failure! The maximum difference is {max_diff}, which exceeds the tolerance.")

    visualize = False  # Set to True to visualize
    if visualize:
        visualize_results(img, kernel, img_custom, img_scipy)

if __name__ == "__main__":
    run_tests()
"""This is an example input and the exact output htat the module shold output. Write a testbench that uses these exact same numbers to test the functionality of the module, by inputting the inputs and then testing the output to ensure it matches the expected output. Ensure that your testbench is professional and contains all valid SystemVerilog syntax, function, and logic : Test Image:
 [[ 10.  10.  10.  10.  10.]
 [ 10.  50.  50.  50.  10.]
 [ 10.  50. 100.  50.  10.]
 [ 10.  50.  50.  50.  10.]
 [ 10.  10.  10.  10.  10.]] Gaussian Kernel:
 [[0.07511361 0.1238414  0.07511361]
 [0.1238414  0.20417996 0.1238414 ]
 [0.07511361 0.1238414  0.07511361]]

Custom Convolved Image:
 [[22.01817727 25.91640089 31.92548952 25.91640089 22.01817727]
 [25.91640089 34.83473519 45.2293254  34.83473519 25.91640089]
 [31.92548952 45.2293254  60.20899778 45.2293254  31.92548952]
 [25.91640089 34.83473519 45.2293254  34.83473519 25.91640089]
 [22.01817727 25.91640089 31.92548952 25.91640089 22.01817727]] The testbench will laso have to include the gaussian kernel module, which has already been confirmed to be correct and has been given earlier """