#include <stdint.h>                                              
                                                                 
// This file's content is created by the testvector generator    
// python script for seed = 2018.1                    
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
uint32_t N[32]       = {0x37a32859, 0xfe8e590c, 0x3ce41b69, 0x98995d53, 0xf0cd6ead, 0xb226ee57, 0xe2994493, 0xda854ec1, 0x2dcd7091, 0x7411d85c, 0x467bcd09, 0xdc21b5d2, 0xdba82236, 0xdb42cbd7, 0xd1246ef5, 0xc51b32a4, 0xf4fbf212, 0x97d5b36d, 0xd273160c, 0x0e555ba7, 0x7bad7b39, 0xa4623e5f, 0xf696a1ef, 0x304b50b9, 0x0a7d0913, 0x4a461061, 0xc27aaff5, 0xe5cacff8, 0xe256d9ea, 0xe92378ff, 0x226515d0, 0xfa4e7b51};           
                                                                 
// encryption exponent                                           
uint32_t e[32]       = {0x0000db6b};            
uint32_t e_len       = 16;                                       
                                                                 
// decryption exponent, reduced to p and q                       
uint32_t d[32]       = {0x1af386c3, 0x41b48900, 0x7e58ca7d, 0xcc4a07fd, 0x1c78b4a1, 0x83063c6b, 0x81f93b86, 0xa891a667, 0x65f0dd50, 0x4bfd9813, 0xc7170d14, 0x123ea753, 0x9f243b05, 0x297971a7, 0x2e288f95, 0x9e1b6218, 0x9dac542a, 0xe08e1cf9, 0xbbcd5aba, 0xffdd2744, 0x9b221e44, 0x23e1a142, 0x1df29f51, 0x88465fb0, 0xd9354673, 0x82c6cc76, 0xdbb16d57, 0x35e9f805, 0xf179c8c6, 0x95bc1b8c, 0x8cfd5e5c, 0x5dafa833};           
uint32_t d_len       =  1023;    
                                                                 
// the message                                                   
uint32_t M[32]       = {0xdb13e82c, 0x46d2a369, 0x2c465cc2, 0xc2b08899, 0xdfccfd8c, 0xc373961f, 0x8c0113fc, 0xdbc652d0, 0xa5830b3f, 0x5ca3c278, 0xa5a1dc71, 0x90f402a3, 0x9e1f2eb3, 0xc03a30ce, 0x1fa295a9, 0x8eace414, 0x63365114, 0x408dd53d, 0x47015c5e, 0x8de4da11, 0x66403759, 0x2364fad4, 0xc5b55350, 0xcea64825, 0xc8f784c5, 0x5c1fd7c0, 0x2bbb7d35, 0xde4f85cb, 0x03919d69, 0x7799f4d8, 0x49fc1f3c, 0xa4260ac6};           
                                                                 
// R mod N, and R^2 mod N, (R = 2^1024)                          
uint32_t R_N[32]     = {0xc85cd7a7, 0x0171a6f3, 0xc31be496, 0x6766a2ac, 0x0f329152, 0x4dd911a8, 0x1d66bb6c, 0x257ab13e, 0xd2328f6e, 0x8bee27a3, 0xb98432f6, 0x23de4a2d, 0x2457ddc9, 0x24bd3428, 0x2edb910a, 0x3ae4cd5b, 0x0b040ded, 0x682a4c92, 0x2d8ce9f3, 0xf1aaa458, 0x845284c6, 0x5b9dc1a0, 0x09695e10, 0xcfb4af46, 0xf582f6ec, 0xb5b9ef9e, 0x3d85500a, 0x1a353007, 0x1da92615, 0x16dc8700, 0xdd9aea2f, 0x05b184ae};        
uint32_t R2_N[32]    = {0x4af2cd17, 0xe7b54a3e, 0x2c54bec3, 0x013d01e0, 0x3e0e4800, 0xa01a4642, 0xa37c5c82, 0xb18ad7cf, 0x76dfc526, 0x4455a806, 0x754e2873, 0x62324c23, 0x206e9511, 0x59838d3d, 0x6327ce8d, 0xcc6592bc, 0xd86e6604, 0x58b2ed62, 0x334d4702, 0x198b924b, 0x004d38b3, 0xd87e5a1f, 0xb1e8ae65, 0x95df9c72, 0x4750ab93, 0x9e519b81, 0x8d061be8, 0x70223f74, 0x281a5ac7, 0xd4ee25da, 0x1affa796, 0x610654ea};        