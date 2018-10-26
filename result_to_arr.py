
def hex_str_to_c_arr(size, in_string):
	in_string = in_string[2:]
	result = 'uint32_t expected[' + str(size) + '] = {'
	arr = '0x' + in_string[-8:] + ', '
	for i in range(1, size-1):
		arr = arr + '0x' + in_string[-8*(i+1):-8*i] + ', '
	index = len(in_string) % 8
	if index == 0:
		index = 8
	arr = arr + '0x' + in_string[:index]
	result = result + arr + '};'
	print(result)

print("Montgomery test 1:")
hex_str_to_c_arr(32, '0x65a0397e62a35770f74d4710f48624616726b8ed0e2735f47deec3cdcb17a1043b6ec2575aa490d4babfb22ce0a9c7ce0a5c4bf4153aacb65c4cc3a99ae0c37b29753f17d504a58581d4714c6bc893474d1c12aa55cfb322e78b03b698f88c7755d17774803996e0bc4e5bd183481c72461cd34d9c234b140b90c4feb7e3ef3')
print("Montgomery test 2:")
hex_str_to_c_arr(32, '0x6a7decd785d91b9f6b70806a679e9aa1fb42688fe9e57d266f93d1e246eda22186dab2c2998fe1c46d5160c41802240954e7fa142d2936f3e0f765293a62ed6ce215dbb8923e818c7df6bde0a4586c9ca1427bbfd5012ddd28a49995b57482b8293a279e8b3a5383366243e900ec59c61deec41ab41445b244ced61ce4a627f2')
print("Montgomery test 3:")
hex_str_to_c_arr(32, '0x11d7e2256e49fd2852a7b38f29408bfe01e17c2a391d873eba1be739105282ae40b1b03c270446f9bf345d0b64db0e7f5f0f7503851fe6c8994fb3f4cf37d992ba3ee24e8af15a07a523a0842d2b3ca4d15373508b1bc301bb2b3cd50e815dc509c51cebdbbe1d00b783bb665896f601f61ba6f036cdf567a0b3d297c60b461c')
