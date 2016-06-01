//
//  TodayViewController.m
//  DNASDKToday
//
//  Created by 白洪坤 on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "NetworkAPI.h"
#import "bhkcommon.h"

@interface TodayViewController () <NCWidgetProviding>{
    NetworkAPI *api;
    dispatch_queue_t networkQueue;
    NSString *filepathFolder;
}

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    api = [[NetworkAPI alloc]init];
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filepathFolder = [paths objectAtIndex:0];
    [self SDKInit:filepathFolder localctrl:[NSNumber numberWithBool:false] loglevel:[NSNumber numberWithInt:0]];
}

- (void)SDKInit:(NSString *)filepath localctrl:(NSNumber *)localctrl loglevel:(NSNumber *)loglevel{
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:filepath forKey:@"filepath"];
        [dic setObject:localctrl forKey:@"localctrl"];
        [dic setObject:loglevel forKey:@"loglevel"];
        NSError *error;
        NSData *descData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *requestData = [api SDKInit:[[NSString alloc] initWithData:descData encoding:NSUTF8StringEncoding]];
        DLog(@"%@",requestData);
//        NSData *responseData = [requestData dataUsingEncoding:NSUTF8StringEncoding];
//        if ([[[responseData objectFromJSONData] objectForKey:@"status"] intValue] == 0) {
//            DLog(@"%@",requestData);
//        }else{
//            DLog(@"%@",requestData);
//        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
