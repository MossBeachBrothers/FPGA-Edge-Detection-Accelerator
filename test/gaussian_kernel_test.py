import numpy as np
from scipy import ndimage

def gaussian_kernel(size, sigma=1.0):
    size = int(size) // 2
    x, y = np.mgrid[-size:size+1, -size:size+1]
    normal = 1 / (2.0 * np.pi * sigma**2)
    g = np.exp(-((x**2 + y**2) / (2.0 * sigma**2))) * normal
    return g

def sobel_filters(img):
    Kx = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], np.float32)
    Ky = np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]], np.float32)

    Ix = ndimage.convolve(img, Kx)
    Iy = ndimage.convolve(img, Ky)

    G = np.hypot(Ix, Iy)
    G = G / G.max() * 255
    theta = np.arctan2(Iy, Ix)
    return G, theta

def print_gaussian_kernel(size, sigma):
    # Generate the kernel
    kernel = gaussian_kernel(size, sigma)
    
    # Print the output in the same format as in the SystemVerilog testbench
    print(f"Gaussian Kernel (size={size}, sigma={sigma}):")
    for i in range(kernel.shape[0]):
        for j in range(kernel.shape[1]):
            print(f"kernel_matrix[{i}][{j}] = {kernel[i][j]:.6f}")
        print()  # Separate rows

def test_sobel_filters():
    # Test Sobel filter with a simple image (e.g., a gradient or an edge)
    img = np.array([[10, 10, 10, 10, 10],
                    [20, 20, 20, 20, 20],
                    [30, 30, 30, 30, 30],
                    [40, 40, 40, 40, 40],
                    [50, 50, 50, 50, 50]], dtype=np.float32)
    
    G, theta = sobel_filters(img)
    
    # Print the magnitude and angle of the gradients
    print("Sobel Filter Results:")
    print("Gradient Magnitude (G):")
    print(G)
    print("Gradient Direction (theta):")
    print(theta)

if __name__ == "__main__":
    # Parameters (same as in the SystemVerilog testbench)
    size = 5
    sigma = 1.0
    
    # Print the Gaussian Kernel
    print_gaussian_kernel(size, sigma)
    
    # Test the Sobel filter function
    test_sobel_filters()
