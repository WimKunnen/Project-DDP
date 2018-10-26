import random
import string

def random_hex(size):
	return ''.join(random.choice('abcdef' + string.digits) for _ in range(size))

def mul_vectors(size):
	a_str = random_hex(8*size)
	b_str = random_hex(8*size)
	a = int(a_str, 16)
	b = int(b_str, 16)
	res = a*b
	a = hex(a)[2:-1]
	b = hex(b)[2:-1]
	res = hex(res)[2:-1]
	a_arr = 'uint32_t a[' + str(size) + '] = {'
	b_arr = 'uint32_t b[' + str(size) + '] = {'
	res_arr = 'uint32_t expected[' + str(2*size) + '] = {'
	a_values = ''
	b_values = ''
	for i in range(size):
		a_values = '0x' + a[8*i:8*(i+1)] + ', ' + a_values
		b_values = '0x' + b[8*i:8*(i+1)] + ', ' + b_values
	a_arr += a_values[:-2] + '};'	
	b_arr += b_values[:-2] + '};'
	res_values = ''
	for i in range(2*size):
		res_values = '0x' + res[8*i:8*(i+1)] + ', ' + res_values
	res_arr += res_values[:-2] + '};'		
	print(a_arr)
	print(b_arr)
	print(res_arr)
mul_vectors(32)
