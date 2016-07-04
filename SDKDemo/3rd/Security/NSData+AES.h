//
//  NSData+AES.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
@class NSString;

@interface NSData (Encryption)

- (NSData *)AES256EncryptWithKey:(NSString *)key;   //加密
- (NSData *)AES256DecryptWithKey:(NSString *)key;   //解密

- (NSString *)AES128DecryptWithKey1:(uint8_t *)key iv:(uint8_t *)iv; //CBC 128bit 解密
- (NSData *)AES128EncryptWithkey:(uint8_t *)key iv:(uint8_t *)iv; //CBC 128bit 加密
@end
