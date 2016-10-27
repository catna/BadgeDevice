//
//  TBLEDevice.m
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <objc/runtime.h>
#import <BabyBluetooth.h>

#import "TBluetoothTools.h"
#import "TBluetooth.h"
#import "TBLEDeviceDistill.h"
#import "TBLEDeviceRawData.h"

@implementation TBLEDevice
@synthesize macAddr = _macAddr;
@synthesize isConnect = _isConnect;

- (void)setConnectStatus:(BOOL)connect {
    _isConnect = connect;
    if (self.connectStatusChanged) {
        self.connectStatusChanged(_isConnect);
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    BabyBluetooth *BLE = [[TBluetooth sharedBluetooth] valueForKeyPath:@"babyBluetooth"];
    _selected ? [BLE AutoReconnect:self.peri] : [BLE AutoReconnectCancel:self.peri];
    if (!_selected) {
        [BLE cancelPeripheralConnection:self.peri];
    }
}

- (void)setMacAddr:(NSString *)macAddr {
    _macAddr = [macAddr mutableCopy];
    if (self.macAddressReaded) {
        self.macAddressReaded(_macAddr);
    }
}

- (void)setDataUpdateHandler:(void (^)(BOOL))DataUpdateHandler {
    _DataUpdateHandler = DataUpdateHandler;
//    self.currentRawData.DataUpdateHandler = _DataUpdateHandler;
}

- (void)clearAllPropertyData {
    self.macAddr = nil;
    self.peri = nil;
}

#pragma mark - getter
- (NSMutableArray <CBCharacteristic *>*)characteristicsForData {
    if (!_characteristicsForData) {
        _characteristicsForData = [[NSMutableArray alloc] init];
    }
    return _characteristicsForData;
}

- (TBLEDeviceRawData *)currentRawData {
    if (!_currentRawData) {
        _currentRawData = [[TBLEDeviceRawData alloc] init];
    }
    return _currentRawData;
}
@end

static const void *TBLEDeviceDistillToolKey = "TBLEDeviceDistillToolKey";
@implementation TBLEDevice(DataDistill)
#pragma mark - public methods

#pragma mark - setter & getter
- (void)setDistillTool:(TBLEDeviceDistill *)distillTool {
    objc_setAssociatedObject(self, TBLEDeviceDistillToolKey, distillTool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TBLEDeviceDistill *)distillTool {
    id distill = objc_getAssociatedObject(self, TBLEDeviceDistillToolKey);
    if (!distill) {
        distill = [[TBLEDeviceDistill alloc] init];
        [self setDistillTool:distill];
    }
    return distill;
}

@end
