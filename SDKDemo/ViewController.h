//
//  ViewController.h
//  SDKDemo
//
//  Created by yzm157 on 15/10/16.
//  Copyright © 2015年 BroadLink Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)SDKInit:(UIButton *)sender;

- (IBAction)SDKAuth:(UIButton *)sender;

- (IBAction)deviceEasyConfig:(UIButton *)sender;

- (IBAction)deviceEasyConfigCancel:(UIButton *)sender;

- (IBAction)deviceProbe:(UIButton *)sender;

- (IBAction)devicePair:(UIButton *)sender;

- (IBAction)deviceBindWithServer:(UIButton *)sender;

- (IBAction)deviceGetResourceToken:(UIButton *)sender;

- (IBAction)deviceProfile:(UIButton *)sender;

- (IBAction)dnaControl:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextField *ssid;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *accountid;
@property (weak, nonatomic) IBOutlet UITextField *accountsession;
@property (weak, nonatomic) IBOutlet UITextView *nslogtext;
- (IBAction)Clear:(id)sender;

@end

