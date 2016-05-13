//
//  Devicecell.h
//  SDKDemo
//
//  Created by 白洪坤 on 16/5/10.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLDeviceInfo;
@interface Devicecell : UITableViewCell
@property (strong,nonatomic) BLDeviceInfo *BLDeviceinfo;
@property (weak, nonatomic) IBOutlet UIImageView *deviceimage;
@property (weak, nonatomic) IBOutlet UILabel *devicename;
@property (weak, nonatomic) IBOutlet UILabel *devicemac;
@property (weak, nonatomic) IBOutlet UISwitch *devicelock;
@property (weak, nonatomic) IBOutlet UILabel *devicetype;
@property (weak, nonatomic) IBOutlet UILabel *devicelanaddr;
@property (weak, nonatomic) IBOutlet UIImageView *devicenewconfig;
@property (weak, nonatomic) IBOutlet UIImageView *backimageview;
@end
