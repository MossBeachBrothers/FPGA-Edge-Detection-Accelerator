import numpy as np
from scipy import ndimage

def non_max_suppression(img, D):
    M, N = img.shape
    Z = np.zeros((M, N), dtype=np.int32)
    angle = D * 180. / np.pi
    angle[angle < 0] += 180

    for i in range(1, M-1):
        for j in range(1, N-1):
            try:
                q = 255
                r = 255

                # angle 0
                if (0 <= angle[i, j] < 22.5) or (157.5 <= angle[i, j] <= 180):
                    q = img[i, j + 1]
                    r = img[i, j - 1]
                # angle 45
                elif (22.5 <= angle[i, j] < 67.5):
                    q = img[i + 1, j - 1]
                    r = img[i - 1, j + 1]
                # angle 90
                elif (67.5 <= angle[i, j] < 112.5):
                    q = img[i + 1, j]
                    r = img[i - 1, j]
                # angle 135
                elif (112.5 <= angle[i, j] < 157.5):
                    q = img[i - 1, j - 1]
                    r = img[i + 1, j + 1]

                if (img[i, j] >= q) and (img[i, j] >= r):
                    Z[i, j] = img[i, j]
                else:
                    Z[i, j] = 0

            except IndexError as e:
                pass

    return Z

def test_non_max_suppression():
    # Create a dummy gradient magnitude and direction for testing
    img = np.array([[0, 0, 0, 0, 0],
                    [0, 100, 100, 100, 0],
                    [0, 100, 255, 100, 0],
                    [0, 100, 100, 100, 0],
                    [0, 0, 0, 0, 0]], dtype=np.float32)

    D = np.array([[0, 0, 0, 0, 0],
                  [0, 1, 1, 0, 0],
                  [0, 1, 0, 1, 0],
                  [0, 1, 1, 0, 0],
                  [0, 0, 0, 0, 0]], dtype=np.float32) * (np.pi / 4)  # Angles in radians

    print("Input Image (Gradient Magnitude):")
    print(img)
    print("Input Angles (D):")
    print(D)

    output = non_max_suppression(img, D)

    print("Non-Maximum Suppression Output:")
    print(output)

test_non_max_suppression()
