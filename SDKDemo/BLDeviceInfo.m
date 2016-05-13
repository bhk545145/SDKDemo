//
//  BLDeviceInfo.m
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLDeviceInfo.h"

@implementation BLDeviceInfo

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        _did = dict[@"did"];
        _mac = dict[@"mac"];
        _type = [dict[@"type"]unsignedIntValue];
        _pid = dict[@"pid"];
        _name = dict[@"name"];
        _lock = [dict[@"lock"]boolValue];
        _newconfig = [dict[@"newconfig"]boolValue];
        _password = [dict[@"password"]unsignedIntValue];
        _lanaddr = dict[@"lanaddr"];
        _extend = dict[@"extend"];
        _allkeys = dict;
    }
    return self;
}

+(id)DeviceinfoWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

@end
