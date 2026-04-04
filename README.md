# NVFP4-Model

A hardware implementation of the NVFP4 (E2M1) floating point format in SystemVerilog, synthesized in Intel Quartus, with a Python reference model for verification.

## Overview

This project implements:
1. Quantization of BF16 vectors to NVFP4 format with a shared group exponent
2. Dequantization of NVFP4 back to BF16
3. Dot product of two NVFP4 vectors
4. Quantization error analysis datapath
5. A Python reference model that mirrors the hardware behavior

## Format

- **NVFP4 (E2M1):** 1 sign bit, 2 exponent bits, 1 mantissa bit
- **Group size:** 16 elements per shared exponent
- **Bias:** 2, Max exponent: 3
- **Input:** BF16 (16-bit)
- **Output:** 4-bit compressed elements + 8-bit shared exponent

## Files

### Synthesis
- `conv_bf16tonvfp4.sv` — Converts BF16 vector to NVFP4
- `conv_nvfp4tobf16.sv` — Dequantizes NVFP4 vector back to BF16
- `quantization_error_datapath.sv` — Chains quantization and dequantization to measure error
- `dot_fp.sv` — Computes dot product of two NVFP4 vectors
- `nvfp4_datapath_top.sv` — Top level datapath
- `unsigned_max.sv`, `fp_rnd_rne.sv`, `clz_int.sv`, `vec_mul_fp.sv`, `vec_sum_int.sv`, `mul_fp.sv`, `mul_int.sv` — Submodules

### Testbenches
- `tb_conv_bf16tonvfp4.sv` — Verifies BF16 to NVFP4 conversion
- `tb_conv_nvfp4tobf16.sv` — Verifies NVFP4 to BF16 dequantization
- `tb_quantization_error_datapath.sv` — Verifies quantization error datapath
- `tb_dot_fp.sv` — Verifies dot product computation
- `tb_nvfp4_datapath_top.sv` — Top level simulation

### Python
- `BF16_to_NVFP4.py` — Converts BF16 vector to NVFP4
- `NVFP4_to_BF16.py` — Dequantizes NVFP4 back to BF16
- `quantization_error.py` — Computes average quantization error

## Simulation Results

- All 1.0 inputs → NVFP4 = `0110`, shared_exp = 125 ✓
- All 1.5 inputs → NVFP4 = `0111`, shared_exp = 125 ✓
- All 2.0 inputs → NVFP4 = `0110`, shared_exp = 126 ✓
- Dot product of 16×`0110` · 16×`0110` = 1024 ✓
- Dot product of 16×`0110` · 16×`0111` = 1536 ✓
- Round-trip 1.0 → NVFP4 → BF16 = 1.0, error = 0 ✓
- Round-trip 0.125 in mixed group → dequantizes to 0.15625, nonzero error ✓

## References

Based on the MX (Microscaling) open source repo, parameterized for NVFP4.