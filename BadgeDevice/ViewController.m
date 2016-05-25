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
#import "TBLEDevice.h"

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
//    [self.ble readDataWithUpdateHandler:^(struct DeviceData deviceData) {
//        self.currentData.macAddress = self.ble.device.macAddress;
//        self.currentData.pres = (__bridge NSString *)(deviceData.pres);
//        self.currentData.humi = (__bridge NSString *)(deviceData.humi);
//        self.currentData.temp = (__bridge NSString *)(deviceData.temp);
//        self.currentData.UVNu = (__bridge NSString *)(deviceData.UVNu);
//        self.currentData.UVLe = (__bridge NSString *)(deviceData.UVLe);
//        self.textView.text = [self.currentData generateShowText];
//    } notify:YES];
    [self.ble scanAndConnectWithMacAddrList:@[@""]];
//    [self.ble scanAndConnectWithMacAddrList:nil];
//    7C:EC:79:E4:24:D5
    [self.ble.device addObserver:self forKeyPath:@"macAddr" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"macAddr"]) {
//        
//        if ([change[@"new"] isKindOfClass:[NSString class]]) {
//            NSString *m = change[@"new"];
//            NSLog(@"收到设备连接后的mac地址%@",m);
//            if ([m isEqualToString:@"7C:EC:79:E4:24:D5"]) {
//                [self.ble cancelConn];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                   [self.ble scanAndConnectWithMacAddrList:@[@""]]; 
//                });
//            }
//        }
//    }
}

- (void)dealloc {
    [self removeListener];
}

#pragma mark - event
- (void)eDeviceConnectSuccess {
//    self.currentData.name = self.ble.device.name;
//    self.textView.text = [NSString stringWithFormat:@"%@\n%@",self.textView.text,self.ble.device.name];
}

#pragma mark - private methods
- (void)addListener {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eDeviceConnectSuccess) name:kTBluetoothConnectSuccess object:nil];
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
