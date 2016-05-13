//
//  BLDeviceService.h
//  SDKDemo
//
//  Created by 白洪坤 on 16/5/5.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLDeviceInfo;
@interface BLDeviceService : NSObject
@property(nonatomic,assign)int onandoff;
/**
 *  设备名称修改
 *
 *  @param BLDeviceInfo  设备模型
 *  @param namefieldtext 设备名称
 *  @param block         返回结果
 */
- (void)dev_info:(BLDeviceInfo *)BLDeviceInfo namefieldtext:(NSString *)namefieldtext andBlock:(void(^)(BOOL ret, NSDictionary *dic))block;
/**
 *  插座开关状态
 *
 *  @param BLDeviceInfo 设备模型
 *  @param block        返回结果
 */
- (void)dev_ctrl:(BLDeviceInfo *)BLDeviceInfo andBlock:(void(^)(BOOL ret, NSDictionary *dic))block;
/**
 *  控制插座开关
 *
 *  @param BLDeviceInfo 设备模型
 *  @param status       开关参数
 *  @param block        返回结果
 */
- (void)dev_ctrlonoff:(BLDeviceInfo *)BLDeviceInfo status:(int)status andBlock:(void(^)(BOOL ret, NSDictionary *dic))block;
- (void)dev_ctrlget:(BLDeviceInfo *)BLDeviceInfo params:(NSString *)params andBlock:(void(^)(BOOL ret, NSDictionary *dic))block;
@end
