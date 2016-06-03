//
//  NetworkAPI.h
//  NetworkAPI
//
//  Created by yzm157 on 15/7/15.
//  Copyright (c) 2015年 Broadlink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkAPI : NSObject

- (NSString *)LicenseInfo:(NSString *)license;

- (NSString *)SDKInit:(NSString *)descStr;

- (NSString *)SDKAuth:(NSString *)descStr;

- (NSString *)deviceBindWithServer:(NSString *)dataStr desc:(NSString *)descStr;

- (NSString *)deviceEasyConfig:(NSString *)descStr;

- (NSString *)deviceEasyConfigCancel;

- (NSString *)deviceGetAPList:(NSString *)descStr;

- (NSString *)deviceAPConfig:(NSString *)descStr;

- (NSString *)deviceProbe:(NSString *)descStr;

- (NSString *)deviceGetResourcesToken:(NSString *)dataStr desc:(NSString *)descStr;

- (NSString *)devicePair:(NSString *)devInfo desc:(NSString *)descStr;

- (NSString *)deviceProfile:(NSString *)devInfo subdev:(NSString *)subdevInfo desc:(NSString *)descStr;

- (NSString *)deviceProfile2:(NSString *)pidStr desc:(NSString *)descStr;

- (NSString *)dnaControl:(NSString *)devInfo subdev:(NSString *)subdevInfo data:(NSString *)dataStr desc:(NSString *)descStr;

@end
