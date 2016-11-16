//
//  ViewController.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import <BadgeDeviceLib/TBluetooth.h>
#import <BadgeDeviceLib/TBLEDevice.h>
#import <BadgeDeviceLib/TBLEDefine.h>
#import <BadgeDeviceLib/TBLEDeviceDistill.h>
#import "BadgeDeviceNotification.h"
#import "BadgeDeviceManager.h"
#import "BadgeDevice.h"

#import "DataStoreTool.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) BadgeDevice *device;
@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eNotiDeviceChanged) name:kNotiBadgeDeviceManagerDeviceChanged object:nil];
    [[BadgeDeviceManager sharedManager] scan:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - event
- (void)eNotiDeviceChanged {
    NSLog(@"视图层设备数目变化%ld", [[[BadgeDeviceManager sharedManager] devices] count]);
    self.device = [[[[BadgeDeviceManager sharedManager] devices] allValues] firstObject];
}

- (IBAction)dump:(UIButton *)sender {
    if (self.device.distillTool.isReady) {
        [self.device readHistoryData];
        [self.device notifyCurrentData:YES];
    }
}


@end
