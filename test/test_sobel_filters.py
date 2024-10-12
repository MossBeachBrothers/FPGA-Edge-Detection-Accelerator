
import numpy as np
from scipy import ndimage
from scipy.ndimage.filters import convolve

def sobel_filters(img):
        Kx = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], np.float32)
        Ky = np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]], np.float32)

        Ix = ndimage.filters.convolve(img, Kx)
        Iy = ndimage.filters.convolve(img, Ky)

        G = np.hypot(Ix, Iy)
        G = G / G.max() * 255
        theta = np.arctan2(Iy, Ix)
        return (G, theta)


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



test_sobel_filters()

