import binascii
import random
import math

import sys
sys.setrecursionlimit(1500)

def setSeed(seedInput):
    random.seed(seedInput)

def getModuli(bits):
    bits = bits / 2
    N = 1
    while bitlen(N) != bits*2:
        p     = getRandomPrime(bits)
        q     = getRandomPrime(bits)
        N     = p*q
    return [p,q,N]

def getModulus(bits):
    n = random.randrange(2**(bits-1), 2**bits-1)
    # print gcd(n, 2**bits)
    while not gcd(n, 2**bits) == 1:
        n = random.randrange(2**(bits-1), 2**bits-1)
    mod = n
    return n

def getRandomMessage(bits,M):
    return random.randrange(2**(bits-1), M); 

def getRandomMessageForCRT(p,q):
    if p < q:
        M = p
    else:
        M = q
    return random.randrange(M); 

def getRandomPrime(bits):
    n = random.randrange(2**(bits-1), 2**bits-1)
    while not isPrime(n):
        n = random.randrange(2**(bits-1), 2**bits-1)
    return n

def getRandomInt(bits):
    return random.randrange(2**(bits-1), 2**bits-1)

def getRandomExponents(p, q):
    phi = (p-1)*(q-1)
    e = getRandomPrime(16)
    while not gcd(e, phi) == 1:
        e = getRandomPrime(16)
    d = Modinv(e,phi)
    return [e,d]

def isPrime(n, k=5): # miller-rabin
    from random import randint
    if n < 2: return False
    for p in [2,3,5,7,11,13,17,19,23,29]:
        if n % p == 0: return n == p
    s, d = 0, n-1
    while d % 2 == 0:
        s, d = s+1, d/2
    for i in range(k):
        x = pow(randint(2, n-1), d, n)
        if x == 1 or x == n-1: continue
        for r in range(1, s):
            x = (x * x) % n
            if x == 1: return False
            if x == n-1: break
        else: return False
    return True

def bitlen(n):
    return int(math.log(n, 2)) + 1

def bit(y,index):
  bits   = [(y >> i) & 1 for i in range(1024)]
  bitstr = ''.join([chr(sum([bits[i * 8 + j] << j for j in range(8)])) for i in range(1024/8)])
  return (ord(bitstr[index/8]) >> (index%8)) & 1

def gcd(x, y):
    while y != 0:
        (x, y) = (y, x % y)
    return x

def Modexp(b,e,m):
  if e == 0: return 1
  t = Modexp(b,e/2,m)**2 % m
  if e & 1: t = (t*b) % m
  return t

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def Modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        return -1
    else:
        return x % m

def WriteConstants(number, size):

    # wordLenInBits = 32

    # charlen = wordLenInBits / 4

    # text   = hex(number)

    # # Remove unwanted characters 0x....L
    # if text[-1] == "L":
    #     text = text[2:-1]
    # else:
    #     text = text[2:]
    
    # # Split the number into word-bit chunks
    # text   = text.zfill(len(text) + len(text) % charlen)  
    # # result = ' '.join("0x"+text[i: i+charlen]+"," for i in range(0, len(text), charlen)) 
    # result = ' '.join("0x"+text[i: i+charlen]+"," for i in reversed(range(0, len(text), charlen))) 

    # # Remove the last comma
    # result = result[:-1]

    # return result

    # size=32

    out = ''

    for i in range(size):
        out += '0x{:08x}'.format(number & 0xFFFFFFFF)
        number >>= 32
        out += ', ' if i<(size - 1) else ''
    return out
    
    # print (out)

def CreateConstants(seed, N, e, d, M):
    target = open("./testvector.c", 'w')
    target.truncate()

    # extern uint32_t N[32],
    #                 e[32],       
    #                 e_len,       
    #                 d[32],
    #                 d_len,    
    #                 M[32], 
    #                 R_1024[32],  
    #                 R2_1024[32];          

    R    = 2**1024
    R_N  = R % N
    R2_N = (R*R) % N

    target.write(
    "#include <stdint.h>                                              \n" +
    "                                                                 \n" +
    "// This file's content is created by the testvector generator    \n" +
    "// python script for seed = " + str(seed) + "                    \n" +   
    "//                                                               \n" +    
    "//  The variables are defined for the RSA                        \n" +   
    "// encryption and decryption operations. And they are assigned   \n" +   
    "// by the script for the generated testvector. Do not create a   \n" +
    "// new variable in this file.                                    \n" +
    "//                                                               \n" +
    "// When you are submitting your results, be careful to verify    \n" +
    "// the test vectors created for seeds from 2018.1, to 2018.5     \n" +
    "// To create them, run your script as:                           \n" +
    "//   $ python testvectors.py rsa 2018.1                          \n" +
    "                                                                 \n" +
    "// modulus                                                       \n" +
    "uint32_t N[32]       = {" + WriteConstants(N,32) + "};           \n" +
    "                                                                 \n" +
    "// encryption exponent                                           \n" +
    "uint32_t e[32]       = {" + WriteConstants(e,1) + "};            \n" +
    "uint32_t e_len       = 16;                                       \n" +
    "                                                                 \n" +
    "// decryption exponent, reduced to p and q                       \n" +
    "uint32_t d[32]       = {" + WriteConstants(d,32) + "};           \n" +
    "uint32_t d_len       =  " + str(int(math.log(d, 2)) + 1) + ";    \n" +    
    "                                                                 \n" +
    "// the message                                                   \n" +
    "uint32_t M[32]       = {" + WriteConstants(M,32) + "};           \n" +
    "                                                                 \n" +
    "// R mod N, and R^2 mod N, (R = 2^1024)                          \n" +
    "uint32_t R_N[32]     = {" + WriteConstants(R_N ,32) + "};        \n" +
    "uint32_t R2_N[32]    = {" + WriteConstants(R2_N,32) + "};        \n" )

    target.close()