//
//  NSData+MD5.m
//  e-Control
//
//  Created by milliwave-Zs on 15/4/11.
//  Copyright (c) 2015年 BroadLink. All rights reserved.
//

#import "NSData+MD5.h"

@implementation NSData (md5)
- (NSString *)md5Encrypt 
{
    unsigned char result[16];
    CC_MD5( self.bytes, (uint32_t)self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end