//
//  DeviceTableViewController.m
//  SDKDemo
//
//  Created by 白洪坤 on 16/4/29.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "DeviceTableViewController.h"
#import "NetworkAPI.h"
#import "JSONKit.h"
#import "BLDeviceInfo.h"
#import "bhkcommon.h"
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "DeviceControl.h"

@interface DeviceTableViewController()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    dispatch_queue_t networkQueue;
    NetworkAPI *api;
    NSString *filepathFolder;
    UIAlertView *alert;
}
@property (nonatomic,strong) NSMutableArray *deviceArray;
@end

@implementation DeviceTableViewController

- (void)viewDidLoad {
    api = [[NetworkAPI alloc] init];
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    _deviceArray = [[NSMutableArray alloc]init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    [self deviceProbe];
}
//获取局域网信息
- (void)deviceProbe{
    dispatch_async(networkQueue, ^{
        NSString *requestData = [api deviceProbe:nil];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            NSLog(@"%@",requestData);
            NSArray *devicelist = [[responseData objectFromJSONData] objectForKey:@"list"];
            [self devicelist:devicelist];
        }else{
            NSLog(@"%@",requestData);
        }
    });
}

- (void)devicelist:(NSArray *)devicelist{
    int i;
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_deviceArray];
    for (NSDictionary *dic in devicelist) {
        BLDeviceInfo *info = [[BLDeviceInfo alloc]init];
        info = [BLDeviceInfo DeviceinfoWithDict:dic];        
       
        for (i=0; i<array.count; i++)
        {
            BLDeviceInfo *tmp = [array objectAtIndex:i];
            if ([tmp.mac isEqualToString:info.mac])
            {
                [array replaceObjectAtIndex:i withObject:info];
                break;
            }
        }
        
        if (i >= array.count)
        {
            [array addObject:info];
        }
        //设备绑定
        [self deviceBindWithServer:ACCOUNT_ID accountsession:ACCOUNT_SESSION name:USER_NAME phone:USER_PHONE email:USER_EMAIL devlist:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:info.did, @"did", info.pid, @"pid", nil], nil] desc:@"{}"];
    }
    
    [_deviceArray removeAllObjects];
    [_deviceArray addObjectsFromArray:array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.deviceArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    BLDeviceInfo *info = [[BLDeviceInfo alloc]init];
    info = _deviceArray[indexPath.row];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = info.mac;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BLDeviceInfo *info = [[BLDeviceInfo alloc]init];
    info = _deviceArray[indexPath.row];
    NSData *devData = [NSJSONSerialization dataWithJSONObject:info.allkeys options:NSJSONWritingPrettyPrinted error:nil];
    //设备配对
    [self devicePair:[[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding] desc:@"{}" info:info];
    alert = [[UIAlertView alloc]init];
    alert.tag = indexPath.row;
}
//刷新
- (IBAction)Refreshbtn:(id)sender {
    [self deviceProbe];
    [self.tableView reloadData];
}
//设备配对
- (void)devicePair:(NSString *)devInfo desc: (NSString *)descStr info:(BLDeviceInfo *)info{
    dispatch_async(networkQueue, ^{
        NSString *requestData = [api devicePair:devInfo desc:descStr];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            NSLog(@"%@",requestData);
            info.deviceid = [[responseData objectFromJSONData] objectForKey:@"id"];
            info.devicekey = [[responseData objectFromJSONData] objectForKey:@"key"];
            [info.allkeys setObject:info.deviceid forKey:@"id"];
            [info.allkeys setObject:info.devicekey forKey:@"key"];
            NSData *devData = [NSJSONSerialization dataWithJSONObject:info.allkeys options:NSJSONWritingPrettyPrinted error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                alert = [alert initWithTitle:@"产品信息展示" message:[[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert show];
            });
            //下载脚本
            [self deviceGetResourceToken:ACCOUNT_ID accountsession:ACCOUNT_SESSION productpid:info.pid resourcestype:@1 data:[NSDictionary dictionary] info:info];
        }else{
            NSLog(@"%@",requestData);
        }
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        DeviceControl *devicecontrol = [[DeviceControl alloc]init];
        BLDeviceInfo *info = _deviceArray[alertView.tag];
        devicecontrol.BLDeviceinfo = info;
        [self.navigationController pushViewController:devicecontrol animated:YES];
    }

}

//绑定设备
- (void)deviceBindWithServer: (NSString *)accountid accountsession:(NSString *)accountsession name:(NSString *)name phone:(NSString *)phone email:(NSString *)email devlist:(NSArray *)devlist desc: (NSString *)descStr{
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:accountid forKey:@"account_id"];
        [dic setObject:accountsession forKey:@"account_session"];
        [dic setObject:name forKey:@"name"];
        [dic setObject:phone forKey:@"phone"];
        [dic setObject:email forKey:@"email"];
        [dic setObject:devlist forKey:@"dev_list"];
        NSError *error;
        NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *requestData = [api deviceBindWithServer:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding] desc:descStr];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            NSLog(@"%@",requestData);
        }else{
            NSLog(@"%@",requestData);
        }
    });
}
//下载脚本
- (void)deviceGetResourceToken:(NSString *)accountid accountsession:(NSString *)accountsession productpid:(NSString *)productpid resourcestype:(NSNumber *)resourcestype data:(NSDictionary *)data info:(BLDeviceInfo *)info{
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:accountid forKey:@"account_id"];
        [dic setObject:accountsession forKey:@"account_session"];
        [dic setObject:productpid forKey:@"product_pid"];
        [dic setObject:resourcestype forKey:@"resources_type"];
        [dic setObject:data forKey:@"data"];
        NSError *error;
        NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *requestData = [api deviceGetResourcesToken:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding] desc:[NSString stringWithFormat:@"{\"account_id\":\"%@\"}", ACCOUNT_ID]];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            NSLog(@"%@",requestData);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *downloadUrl = [[[responseData objectFromJSONData]objectForKey:@"data"] objectForKey:@"url"];
                [self download:downloadUrl pid:productpid info:info];
            });
        }else{
            NSLog(@"%@",requestData);
        }
    });
}

