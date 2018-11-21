#include <stdint.h>                                              
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = random                    
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
uint32_t N[32]       = {0x8c9d096b, 0x0a3a596e, 0x6076f044, 0x40cfde4e, 0xe017ed16, 0x13c461e4, 0xa6cf0cf3, 0xc64333ca, 0x48a79a66, 0xc45f6440, 0xe8312392, 0x5e135748, 0xfec2f34a, 0xf48b44d5, 0xe0548ca5, 0x3c2d4832, 0x4080e42a, 0xaf8fcad4, 0xd95e18c6, 0xa05504fe, 0x80621814, 0x7a454d35, 0xc5da383b, 0x23749d2a, 0xf9f25cfb, 0xb0a6b6fa, 0x00e33f3b, 0x2fe3483e, 0xc068d925, 0x932698b1, 0x9ac67cf3, 0xd6caa56f};           
                                                                 
// encryption exponent                                           
uint32_t e[32]       = {0x0000f209};            
uint32_t e_len       = 16;                                       
                                                                 
// decryption exponent, reduced to p and q                       
uint32_t d[32]       = {0x13acc649, 0x8e376914, 0x74fc4345, 0x0383a7fd, 0x68591f87, 0x38e63f91, 0xfc6651b0, 0x1108bb0e, 0x651ef80b, 0x8811685e, 0xe4b8da7b, 0x7595f951, 0xe7d4a44f, 0x5221520a, 0x39bfec36, 0xb0261ff0, 0xfad13f8e, 0x53babb8f, 0xbf18c516, 0x7d2850fd, 0x5574fdcf, 0x2b8d1895, 0x75524712, 0x6db0819a, 0x15dfd340, 0xe1efcea3, 0xf30008a7, 0x27601cfa, 0xe1070321, 0xbaa72121, 0x10984531, 0x5a8ccf6f};           
uint32_t d_len       =  1023;    
                                                                 
// the message                                                   
uint32_t M[32]       = {0x7a884221, 0x8649697d, 0x08e1b39e, 0x1fffb07f, 0x05133c76, 0x0d86e969, 0xaa85c772, 0x3ba7ca66, 0x3c4384f2, 0x569fb01e, 0xca9980ea, 0x25a4de17, 0x2040a7a0, 0x229f7454, 0x8e6681c3, 0xf46405c2, 0xdb5dd43c, 0x723676ee, 0xaa5a032d, 0x5fed827b, 0xc3df998b, 0x71538811, 0x39026a23, 0xbc97ffdc, 0x83ea4414, 0x16396f5d, 0xe29b81ba, 0x91dbeba9, 0x247296b3, 0xe4e64e8f, 0x77636f9e, 0xa3935ce1};           
                                                                 
// R mod N, and R^2 mod N, (R = 2^1024)                          
uint32_t R_N[32]     = {0x7362f695, 0xf5c5a691, 0x9f890fbb, 0xbf3021b1, 0x1fe812e9, 0xec3b9e1b, 0x5930f30c, 0x39bccc35, 0xb7586599, 0x3ba09bbf, 0x17cedc6d, 0xa1eca8b7, 0x013d0cb5, 0x0b74bb2a, 0x1fab735a, 0xc3d2b7cd, 0xbf7f1bd5, 0x5070352b, 0x26a1e739, 0x5faafb01, 0x7f9de7eb, 0x85bab2ca, 0x3a25c7c4, 0xdc8b62d5, 0x060da304, 0x4f594905, 0xff1cc0c4, 0xd01cb7c1, 0x3f9726da, 0x6cd9674e, 0x6539830c, 0x29355a90};        
uint32_t R2_N[32]    = {0xe14a3049, 0x447fe6d8, 0x0f456964, 0x28409624, 0xb847decb, 0xb4eda146, 0x97f5cb1a, 0xfc503228, 0xd5386a43, 0x4f571f7e, 0xd696870f, 0x5a36c8e0, 0x8dfaa74c, 0x73d9ea4e, 0x8a19b627, 0xe1c77105, 0x4d3d1914, 0x7a612152, 0xdf631a50, 0xbba05826, 0xef4f9c32, 0xe49ec9c2, 0x58878212, 0xc83e99b3, 0xd159463d, 0xa8c42e64, 0x23ec8692, 0xb9acc20c, 0x22cc7f79, 0xf34d6b3b, 0x7992baeb, 0xb243e11d};        
