//
//  Devicecell.m
//  SDKDemo
//
//  Created by 白洪坤 on 16/5/10.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "Devicecell.h"
#import "BLDeviceInfo.h"
#import "bhkcommon.h"
#import "UIImage+MJ.h"

@interface Devicecell (){

}

@end

@implementation Devicecell

- (void)setBLDeviceinfo:(BLDeviceInfo *)BLDeviceinfo{
    _BLDeviceinfo = BLDeviceinfo;
    _backimageview.userInteractionEnabled = YES;
    _backimageview.image = [UIImage resizedImageWithName:@"timeline_card_top_background"];
    _backimageview.highlightedImage = [UIImage resizedImageWithName:@"timeline_card_top_background_highlighted"];
    if (BLDeviceinfo.type == SPmini || BLDeviceinfo.type == SPminiv2) {
        self.deviceimage.image = [UIImage imageNamed:@"SPmin.jpg"];
    }else if (BLDeviceinfo.type == RM || BLDeviceinfo.type == RMplus || BLDeviceinfo.type == RM3mini) {
        self.deviceimage.image = [UIImage imageNamed:@"RMpro.jpg"];
    }else if (BLDeviceinfo.type == SP2) {
        self.deviceimage.image = [UIImage imageNamed:@"SP2.jpg"];
    }else if (BLDeviceinfo.type == A1){
        self.deviceimage.image = [UIImage imageNamed:@"A1.jpg"];
    }else if (BLDeviceinfo.type == MS1){
        self.deviceimage.image = [UIImage imageNamed:@"MS1.jpg"];
    }else if (BLDeviceinfo.type == S1){
        self.deviceimage.image = [UIImage imageNamed:@"S1.jpg"];
    }else{
        self.deviceimage.image = [UIImage imageNamed:@"58.png"];
    }
    
    self.devicename.text = BLDeviceinfo.name;
    self.devicemac.text = BLDeviceinfo.mac;
    [self.devicelock setOn:BLDeviceinfo.lock animated:YES];
    self.devicetype.text = [NSString stringWithFormat:@"%d",BLDeviceinfo.type];
    self.devicelanaddr.text = BLDeviceinfo.lanaddr;
    if (BLDeviceinfo.newconfig) {
        self.devicenewconfig.image = [UIImage imageNamed:@"58.png"];
    }
    
}

@end
