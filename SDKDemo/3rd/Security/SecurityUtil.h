//
//  SecurityUtil.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityUtil : NSObject 

#pragma mark - base64
+ (NSString*)encodeBase64String:(NSString *)input;
+ (NSString*)decodeBase64String:(NSString *)input;
+ (NSString*)encodeBase64Data:(NSData *)data;
+ (NSString*)decodeBase64Data:(NSData *)data;
+ (NSData*)decodeBase64StringTodata:(NSString *)input;

#pragma mark - AES加密
//将string转成带密码的data
+ (NSData*)encryptAESData:(NSString*)string;
//将带密码的data转成string
+ (NSString*)decryptAESData:(NSData*)data;

+ (NSString *)AES128DecryptData:(NSData *)data WithKey:(uint8_t *)key iv:(uint8_t *)iv; //CBC 128bit 解密
+ (NSData *)AES128EncryptWithString:(NSString *)string key:(uint8_t *)key iv:(uint8_t *)iv; //CBC 128bit 加密
+ (NSData *)AES128EncryptWithStringNOPadding:(NSString *)string key:(uint8_t *)key iv:(uint8_t *)iv;
+ (NSString *)AES128DecryptDataNOPadding:(NSData *)data WithKey:(uint8_t *)key iv:(uint8_t *)iv;

#pragma mark - MD5加密
/**
 *	@brief	对string进行md5加密
 *
 *	@param 	string 	未加密的字符串
 *
 *	@return	md5加密后的字符串
 */
+ (NSString*)encryptMD5String:(NSString*)string;

+ (NSString*)encryptMD5File:(NSString *)filePath;

+ (NSString*)encryptMD5Data:(NSData*)data ;

#pragma makr - SHA1加密
+ (NSData *)encryptSHA1String:(NSString *)string;

//nsdata进行sha1加密
+ (NSData *)encryptSHA1Data:(NSData *)mydata;

//nstring 转换为十六进制字符串
+ (NSString *)hexStringFromString:(NSString *)string;

//NSData转换为16进制字符串
+ (NSString *)hexStringFromData:(NSData *)myData;

//NSData转16进制字符串，另外写法
+ (NSString *)hexStringFromData1:(NSData *)myData;

@end
