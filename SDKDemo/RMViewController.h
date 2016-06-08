//
//  RMViewController.h
//  SDKDemo
//
//  Created by 白洪坤 on 16/6/7.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLDeviceInfo;
@interface RMViewController : UIViewController
@property (strong,nonatomic) BLDeviceInfo *BLDeviceinfo;
- (IBAction)RMbtn:(id)sender;

@end
