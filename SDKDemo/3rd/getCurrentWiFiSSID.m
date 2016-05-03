//
//  getCurrentWiFiSSID.m
//  bhkreader
//
//  Created by bai on 15/11/27.
//  Copyright © 2015年 bai. All rights reserved.
//

#import "getCurrentWiFiSSID.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation getCurrentWiFiSSID
/*获取当前连接的wifi网络名称，如果未连接，则为nil*/
- (NSString *)getCurrentWiFiSSID
{
    CFArrayRef ifs = CNCopySupportedInterfaces();       //得到支持的网络接口 eg. "en0", "en1"
    
    if (ifs == NULL)
        return nil;
    
    CFDictionaryRef info = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(ifs, 0));
    
    CFRelease(ifs);
    
    if (info == NULL)
        return nil;
    
    NSDictionary *dic = (__bridge_transfer NSDictionary *)info;
    
    // If ssid is not exist.
    if ([dic isEqual:nil])
        return nil;
    
    NSString *ssid = [dic objectForKey:@"SSID"];
    
    return ssid;
}
@end
