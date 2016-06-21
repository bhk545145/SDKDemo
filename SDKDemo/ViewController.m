//
//  ViewController.m
//  SDKDemo
//
//  Created by yzm157 on 15/10/16.
//  Copyright © 2015年 BroadLink Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "NetworkAPI.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "JSONKit.h"
#import "getCurrentWiFiSSID.h"
#import "MBProgressHUD+MJ.h"
#import "bhkcommon.h"
#import "BLDeviceService.h"

@interface ViewController () <UIAlertViewDelegate,UITextFieldDelegate>
{
    dispatch_queue_t networkQueue;
    NetworkAPI *api;
    NSString *filepathFolder;
    NSMutableArray *deviceList;
    NSMutableDictionary *selectDev;
    NSDictionary *selectDevProfile;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    api = [[NetworkAPI alloc] init];
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    
    getCurrentWiFiSSID *ssid = [[getCurrentWiFiSSID alloc]init];
    self.ssid.text = [ssid getCurrentWiFiSSID];
    self.accountid.delegate = self;
    self.accountsession.delegate = self;
    self.ssid.delegate = self;
    self.password.delegate = self;
    [self SDKInit:nil];
    [self SDKAuth:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.accountid resignFirstResponder];
    [self.accountsession resignFirstResponder];
    [self.ssid resignFirstResponder];
    [self.password resignFirstResponder];
    return YES;
}

- (void)SDKInit:(NSString *)filepath localctrl:(NSNumber *)localctrl loglevel:(NSNumber *)loglevel{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:filepath forKey:@"filepath"];
        [dic setObject:localctrl forKey:@"localctrl"];
        [dic setObject:loglevel forKey:@"loglevel"];
        NSError *error;
        NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *requestData = [api SDKInit:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding]];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }else{
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }
    });
}

- (void)SDKAuth:(NSString *)license accountid:(NSString *)accountid accountsession:(NSString *)accountsession{
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:license forKey:@"license"];
        [dic setObject:accountid forKey:@"account_id"];
        [dic setObject:accountsession forKey:@"account_session"];
        NSError *error;
        NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *requestData = [api SDKAuth:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding]];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }else{
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }
    });
    
}

- (void)deviceEasyConfigssid:(NSString *)ssid password:(NSString *)password wifigateway:(NSString *)wifigateway{
    UIView *progressview = [[UIView alloc]initWithFrame:CGRectMake(180, 100, 200, 100)];
    [self.view addSubview:progressview];
    MBProgressHUD *hub = [MBProgressHUD showMessage:@"正在配置中" toView:progressview];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:ssid forKey:@"ssid"];
    [dic setObject:password forKey:@"password"];
    [dic setObject:wifigateway forKey:@"gatewayaddr"];
    NSError *error;
    NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    dispatch_async(networkQueue, ^{
        NSString *requestData = [api deviceEasyConfig:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding]];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hub hide:YES];
                [MBProgressHUD showSuccess:@"配置成功" toView:progressview];
            });
        }else{
            DLog(@"%@",requestData);
            dispatch_async(dispatch_get_main_queue(), ^{
                [hub hide:YES];
                [MBProgressHUD showSuccess:@"配置失败" toView:progressview];
            });
        }
    });
}

- (void)deviceEasyConfigCancel{
    dispatch_async(networkQueue, ^{
        NSString *requestData = [api deviceEasyConfigCancel];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }else{
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }
    });
}

- (void)deviceProbe{
    dispatch_async(networkQueue, ^{
        NSDictionary *dic = @{
                              @"scantime"      : @3000,
                              @"scaninterval"  : @150
                              
                              };
        NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *requestData = [api deviceProbe:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding]];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
            deviceList = [[responseData objectFromJSONData] objectForKey:@"list"];
        }else{
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }
    });
}

- (void)devicePair:(NSString *)devInfo desc: (NSString *)descStr{
    dispatch_async(networkQueue, ^{
        NSString *requestData = [api devicePair:devInfo desc:descStr];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
            id did = [[responseData objectFromJSONData] objectForKey:@"id"];
            id key = [[responseData objectFromJSONData] objectForKey:@"key"];
            [selectDev setObject:did forKey:@"id"];
            [selectDev setObject:key forKey:@"key"];
            [deviceList setValue:did forKey:@"id"];
            [deviceList setValue:key forKey:@"key"];
        }else{
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }
    });
}

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
            DLog(@"%@-----%@",requestData,devlist);
            [self NSlogNSdata:responseData];
        }else{
            DLog(@"%@-----%@",requestData,devlist);
            [self NSlogNSdata:responseData];
        }
    });
}

- (void)deviceGetResourceToken:(NSString *)accountid accountsession:(NSString *)accountsession productpid:(NSString *)productpid resourcestype:(NSNumber *)resourcestype data:(NSDictionary *)data{
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:accountid forKey:@"account_id"];
        [dic setObject:accountsession forKey:@"account_session"];
        [dic setObject:productpid forKey:@"product_pid"];
        [dic setObject:resourcestype forKey:@"resources_type"];
        [dic setObject:data forKey:@"data"];
        NSError *error;
        NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *requestData = [api deviceGetResourcesToken:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding] desc:[NSString stringWithFormat:@"{\"account_id\":\"%@\"}", self.accountid.text]];
        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *downloadUrl = [[[responseData objectFromJSONData]objectForKey:@"data"] objectForKey:@"url"];
                [self download:downloadUrl pid:productpid];
            });
        }else{
            DLog(@"%@",requestData);
            [self NSlogNSdata:responseData];
        }
    });
}

