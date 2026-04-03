from BF16_to_NVFP4 import BF16_to_NVFP4
from NVFP4_to_BF16 import NVFP4_to_BF16
import struct

def getQuantizationError (bf16_list: list[int]):
    
    quantizedNVFP4, shared_exp = BF16_to_NVFP4(bf16_list)           # BF16 vector -> NVFP4 vector

    dequantizedBF16 = NVFP4_to_BF16(quantizedNVFP4, shared_exp)     # Resulting NVFP4 vector back to lower resolution BF16 vector

    quantizationErrorSum = 0

    for i in range(len(bf16_list)):
        original = struct.unpack('f', struct.pack('I', bf16_list[i] << 16))[0]          # Converts the raw 16 bit ints into 32 bit floats so that Python can do math with them.
        recovered = struct.unpack('f', struct.pack('I', dequantizedBF16[i] << 16))[0]
        quantizationErrorSum += abs(original - recovered)

    quantizationError = quantizationErrorSum / len(bf16_list)

    return quantizationError