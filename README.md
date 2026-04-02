# NVFP4-Model

A hardware implementation of the NVFP4 (E2M1) floating point format in SystemVerilog, synthesized in Intel Quartus.

## Overview

This project implements a datapath that:
1. Takes two input vectors of 16 BF16 values
2. Converts them to NVFP4 format by factoring out a shared group exponent
3. Computes their dot product

## Format

- **NVFP4 (E2M1):** 1 sign bit, 2 exponent bits, 1 mantissa bit
- **Group size:** 16 elements per shared exponent
- **Input:** BF16 (16-bit)
- **Output:** 4-bit compressed elements + 8-bit shared exponent

## Files

### Synthesis
- `conv_bf16tomxfp.sv` — Converts BF16 vector to NVFP4
- `dot_fp.sv` — Computes dot product of two NVFP4 vectors
- `nvfp4_datapath_top.sv` — Top level datapath
- `unsigned_max.sv`, `fp_rnd_rne.sv`, `clz_int.sv`, `vec_mul_fp.sv`, `vec_sum_int.sv`, `mul_fp.sv`, `mul_int.sv` — Submodules

### Testbenches
- `tb_conv_bf16tomxfp.sv` — Verifies BF16 to NVFP4 conversion
- `tb_dot_fp.sv` — Verifies dot product computation
- `tb_nvfp4_datapath_top.sv` — Top level simulation

## References

Based on the MX (Microscaling) open source repo, parameterized for NVFP4.
