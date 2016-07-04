//
//  SecurityUtil.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import "SecurityUtil.h"
#import "BLGTMBase64.h"
#import "NSData+AES.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>

#define APP_PUBLIC_PASSWORD     @"boundary"

@implementation SecurityUtil

#pragma mark - base64
+ (NSString*)encodeBase64String:(NSString * )input { 
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [BLGTMBase64 encodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]; 
	return base64String;
}

+ (NSString*)decodeBase64String:(NSString * )input { 
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [BLGTMBase64 decodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]; 
	return base64String;
} 

+ (NSString*)encodeBase64Data:(NSData *)data {
	data = [BLGTMBase64 encodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return base64String;
}

+ (NSString*)decodeBase64Data:(NSData *)data {
	data = [BLGTMBase64 decodeData:data]; 
    NSString *base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	return base64String;
}

+ (NSData*)decodeBase64StringTodata:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [BLGTMBase64 decodeData:data];
    return data;
}

#pragma mark - AES加密
//将string转成带密码的data
+(NSData*)encryptAESData:(NSString*)string {
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES256EncryptWithKey:APP_PUBLIC_PASSWORD];
    return encryptedData;
}

//将带密码的data转成string
+(NSString*)decryptAESData:(NSData*)data {
    //使用密码对data进行解密
    NSData *decryData = [data AES256DecryptWithKey:APP_PUBLIC_PASSWORD];
    //将解了密码的nsdata转化为nsstring
    NSString *string = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return [string autorelease];
}

+ (NSString *)AES128DecryptData:(NSData *)data WithKey:(uint8_t *)key iv:(uint8_t *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    memcpy(keyPtr, key, sizeof(keyPtr));
    //    [gkey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    memcpy(ivPtr, iv, sizeof(ivPtr));
    //    [gIv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    //    NSData *data = [BLGTMBase64 decodeData:self];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytes:buffer length:numBytesCrypted];
        free(buffer);
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}
+ (NSData *)AES128EncryptWithString:(NSString *)string key:(uint8_t *)key iv:(uint8_t *)iv
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    memcpy(keyPtr, key, sizeof(keyPtr));
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    memcpy(ivPtr, iv, sizeof(ivPtr));
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    }
    free(buffer);
    return nil;
}
+ (NSString *)AES128DecryptDataNOPadding:(NSData *)data WithKey:(uint8_t *)key iv:(uint8_t *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    memcpy(keyPtr, key, sizeof(keyPtr));

    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    memcpy(ivPtr, iv, sizeof(ivPtr));
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}
+ (NSData *)AES128EncryptWithStringNOPadding:(NSString *)string key:(uint8_t *)key iv:(uint8_t *)iv
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    memcpy(keyPtr, key, sizeof(keyPtr));
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    memcpy(ivPtr, iv, sizeof(ivPtr));
    
    int dataLength = (int)[data length];
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
    
    if(diff > 0)
    {
        newSize = dataLength + diff;
    }
    
    //add by guoyong 20150325
    if (newSize <= 0)
    {
        return nil;
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          0x0000, //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    
    if(cryptStatus == kCCSuccess)
    {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}
#pragma mark - MD5加密
/**
 *	@brief	对string进行md5加密
 *
 *	@param 	string 	未加密的字符串
 *
 *	@return	md5加密后的字符串
 */
+ (NSString*)encryptMD5String:(NSString*)string {
    return [string md5Encrypt];
}

+ (NSString*)encryptMD5Data:(NSData*)data {
    return [data md5Encrypt];
}

#define FileHashDefaultChunkSizeForReadingData 1024*8
+ (NSString *)encryptMD5File:(NSString *)filePath
{
    return (NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)filePath, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData)
{
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

+ (NSData *)encryptSHA1String:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (uint32_t)data.length, digest);
  
    return [NSData dataWithBytes:digest length:sizeof(digest)];
}

//add by guoyong 20141203 nsdata进行sha1加密
+ (NSData *)encryptSHA1Data:(NSData *)mydata
{
//    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(mydata.bytes, (uint32_t)mydata.length, digest);
    
    return [NSData dataWithBytes:digest length:sizeof(digest)];
}

//add by guoyong 20141009 nsstring转换为16进制字符串
+ (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
        {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else
        {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    
    return hexStr;
}

//add by guoyong 20141203 NSData转换为16进制字符串
+ (NSString *)hexStringFromData:(NSData *)myData
{
    Byte *bytes = (Byte *)[myData bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myData length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
        {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else
        {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    
    return hexStr;
}

//NSData转16进制字符串，另外写法
+ (NSString *)hexStringFromData1:(NSData *)myData
{
    Byte *bytes = (Byte *)[myData bytes];
    NSMutableString *hexStr = [[NSMutableString alloc] init];
    for(int i=0;i<[myData length];i++)
    {
        [hexStr appendFormat:@"%02x", bytes[i] & 0xff];
    }
    return hexStr;
}

@end
