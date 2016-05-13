//
//  DeviceControl.m
//  SDKDemo
//
//  Created by 白洪坤 on 16/5/4.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "SPDeviceControl.h"
#import "BLDeviceInfo.h"
#import "NetworkAPI.h"
#import "bhkcommon.h"
#import "BLDeviceService.h"

@interface SPDeviceControl()<UITextViewDelegate>{
    dispatch_queue_t queue;
    dispatch_queue_t networkQueue;
    NetworkAPI *api;
    UITextField *namefield;
    UILabel *onandoff;
    UITextField *paramsfield;
    UITextView *paramsview;
    BLDeviceService *deviceservice;
}
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation SPDeviceControl

- (void)dealloc{
    [self setTimer:nil];
}

- (void)viewDidLoad {
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    self.view =view;
    api = [[NetworkAPI alloc]init];
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    deviceservice = [[BLDeviceService alloc]init];
    dispatch_async(queue, ^{
        //定时刷新
        //[self startTimer];
    });
}

- (void)startTimer{
    //每1秒刷新一次
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onandoffstate) userInfo:nil repeats:YES];
    //[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop]run];
}

- (void)setBLDeviceinfo:(BLDeviceInfo *)BLDeviceinfo{
    _BLDeviceinfo = BLDeviceinfo;
    UIButton *devinfobtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 80, 50, 50)];
    [devinfobtn setBackgroundImage:[UIImage imageNamed:@"58.png"] forState:UIControlStateNormal];
    [devinfobtn addTarget:self action:@selector(devinfobtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:devinfobtn];
    UIButton *devctrlonoffbtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 150, 50, 50)];
    [devctrlonoffbtn setBackgroundImage:[UIImage imageNamed:@"58.png"] forState:UIControlStateNormal];
    [devctrlonoffbtn addTarget:self action:@selector(devctrlonoffbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:devctrlonoffbtn];
    UIButton *devctrlbtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 220, 50, 50)];
    [devctrlbtn setBackgroundImage:[UIImage imageNamed:@"58.png"] forState:UIControlStateNormal];
    [devctrlbtn addTarget:self action:@selector(devctrlbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:devctrlbtn];
    namefield = [[UITextField alloc]initWithFrame:CGRectMake(10, 80, 80, 50)];
    namefield.font = [UIFont fontWithName:@"Arial" size:14.0f];
    namefield.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:namefield];
    namefield.text = _BLDeviceinfo.name;
    onandoff = [[UILabel alloc]initWithFrame:CGRectMake(10, 150, 80, 50)];
    onandoff.font = [UIFont fontWithName:@"Arial" size:14.0f];
    [self.view addSubview:onandoff];
    paramsfield = [[UITextField alloc]initWithFrame:CGRectMake(10, 220, 80, 50)];
    paramsfield.font = [UIFont fontWithName:@"Arial" size:14.0f];
    paramsfield.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:paramsfield];
    paramsfield.text = @"devtime";
    paramsview = [[UITextView alloc]initWithFrame:CGRectMake(10, 290, 640, 250) textContainer:nil];
    paramsview.font = [UIFont fontWithName:@"Arial" size:14.0f];
    paramsview.delegate = self;
    [self.view addSubview:paramsview];
    [self onandoffstate];
}
//修改设备信息
- (void)devinfobtnClick:(UIButton *)btn{
    dispatch_async(networkQueue, ^{
        [deviceservice dev_info:_BLDeviceinfo namefieldtext:namefield.text andBlock:^(BOOL ret, NSDictionary *dic) {
            DLog(@"%@",dic);
        }];
    });
}
//插座开关状态
- (void)onandoffstate{
    dispatch_async(networkQueue, ^{
        [deviceservice dev_ctrl:_BLDeviceinfo andBlock:^(BOOL ret, NSDictionary *dic) {
            if (ret) {
                NSArray *switchStatus = [dic valueForKeyPath:@"data.vals"];
                deviceservice.onandoff = [[[[switchStatus objectAtIndex:0] objectAtIndex:0] valueForKey:@"val"] boolValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    onandoff.text = deviceservice.onandoff?@"开":@"关";
                });
            }else{
                DLog(@"%@",dic);
            }
        }];
    });
}
//插座开关
- (void)devctrlonoffbtnClick:(UIButton *)btn{
    int status = 0;
    if (deviceservice.onandoff == 0) {
        status = 1;
    }else{
        status = 0;
    }
    dispatch_async(networkQueue, ^{
        [deviceservice dev_ctrlonoff:_BLDeviceinfo status:status andBlock:^(BOOL ret, NSDictionary *dic) {
            if (ret) {
                [self onandoffstate];
            }
            DLog(@"%@",dic);
        }];
    });
}

//插座get
- (void)devctrlbtnClick:(UIButton *)btn{
    int status = 0;
    if (deviceservice.onandoff == 0) {
        status = 1;
    }else{
        status = 0;
    }
    dispatch_async(networkQueue, ^{
        [deviceservice dev_ctrlget:_BLDeviceinfo params:paramsfield.text andBlock:^(BOOL ret, NSDictionary *dic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ret) {
                    NSArray *paramsvals = [dic valueForKeyPath:@"data.vals"];
                    if([paramsvals count] != 0){
                        if([[paramsvals objectAtIndex:0] count] != 0){
                            NSString *paramsval = [[[paramsvals objectAtIndex:0] objectAtIndex:0] valueForKey:@"val"];
                            paramsview.text = [NSString stringWithFormat:@"%@",paramsval];
                        }else{
                            paramsview.text = @"空";
                        }
                    }else{
                        paramsview.text = @"空";
                    }
                }
                DLog(@"%@",dic);
            });
        }];
                           
    });
}

@end
