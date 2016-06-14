//
//  bhkcommon.h
//  SDKDemo
//
//  Created by 白洪坤 on 16/4/26.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#ifndef bhkcommon_h
#define bhkcommon_h

#define OWNER_LICENSE       @"j2Z8lGo4H5QyY9QuLIvaArpJilB4niPX0VJ3/yJmg2uz9VLe0/3NG4ijLTtsr6cXvuoNVwAAAAC34dCX0yp96VBPcuFLL7wGcGROQUnBoZ+yWte4wQP2QBAiWsIC7HOxWMc5DPTJ6KB+CwHvkzI2xdh4hc7UtXUGsEkbxXTfoUSQjDzWcfVjcA4AAADyki8iea7A5SRnXUE3S9qWgOmS8UyHs5pISopUO3fLlWUU/3Xu40C//cc6tVOyI8bjRa8g9o3HM62zOdPHgG6/"

//#define WIFI_SSID           @"WCWCWC"
//#define WIFI_PWD            @""
#define WIFI_GATEWAY        @"192.168.9.1"

#define USER_NAME           @"yzm157"
#define USER_PHONE          @"18011112222"
#define USER_EMAIL          @"yzm157@broadlink.com.cn"
#define ACCOUNT_ID          @"yzm157"
#define ACCOUNT_SESSION     @"yzm157.broadlink.com.cn"


#pragma mark -
#pragma mark - log信息函数预定义
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


// 设备代号
#define SPmini 10016
#define SPminiv2 10024
#define SP2 10001
#define RM 10002
#define A1 10004
#define MS1 10015
#define S1 10018
#define RMplus 10026
#define RM3mini  10039

// 获得RGB颜色
#define IWColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#endif /* bhkcommon_h */
