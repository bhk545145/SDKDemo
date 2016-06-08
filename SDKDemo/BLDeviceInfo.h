//
//  BLDeviceInfo.h
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLDeviceInfo : NSObject

@property (nonatomic, strong) NSString *did;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL lock;
@property (nonatomic, assign) BOOL newconfig;
@property (nonatomic, assign) int password;
@property (nonatomic, assign) NSString *lanaddr;
@property (nonatomic, strong) NSObject *extend;
@property (nonatomic, strong) NSString *deviceid;
@property (nonatomic, strong) NSString *devicekey;
@property (nonatomic, strong) NSString *downloadurl;
@property (nonatomic, strong) NSMutableDictionary *allkeys;

- (id)initWithDict:(NSDictionary *)dict;
+ (id)DeviceinfoWithDict:(NSDictionary *)dict;
@end
