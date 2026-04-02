from BF16_to_NVFP4 import BF16_to_NVFP4

K = 16
vec_a = [0x3F80] * K
vec_b = [0x3FC0] * K

nvfp4_a, exp_a = BF16_to_NVFP4(vec_a)
nvfp4_b, exp_b = BF16_to_NVFP4(vec_b)

# dot product and error analysis here
print(f"NVFP4 A: {[bin(x) for x in nvfp4_a]}")
print(f"Shared exp A: {exp_a}")
print(f"NVFP4 B: {[bin(x) for x in nvfp4_b]}")
print(f"Shared exp B: {exp_b}")