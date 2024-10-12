import numpy as np

def hysteresis(img):
    M, N = img.shape
    weak = 75
    strong = 255

    for i in range(1, M-1):
        for j in range(1, N-1):
            if img[i, j] == weak:
                try:
                    if (img[i+1, j-1] == strong or img[i+1, j] == strong or img[i+1, j+1] == strong or
                        img[i, j-1] == strong or img[i, j+1] == strong or
                        img[i-1, j-1] == strong or img[i-1, j] == strong or img[i-1, j+1] == strong):
                        img[i, j] = strong
                    else:
                        img[i, j] = 0
                except IndexError:
                    pass

    return img

# Create a sample input image
sample_img = np.array([
    [0, 0, 0, 0, 0],
    [0, 255, 0, 0, 0],
    [0, 75, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0]
])

# Print the original image
print("Original Image:")
print(sample_img)

# Run the hysteresis function
result_img = hysteresis(sample_img)

# Print the result
print("\nResulting Image after Hysteresis:")
print(result_img)
