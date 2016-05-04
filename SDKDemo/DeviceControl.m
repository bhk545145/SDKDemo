//
//  DeviceControl.m
//  SDKDemo
//
//  Created by 白洪坤 on 16/5/4.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "DeviceControl.h"
#import "BLDeviceInfo.h"
#import "NetworkAPI.h"
#import "bhkcommon.h"

@interface DeviceControl(){
    NetworkAPI *api;
    UITextField *namefield;
}

@end

@implementation DeviceControl

- (void)viewDidLoad {
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    self.view =view;
    api = [[NetworkAPI alloc]init];
}

- (void)setBLDeviceinfo:(BLDeviceInfo *)BLDeviceinfo{
    _BLDeviceinfo = BLDeviceinfo;
    UIButton *devinfobtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 80, 30, 30)];
    [devinfobtn setBackgroundImage:[UIImage imageNamed:@"58.png"] forState:UIControlStateNormal];
    [devinfobtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:devinfobtn];
    namefield = [[UITextField alloc]initWithFrame:CGRectMake(10, 80, 80, 30)];
    namefield.font = [UIFont fontWithName:@"Arial" size:14.0f];
    namefield.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:namefield];
    namefield.text = _BLDeviceinfo.name;
}

- (void)btnClick:(UIButton *)btn{
    [self dev_info];
}

//修改设备信息
- (void)dev_info{
    //1
    NSData *devData = [NSJSONSerialization dataWithJSONObject:_BLDeviceinfo.allkeys options:NSJSONWritingPrettyPrinted error:nil];
    NSString *devDataJsonString = [[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding];
    
    //2
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    [dic setObject:data forKey:@"data"];
    [data setObject:namefield.text forKey:@"name"];
    [data setObject:[NSNumber numberWithBool:false] forKey:@"lock"];
    NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataJsonString = [[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding];
    //NSString *dataJsonString = [NSString stringWithFormat:@"{\"data\":{\"name\":\"%@\",\"lock\":false}}",namefield.text];
    
    //3
    [dic setObject:@"dev_info" forKey:@"command"];
    [dic setObject:@"" forKey:@"cookie"];
    [dic setObject:[NSNumber numberWithInt:1] forKey:@"netmode"];
    [dic setObject:ACCOUNT_ID forKey:@"account_id"];
    descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *descJsonString = [[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding];
    //NSString *descJsonString = [NSString stringWithFormat:@"{\"command\":\"dev_info\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\"}", ACCOUNT_ID];
    
    //4
    [self dnaControl:devDataJsonString subdev:nil data:dataJsonString desc:descJsonString];
}

- (void)dnaControl:(NSString *)devInfo subdev:(NSString *)subdevInfo data:(NSString *)dataStr desc:(NSString *)descStr{
    NSString *result = [api dnaControl:devInfo subdev:subdevInfo data:dataStr desc:descStr];
    NSLog(@"%@",result);
}

@end
