#include <stdint.h>                                              
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 2018.2                    
//                                                               
//  The variables are defined for the RSA                        
// encryption and decryption operations. And they are assigned   
// by the script for the generated testvector. Do not create a   
// new variable in this file.                                    
//                                                               
// When you are submitting your results, be careful to verify    
// the test vectors created for seeds from 2018.1, to 2018.5     
// To create them, run your script as:                           
//   $ python testvectors.py rsa 2018.1                          
                                                                 
// modulus                                                       
uint32_t N[32]       = {0x8e72ac99, 0xa3aaedf7, 0x70c0abc5, 0xd36b62d6, 0x1e377ed9, 0xabe06740, 0xa390f567, 0x49c9b720, 0xa1e3158e, 0xcc7a8f07, 0xd9bec93d, 0x0fce9e40, 0x9c20e38d, 0x2ff36702, 0x2841800d, 0xef9c27dc, 0x12042b2c, 0xa3e78727, 0xc0fbee47, 0xb84ee44a, 0x498a39fd, 0x3655ec68, 0x9b780f4b, 0xe7b863b7, 0xf3e614be, 0x19526e38, 0x32a9d003, 0x1744eb70, 0xeaabeb1f, 0x4bdb114d, 0xced977dd, 0xcddba959};           
                                                                 
// encryption exponent                                           
uint32_t e[32]       = {0x0000cfb5};            
uint32_t e_len       = 16;                                       
                                                                 
// decryption exponent, reduced to p and q                       
uint32_t d[32]       = {0xc71113dd, 0xaed3053e, 0x73fb52fd, 0x89178107, 0x57608b4e, 0x6f532399, 0x9a7621ec, 0x6094e844, 0x109261fe, 0x0f2eb079, 0xada4cf34, 0xd2f17c58, 0xfc63b5bc, 0x9e7ed57e, 0xbce17827, 0xebea19b3, 0x3a3d73bf, 0x31abddd3, 0xa7df608e, 0x9f59bf97, 0x548484ce, 0xf7da02ef, 0x701fc921, 0x9788eb1c, 0x4ff6f424, 0x2f2093a5, 0xe5612312, 0xce671712, 0xc2c4b651, 0xf3426ef5, 0xf0639ae7, 0x1474f66b};           
uint32_t d_len       =  1021;    
                                                                 
// the message                                                   
uint32_t M[32]       = {0x8fc29643, 0x8c45480a, 0x9c8ebed0, 0x0594133d, 0xddba6664, 0xef76b462, 0x052b1e5f, 0x10346fe8, 0x0602e1e2, 0x4edf0a11, 0x9e4bb03d, 0x29912161, 0xdbfffe2c, 0x45ed2cad, 0x048db198, 0xf646811a, 0x736d1fbe, 0xb21dfd42, 0x83ec849e, 0x5f1bce98, 0x96fb772a, 0xd7de3517, 0xd44abc1d, 0xb9c2bf4c, 0xb14868d7, 0xc0562aea, 0xf69ba521, 0x188261d4, 0x7f342670, 0x6ec33088, 0x2472f6ba, 0x8d8297ae};           
                                                                 
// R mod N, and R^2 mod N, (R = 2^1024)                          
uint32_t R_N[32]     = {0x718d5367, 0x5c551208, 0x8f3f543a, 0x2c949d29, 0xe1c88126, 0x541f98bf, 0x5c6f0a98, 0xb63648df, 0x5e1cea71, 0x338570f8, 0x264136c2, 0xf03161bf, 0x63df1c72, 0xd00c98fd, 0xd7be7ff2, 0x1063d823, 0xedfbd4d3, 0x5c1878d8, 0x3f0411b8, 0x47b11bb5, 0xb675c602, 0xc9aa1397, 0x6487f0b4, 0x18479c48, 0x0c19eb41, 0xe6ad91c7, 0xcd562ffc, 0xe8bb148f, 0x155414e0, 0xb424eeb2, 0x31268822, 0x322456a6};        
uint32_t R2_N[32]    = {0xbdcd9707, 0x1acc7901, 0x139e1dfa, 0x8dbcf2ec, 0x7d2f9f19, 0xb8db3011, 0xbc46cefc, 0x312db89a, 0x55714cdd, 0x8e3e86ef, 0x13ff24b6, 0x7b09294c, 0xac9df4fa, 0x74053eb5, 0x23536af3, 0xe2c3728d, 0x5f74edde, 0x8cdd3043, 0x86709dfa, 0x1d386cfe, 0x19026b31, 0x7e963d6a, 0x507779d5, 0xc43a771f, 0x2321379e, 0x1e6ae11c, 0xba36f41c, 0xaab4cc31, 0x3c7342ad, 0x0678bddd, 0xba9aa363, 0xad0bb962};        