- (void)download:(NSString *)downloadUrl pid:(NSString *)pid info:(BLDeviceInfo *)info
{
    time_t timestamp = time(NULL);
    NSString *sign = [self sha1:[NSString stringWithFormat:@"%@%ldbroadlinkDNA@", downloadUrl, timestamp]];
    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:@"download", @"action", @"script", @"type", pid,@"pid",[NSDictionary dictionaryWithObject:@"bl" forKey:@"platform"], @"extrainfo", nil];
    NSMutableData *bodydata = [NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    [request setRequestMethod:@"POST"];
    [request setAuthenticationScheme:@"https"];
    [request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"timestamp" value:[NSString stringWithFormat:@"%ld", timestamp]];
    [request addRequestHeader:@"sign" value:sign];
    [request setPostBody:bodydata];
    [request startAsynchronous];
    __block ASIHTTPRequest *reqblock = request;
    [request setCompletionBlock:^{
        if (reqblock.responseStatusCode == 200)
        {
            NSString *filepath = [filepathFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.script", pid]];
            NSLog(@"filepath: %@", filepath);
            if ([reqblock.responseData writeToFile:filepath atomically:YES])
            {
                //获取设备的 profile 信息
                [info.allkeys setObject:info.deviceid forKey:@"id"];
                [info.allkeys setObject:info.devicekey forKey:@"key"];
                [self deviceProfile:info.allkeys subdev:nil desc:@"{}"];
            }
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"Download fail: %d", reqblock.responseStatusCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
    [request setFailedBlock:^{
        [[[UIAlertView alloc] initWithTitle:@"error" message:@"Download fail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (NSString *)sha1:(NSString *)str
{
    int i;
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [[NSMutableString alloc] initWithCapacity:CC_SHA1_DIGEST_LENGTH];
    for (i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

//获取设备的 profile 信息
- (void)deviceProfile:(NSDictionary *)dic subdev:(NSString *)subdevInfo desc:(NSString *)descStr{
    dispatch_async(networkQueue, ^{
        NSData *devData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *devProfileResult = [api deviceProfile:[[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding] subdev:subdevInfo desc:descStr];
        NSDictionary *devProfileDic = [NSJSONSerialization JSONObjectWithData:[devProfileResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary *selectDevProfile = devProfileDic[@"profile"];
        NSLog(@"%@",selectDevProfile);
    });
}

- (void)dnaControl:(NSString *)devInfo subdev:(NSString *)subdevInfo data:(NSString *)dataStr desc:(NSString *)descStr{
    NSString *result = [api dnaControl:devInfo subdev:subdevInfo data:dataStr desc:descStr];
    NSLog(@"%@",result);
}
@end
