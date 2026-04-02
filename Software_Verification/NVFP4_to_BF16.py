def NVFP4_to_BF16 (nvfp4_list: list[int], shared_exp):
    signs = []
    exps = []
    mans = []

    for value in nvfp4_list:
        signs.append((value >> 3) & 1)
        exps.append((value >> 1) & 3)
        mans.append(value & 1)

