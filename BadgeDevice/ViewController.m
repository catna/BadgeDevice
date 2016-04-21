//
//  ViewController.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "ViewController.h"
#import "TBluetooth.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic ,strong) TBluetooth *ble;
@end

@implementation ViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ble connect];
    [self addListener];
}

- (void)dealloc {
    [self removeListener];
}

#pragma mark - event
- (void)eDeviceConnectSuccess {
    self.textView.text = self.ble.device.name;
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

@end
