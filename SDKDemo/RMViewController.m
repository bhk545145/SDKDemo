//
//  RMViewController.m
//  SDKDemo
//
//  Created by 白洪坤 on 16/6/7.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "RMViewController.h"
#import "BLDeviceInfo.h"
#import "NetworkAPI.h"
#import "bhkcommon.h"
#import "BLDeviceService.h"

@interface RMViewController (){
    dispatch_queue_t queue;
    dispatch_queue_t networkQueue;
    NetworkAPI *api;
    BLDeviceService *deviceservice;
}

@end

@implementation RMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    api = [[NetworkAPI alloc]init];
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    deviceservice = [[BLDeviceService alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBLDeviceinfo:(BLDeviceInfo *)BLDeviceinfo{
    _BLDeviceinfo = BLDeviceinfo;
}


- (IBAction)RMbtn:(id)sender {
    dispatch_async(networkQueue, ^{
        [deviceservice RMdev_ctrl:_BLDeviceinfo params:@"irdastudy" andBlock:^(BOOL ret, NSDictionary *dic) {
            [deviceservice RMdev_ctrlIrdaGet:_BLDeviceinfo params:@"irda" andBlock:^(BOOL ret, NSDictionary *dic) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ret) {
                        NSArray *paramsvals = [dic valueForKeyPath:@"data.vals"];
                        if([paramsvals count] != 0){
                            if([[paramsvals objectAtIndex:0] count] != 0){
                                NSString *paramsval = [[[paramsvals objectAtIndex:0] objectAtIndex:0] valueForKey:@"val"];
                                self.Irdatxt.text = [NSString stringWithFormat:@"%@",paramsval];
                            }else{
                                self.Irdatxt.text = @"空";
                            }
                        }else{
                            self.Irdatxt.text = @"空";
                        }
                    }
                });
            }];
        }];
    });
}

- (IBAction)RMsend:(id)sender {
    dispatch_async(networkQueue, ^{
        [deviceservice RMdev_ctrlIrdaSet:_BLDeviceinfo params:@"irda" status:self.Irdatxt.text andBlock:^(BOOL ret, NSDictionary *dic) {
            DLog(@"RM发射%@",dic);
        }];
    });
}
@end
