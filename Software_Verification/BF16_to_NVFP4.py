def BF16_to_NVFP4(vec: list[int]):
    signs = []
    exps = []
    mans = []
    for value in vec:                               # Extracts the sign, exponent, and mantissa values from each BF16 element in the block of 16.
        signs.append((value >> 15) & 1)
        exps.append((value >> 7) & 0xFF)
        mans.append(value & 0x7F)
    
    e_max = max(exps)

    d_shifts = []
    for exp in exps:                                # Finds the d_shift for each value.
        d_shifts.append(e_max - exp)

    mans_extended = []                              # List of mantissas with leading 1s.
    for i in range(len(mans)): 
        if exps[i] != 0:
            mans_extended.append((1 << 7) | mans[i]) # Creates 10000000 and then bitwise OR with mantissa to add the implicit leading 1 to the mantissa.
        else:
            mans_extended.append(mans[i] << 1)
    
    mans_normalized = []
    for i in range(len(mans_extended)):
        mans_normalized.append(mans_extended[i] >> d_shifts[i]) # Shifts mantissas by d_shift to the left to normalize them, so that we are not comparring apples to oranges.
    
    mans_rounded = []
    for man_normal in mans_normalized:
        mans_rounded.append((man_normal >> 6) & 1) # Shifts the normalized mantissa 7 bits to the right, leaving only the MSB, which is the bit we want to round the mantissa to.
    
    exps_new = []
    for d_shift in d_shifts:
        exps_new.append(max(3 - d_shift, 0)) # Set the max possible exponenet to the largest exponent value in the inital block to maximize the range of values. If a value's d_shift is too large, the value is represented as 0.

    nvfp4 = []
    for i in range(len(signs)):
        nvfp4.append(signs[i] << 3 | (exps_new[i] << 1 | mans_rounded[i]))

    shared_exp = e_max - 2                  # shared_exp represents the scale regarding how much we scaled the block of 16 down throughout the conversion. This is relative to the bias for normalization purposes.
    
    return nvfp4, shared_exp