- (void)deviceProfile:(NSDictionary *)dic subdev:(NSString *)subdevInfo desc:(NSString *)descStr{
    dispatch_async(networkQueue, ^{
        NSData *devData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *devProfileResult = [api deviceProfile:[[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding] subdev:subdevInfo desc:descStr];
        DLog(@"devProfileResult: %@", devProfileResult);
        NSDictionary *devProfileDic = [NSJSONSerialization JSONObjectWithData:[devProfileResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        selectDevProfile = devProfileDic[@"profile"];
        DLog(@"profile: %@", selectDevProfile);
        [self NSlogNSString:devProfileResult];
    });
}

- (void)dnaControl{
    
}

- (IBAction)SDKInit:(UIButton *)sender {
    [self SDKInit:filepathFolder localctrl:[NSNumber numberWithBool:false] loglevel:[NSNumber numberWithInt:0]];
}

- (IBAction)SDKAuth:(UIButton *)sender {
    [self SDKAuth:OWNER_LICENSE accountid:self.accountid.text accountsession:self.accountsession.text];
}

- (IBAction)deviceEasyConfig:(UIButton *)sender {
    [self deviceEasyConfigssid:self.ssid.text password:self.password.text wifigateway:WIFI_GATEWAY];
}

- (IBAction)deviceEasyConfigCancel:(UIButton *)sender {
    [self deviceEasyConfigCancel];
}

- (IBAction)deviceProbe:(UIButton *)sender {
    [self deviceProbe];
}

- (IBAction)devicePair:(UIButton *)sender {
    if (deviceList.count <= 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"error" message:@"have no device found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    for (NSMutableDictionary *dic in deviceList) {
        NSData *devData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [self devicePair:[[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding] desc:@"{}"];
        selectDev = [[NSMutableDictionary alloc] initWithDictionary:dic];
    }
}

- (IBAction)deviceBindWithServer:(UIButton *)sender {
    if (selectDev == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"error" message:@"have no selected device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    for (NSDictionary *dic in deviceList) {
        [self deviceBindWithServer:self.accountid.text accountsession:self.accountsession.text name:USER_NAME phone:USER_PHONE email:USER_EMAIL devlist:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:dic[@"did"], @"did", dic[@"pid"], @"pid", nil], nil] desc:@"{}"];
    }
}

- (IBAction)deviceGetResourceToken:(UIButton *)sender {
    
    if (selectDev == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"error" message:@"have no selected device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    for (NSDictionary *dic in deviceList) {
        [self deviceGetResourceToken:self.accountid.text accountsession:self.accountsession.text productpid:dic[@"pid"] resourcestype:@1 data:[NSDictionary dictionary]];
    }
}

- (IBAction)deviceProfile:(UIButton *)sender {
    if (selectDev == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"error" message:@"have no selected device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    for (NSDictionary *dic in deviceList) {
        [self deviceProfile:dic subdev:nil desc:@"{}"];
    }
}

- (IBAction)dnaControl:(UIButton *)sender {
    if (selectDev == nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"error" message:@"have no selected device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *devData = [NSJSONSerialization dataWithJSONObject:selectDev options:NSJSONWritingPrettyPrinted error:nil];
        NSString *dnaControlResult = [api dnaControl:[[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding] subdev:nil data:@"{\"data\":\"BgAAAA==\"}" desc:[NSString stringWithFormat:@"{\"command\":\"dev_passthrough\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\"}", self.accountid.text]];
        NSString *dnadev_ctrlResult = [api dnaControl:[[NSString alloc] initWithData:devData encoding:NSUTF8StringEncoding] subdev:nil data:@"{\"act\":\"set\", \"params\":[\"pwr\"], \"vals\":[[{\"val\":1, \"idx\":1}]]}" desc:[NSString stringWithFormat:@"{\"command\":\"dev_ctrl\", \"cookie\":\"\", \"netmode\":1, \"account_id\":\"%@\"}", self.accountid.text]];
        DLog(@"dnaControlResult: %@", dnaControlResult);
        DLog(@"dnadev_ctrlResult: %@", dnadev_ctrlResult);
        [self NSlogNSString:dnaControlResult];
    });
    
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

- (void)download:(NSString *)downloadUrl pid:(NSString *)pid
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
            DLog(@"%@",[reqblock.responseData objectFromJSONData]);
            NSString *filepath = [filepathFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.script", pid]];
            DLog(@"filepath: %@", filepath);
            if ([reqblock.responseData writeToFile:filepath atomically:YES])
            {
                
                DLog(@"success");
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

- (void)NSlogNSdata:(NSData *)NSData{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *string = self.nslogtext.text;
        NSString *str = [[NSString alloc]initWithData:NSData encoding:NSUTF8StringEncoding];
        self.nslogtext.text = [string stringByAppendingString:str];
    });
}

- (void)NSlogNSString:(NSString *)str{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *string = self.nslogtext.text;
        self.nslogtext.text = [string stringByAppendingString:str];
    });
}

- (IBAction)Clear:(id)sender {
    self.nslogtext.text = @"";
}
@end
