import numpy as np

def threshold(img, highThreshold=0.3, lowThreshold=0.1, weak_pixel=75, strong_pixel=255):
    highThreshold = img.max() * highThreshold
    lowThreshold = highThreshold * lowThreshold

    M, N = img.shape
    res = np.zeros((M, N), dtype=np.int32)

    strong_i, strong_j = np.where(img >= highThreshold)
    weak_i, weak_j = np.where((img <= highThreshold) & (img >= lowThreshold))

    res[strong_i, strong_j] = strong_pixel
    res[weak_i, weak_j] = weak_pixel

    return res

def test_threshold():
    # Create a dummy image for testing
    img = np.array([[0, 0, 0, 0, 0],
                    [0, 100, 100, 100, 0],
                    [0, 100, 255, 100, 0],
                    [0, 100, 100, 100, 0],
                    [0, 0, 0, 0, 0]], dtype=np.float32)

    print("Input Image:")
    print(img)

    # Apply thresholding
    thresholded_output = threshold(img, highThreshold=0.3, lowThreshold=0.1)
    print("Thresholding Output:")
    print(thresholded_output)

test_threshold()
