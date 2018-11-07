import helpers

# Here we implement the three functions 
# that we implement in the hardware lab sessions.

# The mongomery multiplication, and exponentiation
# follow the pseudo code given in the slides,
# so that if needed students can debug
# their code by printing the intermediate values.

def MultiPrecisionAddSub_1026(A, B, addsub):
    # returns (A + B) mod 2^1026 if   addsub == "add"
    #         (A - B) mod 2^1026 else
    
    mask1026  = 2**1026 - 1
    mask1027  = 2**1027 - 1

    am     = A & mask1026
    bm     = B & mask1026

    if addsub == "add": 
        r = (am + bm) 
    else:
        r = (am - bm)
    
    return r & mask1027

def MultiPrecisionAddSub_1027(A, B, addsub):
    # returns (A + B) mod 2^1027 if   addsub == "add"
    #         (A - B) mod 2^1027 else
    
    mask1027  = 2**1027 - 1
    mask1028  = 2**1028 - 1

    am     = A & mask1027
    bm     = B & mask1027

    if addsub == "add": 
        r = (am + bm) 
    else:
        r = (am - bm)
    
    return r & mask1028

def MontMul(A, B, M):
    # Returns (A*B*Modinv(R,M)) mod M
    
    regA  = A
    regB  = B
    regC  = 0
    regM  = M

    for i in range(0,1024):
        
        if (regA % 2) == 0  : regC = regC
        else                : regC = MultiPrecisionAddSub_1026(regC, regB, "add")
        
        if (regC % 2) == 0  : regC = regC / 2
        else                : regC = MultiPrecisionAddSub_1026(regC, regM, "add") / 2
    
        regA = regA >> 1

    while regC >= regM:
        regC = MultiPrecisionAddSub_1026(regC, regM, "sub")
    
    return regC

def ModMux(M, twoM, threeM, Csel, Msel):
    
    if   (Csel == 0 and Msel == 1) or (Csel == 0 and Msel == 3) : return 0;
    elif (Csel == 1 and Msel == 1) or (Csel == 3 and Msel == 3) : return threeM;
    elif (Csel == 2 and Msel == 1) or (Csel == 2 and Msel == 3) : return twoM;
    elif (Csel == 3 and Msel == 1) or (Csel == 1 and Msel == 3) : return M;

def MontMul_2bW(A, B, M):
    # Implements the multiplication with 2-bit windows
    # Returns (A*B*Modinv(R,M)) mod M
    
    WindowSize = 2
    b = 2**WindowSize
    
    regA  = A
    regB  = B
    regC  = 0
    regM  = M

    # reg2B = MultiPrecisionAddSub_1027(regB, regB , "add")
    reg3B = MultiPrecisionAddSub_1027(regB, 2*regB, "add")
    
    # reg2M = MultiPrecisionAddSub_1027(regM, regM , "add")
    reg3M = MultiPrecisionAddSub_1027(regM, 2*regM, "add")

    for i in range(0, 1024/WindowSize):
        
        # Decide the conditional addition with the lsb 2-bits of A
        if   (regA % b) == 0:  regC = regC;
        elif (regA % b) == 1:  regC = MultiPrecisionAddSub_1027(regC,   regB , "add")
        elif (regA % b) == 2:  regC = MultiPrecisionAddSub_1027(regC, 2*regB , "add")
        elif (regA % b) == 3:  regC = MultiPrecisionAddSub_1027(regC,   reg3B, "add")
        # Optionally, two additions can be performed to get rid of reg3B
        # elif (regA % b) == 3:  
        #     regC = MultiPrecisionAddSub_1027(regC,   regB, "add")
        #     regC = MultiPrecisionAddSub_1027(regC, 2*regB, "add")

        # Take the lsb 2-bits of C and M as select signals
        C_sel = (regC % b)
        M_sel = (regM % b)

        ModMuxOut = ModMux(regM, 2*regM,  reg3M, C_sel, M_sel)

        regC = MultiPrecisionAddSub_1027(regC, ModMuxOut, "add") / b
        # Optionally, two additions can be performed to get rid of reg3M

        regA = regA >> WindowSize
        
    while regC >= regM:
        regC = MultiPrecisionAddSub_1027(regC, regM, "sub")

    return regC


def MontExp(X, E, N):
    # Returns (X^E) mod N
    
    # R  = 2**1024
    # RN = R % N
    # R2N = (R*R) % N;
    # A  = RN;
    # X_tilde = MontMul(X,R2N,N)
    # t = helpers.bitlen(E)
    # for i in range(0,t):
    #     A = MontMul(A,A,N)
    #     if helpers.bit(E,t-i-1) == 1:
    #         A = MontMul(A,X_tilde,M)
    # A = MontMul(A,1,N)

    R  = 2**1024
    RN = R % N
    R2N = (R*R) % N;
    A  = RN;
    X_tilde = MontMul_2bW(X,R2N,N)
    t = helpers.bitlen(E)
    for i in range(0,t):
        A = MontMul_2bW(A,A,N)
        if helpers.bit(E,t-i-1) == 1:
            A = MontMul_2bW(A,X_tilde,N)
    A = MontMul_2bW(A,1,N)
    return A