import helpers
import HW
import SW

import sys

operation = 0
seed = "random"

print "TEST VECTOR GENERATOR FOR DDP\n"

if len(sys.argv) == 2 or len(sys.argv) == 3 or len(sys.argv) == 4:
  if str(sys.argv[1]) == "adder":           operation = 1;
  if str(sys.argv[1]) == "subtractor":      operation = 2;
  if str(sys.argv[1]) == "multiplication":  operation = 3;
  if str(sys.argv[1]) == "exponentiation":  operation = 4;
  if str(sys.argv[1]) == "rsa":             operation = 5;
  if str(sys.argv[1]) == "mul_custom":      operation = 6;

if len(sys.argv) == 3:
  print "Seed is: ", sys.argv[2], "\n"
  seed = sys.argv[2]
  helpers.setSeed(sys.argv[2])

#####################################################

if operation == 0:
  print "You should use this script by passing an argument like:"
  print " $ python testvectors.py adder"
  print " $ python testvectors.py subractor"
  print " $ python testvectors.py multiplication"
  print " $ python testvectors.py exponentiation"
  print " $ python testvectors.py rsa"
  print ""
  print "You can also set a seed for randomness to work"
  print "with the same testvectors at each execution:"
  print " $ python testvectors.py rsa 2017"
  print ""

#####################################################

if operation == 1:
  print "Test Vector for Multi Precision Adder\n"

  A = helpers.getRandomInt(1027)
  B = helpers.getRandomInt(1027)
  C = HW.MultiPrecisionAddSub_1027(A,B,"add")

  print "A                = ", hex(A)           # 1027-bits
  print "B                = ", hex(B)           # 1027-bits
  print "A + B            = ", hex(C)           # 1028-bits

#####################################################

if operation == 2:
  print "Test Vector for Multi Precision Subtractor\n"

  A = helpers.getRandomInt(1027)
  B = helpers.getRandomInt(1027)
  C = HW.MultiPrecisionAddSub_1027(A,B,"subtract")

  print "A                = ", hex(A)           # 1027-bits
  print "B                = ", hex(B)           # 1027-bits
  print "A - B            = ", hex(C)           # 1028-bits

#####################################################

if operation == 3:

  print "Test Vector for Windoed Montgomery Multiplication\n"

  M = helpers.getModulus(1024)
  A = helpers.getRandomInt(1024) % M
  B = helpers.getRandomInt(1024) % M

  C = SW.MontMul(A, B, M)
  # D = HW.MontMul(A, B, M)
  D = HW.MontMul_2bW(A, B, M)

  e = (C - D)

  print "A                = ", hex(A)           # 1024-bits
  print "B                = ", hex(B)           # 1024-bits
  print "M                = ", hex(M)           # 1024-bits
  print "(A*B*R^-1) mod M = ", hex(C)           # 1024-bits
  print "(A*B*R^-1) mod M = ", hex(D)           # 1024-bits
  print "error            = ", hex(e)

#####################################################

if operation == 4:

  print "Test Vector for Montgomery Exponentiation\n"

  X = helpers.getRandomInt(1024)
  E = helpers.getRandomInt(8)
  M = helpers.getModulus(1024)
  C = HW.MontExp(X, E, M)
  D = helpers.Modexp(X, E, M)
  e = C - D

  print "X                = ", hex(X)           # 1024-bits
  print "E                = ", hex(E)           # 8-bits
  print "M                = ", hex(M)           # 1024-bits
  print "(X^E) mod M      = ", hex(C)           # 1024-bits
  print "(X^E) mod M      = ", hex(D)           # 1024-bits
  print "error            = ", hex(e)

#####################################################

if operation == 5:

  print "Test Vector for RSA\n"

  print "\n--- Precomputed Values"

  # Generate two primes (p,q), and modulus
  [p,q,N] = helpers.getModuli(1024)

  print "p            = ", hex(p)               # 512-bits
  print "q            = ", hex(q)               # 512-bits
  print "Modulus      = ", hex(N)               # 1024-bits

  # Generate Exponents
  [e,d] = helpers.getRandomExponents(p,q)

  print "Enc exp      = ", hex(e)               # 16-bits
  print "Dec exp      = ", hex(d)               # 1024-bits

  # Generate Message
  M     = helpers.getRandomMessage(1024,N)

  print "Message      = ", hex(M)               # 1024-bits

  helpers.CreateConstants(seed, N, e, d, M)

  #####################################################

  print "\n--- Execute RSA (for verification)"

  # Encrypt
  Ct = SW.MontExp(M, e, N)                      # 1024-bit exponentiation
  print "Ciphertext   = ", hex(Ct)              # 1024-bits

  # Decrypt
  Pt = SW.MontExp(Ct, d, N)                     # 1024-bit exponentiation
  print "Plaintext    = ", hex(Pt)              # 1024-bits

  #####################################################

  print "\n--- Execute RSA in HW (slow)"

  # Encrypt
  Ct = HW.MontExp(M, e, N)                      # 1024-bit exponentiation
  print "Ciphertext   = ", hex(Ct)              # 1024-bits

  # Decrypt
  Pt = HW.MontExp(Ct, d, N)                     # 1024-bit exponentiation
  print "Plaintext    = ", hex(Pt)              # 1024-bits
#####################################################

if operation == 6:

  print "Test Vector for Windoed Montgomery Multiplication\n"

  M = helpers.getModulus(1024)
  A = int(sys.argv[2]) % M
  B = int(sys.argv[3]) % M

  C = SW.MontMul(A, B, M)
  # D = HW.MontMul(A, B, M)
  D = HW.MontMul_2bW(A, B, M)

  e = (C - D)

  print "A                = ", hex(A)           # 1024-bits
  print "B                = ", hex(B)           # 1024-bits
  print "M                = ", hex(M)           # 1024-bits
  print "(A*B*R^-1) mod M = ", hex(C)           # 1024-bits
  print "(A*B*R^-1) mod M = ", hex(D)           # 1024-bits
  print "error            = ", hex(e)
