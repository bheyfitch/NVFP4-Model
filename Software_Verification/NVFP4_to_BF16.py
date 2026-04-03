def NVFP4_to_BF16 (nvfp4_list: list[int], shared_exp):
    signs = []
    exps = []
    mans = []

    for value in nvfp4_list:
        signs.append((value >> 3) & 1)
        exps.append((value >> 1) & 3)
        mans.append(value & 1)

    bf16_exps = []
    for exp in exps:
        bf16_exps.append(shared_exp + 2 - 3 + exp)  # Working backwards from the BF16_to_NVFP4 function, we get this formula for the original BF16 exponent where 2 is the bias and 3 is the max possible NVFP4 exponent.

    bf16_mans = []
    for man in mans:
        if man == 0:
            bf16_mans.append(0b0000000)         # Doesn't include the implicit leading 1.
        else:                                   # Only other case is when the mantissa is 1.
            bf16_mans.append(0b1000000)

    bf16_out = []
    for i in range(len(signs)):
        if (mans[i] == 0 and exps[i] == 0):
            bf16_out.append(0)
        else:
            bf16_out.append((signs[i] << 15) | (bf16_exps[i] << 7) | bf16_mans[i])

    return bf16_out