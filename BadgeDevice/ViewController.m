//
//  ViewController.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "ViewController.h"
#import "TBluetooth.h"
#import "MDeviceData.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic ,strong) TBluetooth *ble;
@property (nonatomic ,strong) MDeviceData *currentData;
@end

@implementation ViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addListener];
    [self.ble readDataWithUpdateHandler:^(struct DeviceData deviceData) {
        
    } notify:YES];
}

- (void)dealloc {
    [self removeListener];
}

#pragma mark - event
- (void)eDeviceConnectSuccess {
    self.currentData.name = self.ble.device.name;
}

#pragma mark - private methods
- (void)addListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eDeviceConnectSuccess) name:kTBluetoothConnectSuccess object:nil];
}

- (void)removeListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter
- (TBluetooth *)ble {
    if (!_ble) {
        _ble = [TBluetooth sharedBluetooth];
    }
    return _ble;
}

- (MDeviceData *)currentData {
    if (!_currentData) {
        _currentData = [[MDeviceData alloc] init];
    }
    return _currentData;
}

@end
