//
//  NSData+MD5.h
//  e-Control
//
//  Created by milliwave-Zs on 15/4/11.
//  Copyright (c) 2015年 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSData (MD5)

- (NSString *)md5Encrypt;

@end

