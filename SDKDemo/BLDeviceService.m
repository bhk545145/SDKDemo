//
//  BLDeviceService.m
//  SDKDemo
//
//  Created by 白洪坤 on 16/5/5.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLDeviceService.h"
#import "BLDeviceInfo.h"
#import "NetworkAPI.h"
#import "bhkcommon.h"
#import "BLDeviceService.h"

@interface BLDeviceService(){
    dispatch_queue_t networkQueue;
    NetworkAPI *api;
}

@end
@implementation BLDeviceService


- (id)init{
    if (self = [super init]) {
        api = [[NetworkAPI alloc]init];
        networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

//修改设备信息
- (void)dev_info:(BLDeviceInfo *)BLDeviceInfo namefieldtext:(NSString *)namefieldtext andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSData *devData = [NSJSONSerialization dataWithJSONObject:BLDeviceInfo.allkeys options:NSJSONWritingPrettyPrinted error:nil];
    NSString *devDataJsonString = [[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"data\":{\"name\":\"%@\",\"lock\":false}}",namefieldtext];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_info\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\"}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        block(NO,dic);
    }
}

//插座开关状态
- (void)dev_ctrl:(BLDeviceInfo *)BLDeviceInfo andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSData *devData = [NSJSONSerialization dataWithJSONObject:BLDeviceInfo.allkeys options:NSJSONWritingPrettyPrinted error:nil];
    NSString *devDataJsonString = [[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"prop\":\"stdctrl\",\"act\":\"get\", \"params\":[\"pwr\"], \"vals\":[]}"];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\"}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        block(NO,dic);
    }
    
}

//插座开关
- (void)dev_ctrlonoff:(BLDeviceInfo *)BLDeviceInfo status:(int)status andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSData *devData = [NSJSONSerialization dataWithJSONObject:BLDeviceInfo.allkeys options:NSJSONWritingPrettyPrinted error:nil];
    NSString *devDataJsonString = [[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"set\", \"params\":[\"pwr\"], \"vals\":[[{\"val\":%d, \"idx\":1}]]}",status];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":0, \"account_id\":\"%@\"}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        block(NO,dic);
    }
}

//插座get
- (void)dev_ctrlget:(BLDeviceInfo *)BLDeviceInfo params:(NSString *)params andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSData *devData = [NSJSONSerialization dataWithJSONObject:BLDeviceInfo.allkeys options:NSJSONWritingPrettyPrinted error:nil];
    NSString *devDataJsonString = [[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"get\", \"params\":[\"%@\"], \"vals\":[]}",params];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":0, \"account_id\":\"%@\"}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        block(NO,dic);
    }
}

//RM控制
- (void)RMdev_ctrl:(BLDeviceInfo *)BLDeviceInfo params:(NSString *)params andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSData *devData = [NSJSONSerialization dataWithJSONObject:BLDeviceInfo.allkeys options:NSJSONWritingPrettyPrinted error:nil];
    NSString *devDataJsonString = [[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"get\", \"params\":[\"%@\"], \"vals\":[]}",params];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":0, \"account_id\":\"%@\"}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        block(NO,dic);
    }
}

- (NSDictionary *)dnaControl:(NSString *)devInfo subdev:(NSString *)subdevInfo data:(NSString *)dataStr desc:(NSString *)descStr{
    NSString *result = [api dnaControl:devInfo subdev:subdevInfo data:dataStr desc:descStr];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    return dic;
}

@end
