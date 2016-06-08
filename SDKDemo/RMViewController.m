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

@interface RMViewController ()

@end

@implementation RMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBLDeviceinfo:(BLDeviceInfo *)BLDeviceinfo{
    _BLDeviceinfo = BLDeviceinfo;
}


- (IBAction)RMbtn:(id)sender {
    
}
@end
