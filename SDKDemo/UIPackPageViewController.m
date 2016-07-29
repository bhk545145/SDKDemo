//
//  UIPackPageViewController.m
//  SDKDemo
//
//  Created by 白洪坤 on 16/6/8.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "UIPackPageViewController.h"
#import "NetworkAPI.h"
#import "JSONKit.h"
#import "BLDeviceInfo.h"
#import "bhkcommon.h"
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import "SSZipArchive.h"
#import "SecurityUtil.h"

@interface UIPackPageViewController (){
    dispatch_queue_t networkQueue;
    NetworkAPI *api;
    NSString *filepathFolder;
    UIWebView *UIPackPageWebView;
}

@end

@implementation UIPackPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    api = [[NetworkAPI alloc] init];
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    
    UIPackPageWebView = [[UIWebView alloc]init];
    UIPackPageWebView.frame = self.view.frame;
    [self.view addSubview:UIPackPageWebView];
    //取document目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    //加载UI包
    NSString *pathstr = [NSString stringWithFormat:@"/%@/zh-cn/app.html",_BLDeviceInfo.pid];
    NSString* path = [filepathFolder stringByAppendingPathComponent:pathstr];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [UIPackPageWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setBLDeviceInfo:(BLDeviceInfo *)BLDeviceInfo{
    _BLDeviceInfo = BLDeviceInfo;
    [self queryuiid:BLDeviceInfo.downloadurl pid:_BLDeviceInfo.pid info:_BLDeviceInfo];
}

- (void)queryuiid:(NSString *)downloadUrl pid:(NSString *)pid info:(BLDeviceInfo *)info
{
    time_t timestamp = time(NULL);
    NSString *sign = [self sha1:[NSString stringWithFormat:@"%@%ldbroadlinkDNA@", downloadUrl, timestamp]];
    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:@"query", @"action", @"ui", @"type", pid,@"pid",[NSDictionary dictionaryWithObject:@"bl" forKey:@"platform"], @"extrainfo", nil];
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
            [self download:_BLDeviceInfo.downloadurl pid:_BLDeviceInfo.pid];

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

- (void)download:(NSString *)downloadUrl pid:(NSString *)pid
{
    time_t timestamp = time(NULL);
    NSString *sign = [self sha1:[NSString stringWithFormat:@"%@%ldbroadlinkDNA@", downloadUrl, timestamp]];
    
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:@"download", @"action", @"ui", @"type", pid,@"pid",[NSDictionary dictionaryWithObjectsAndKeys:@"bl",@"platform",@"125",@"uiid",nil], @"extrainfo", nil];
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
            NSString *filepath = [filepathFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", pid]];
            NSString *filepathFolderpid = [filepathFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", pid]];
            if ([reqblock.responseData writeToFile:filepath atomically:YES])
            {
                DLog(@"filepath: %@", filepath);
                [SSZipArchive unzipFileAtPath:filepath toDestination:filepathFolderpid];
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
@end
