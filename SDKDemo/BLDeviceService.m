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
#import "JSONKit.h"

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
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
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
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
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
//    NSData *devData = [NSJSONSerialization dataWithJSONObject:BLDeviceInfo.allkeys options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *devDataJsonString = [[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding];
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"set\", \"params\":[\"pwr\"], \"vals\":[[{\"val\":%d, \"idx\":1}]]}",status];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\",\"ltimeout\": 1500,\"rtimeout\": 12000}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        block(NO,dic);
    }
}

//插座定时get
- (void)dev_ctrltsk:(BLDeviceInfo *)BLDeviceInfo andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"get\", \"params\":[\"pertsk\"], \"vals\":[]}"];
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

//插座设置定时
- (void)dev_ctrlsetpertsk:(BLDeviceInfo *)BLDeviceInfo andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    __block NSString *cookie;
    [self dev_ctrltsk:BLDeviceInfo andBlock:^(BOOL ret, NSDictionary *dic) {
       cookie = dic[@"cookie"];
    }];
    //1
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
    //2
    NSString *val  =@"1|+0800-164530@165031|null|0|0";
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"set\", \"params\":[\"pertsk\"], \"vals\":[[{\"val\":\"%@\",\"idx\":1}]]}",val];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"%@\", \"netmode\":1, \"account_id\":\"%@\"}", cookie,ACCOUNT_ID];
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
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"get\", \"params\":[\"%@\"], \"vals\":[]}",params];
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

//RM进入学习模式
- (void)RMdev_ctrl:(BLDeviceInfo *)BLDeviceInfo params:(NSString *)params andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"set\", \"params\":[\"%@\"], \"vals\":[]}",params];
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

//RM查询学习到的码
- (void)RMdev_ctrlIrdaGet:(BLDeviceInfo *)BLDeviceInfo params:(NSString *)params andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"get\", \"params\":[\"%@\"], \"vals\":[]}",params];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\"}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        [self RMdev_ctrlIrdaGet:BLDeviceInfo params:params andBlock:^(BOOL ret, NSDictionary *dic) {
            block(YES,dic);
        }];
    }
}

//RM发射学习到的码
- (void)RMdev_ctrlIrdaSet:(BLDeviceInfo *)BLDeviceInfo params:(NSString *)params status:(NSString *)status andBlock:(void(^)(BOOL ret, NSDictionary *dic))block{
    //1
    NSString *devDataJsonString = [BLDeviceInfo.allkeys JSONString];
    //2
    NSString *dataJsonString = [NSString stringWithFormat:@"{\"act\":\"set\", \"params\":[\"%@\"], \"vals\":[[{\"val\":\"%@\", \"idx\":1}]]}",params,status];
    //3
    NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\"}", ACCOUNT_ID];
    //4
    NSDictionary *dic = [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
    if ([dic[@"status"]intValue] == 0) {
        block(YES,dic);
    }else{
        block(YES,dic);
    }
}

- (NSDictionary *)dnaControl:(NSString *)devInfo subdev:(NSString *)subdevInfo data:(NSString *)dataStr desc:(NSString *)descStr{
    NSString *result = [api dnaControl:devInfo subdev:subdevInfo data:dataStr desc:descStr];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    return dic;
}

@end
