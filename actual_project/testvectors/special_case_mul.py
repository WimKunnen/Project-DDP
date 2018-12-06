import helpers
import HW
import SW

import sys


M = helpers.getModulus(1024)
# A = helpers.getRandomInt(1024) % M
# B = helpers.getRandomInt(1024) % M
A = M-1
B = M-1

D = HW.MontMul_2bW(A, B, M)


print "A                = ", hex(A)           # 1024-bits
print "B                = ", hex(B)           # 1024-bits
print "M                = ", hex(M)           # 1024-bits
print "(A*B*R^-1) mod M = ", hex(D)           # 1024-bits

