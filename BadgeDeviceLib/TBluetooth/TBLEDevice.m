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

#import "TBLEDefine.h"
#import "TBluetoothTools.h"
#import "TBluetooth.h"
#import "TBLEDeviceDistill.h"
#import "TBLEDeviceRawData.h"
#import "TBLENotification.h"

@interface TBLEDevice ()
@property (nonatomic, assign) BOOL isReady;
@end

@implementation TBLEDevice
@synthesize peri = _peri;
@synthesize advertisementData = _advertisementData;
@synthesize macAddr = _macAddr;
@synthesize isConnect = _isConnect;
@synthesize characteristics = _characteristics;

- (void)setConnectStatus:(BOOL)connect {
    _isConnect = connect;
    [self setNotifyData:self.notifyData];
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

- (void)setIsReady:(BOOL)isReady {
    _isReady = isReady;
    if (self.readyHandler) {
        self.readyHandler(_isReady);
    }
}

- (void)setNotifyData:(BOOL)notifyData {
    _notifyData = notifyData;
    NSArray *keys = @[UVConfig, THConfig, PrConfig];
    for (NSString *key in keys) {
        CBCharacteristic *cha = [self.characteristics valueForKey:key];
        if (self.peri && cha) {
            Byte open = _notifyData ? 0x01 : 0x00;
            NSData *data = [NSData dataWithBytes:&open length:sizeof(open)];
            [self.peri writeValue:data forCharacteristic:cha type:CBCharacteristicWriteWithResponse];
        }
    }
    
    NSArray *notiKeys = @[UVData, THData, PrData];
    for (NSString *key in notiKeys) {
        CBCharacteristic *cha = [self.characteristics valueForKey:key];
        if (self.peri && cha) {
            [self.peri setNotifyValue:_notifyData forCharacteristic:cha];
        }
    }
}

- (void)setMacAddr:(NSString *)macAddr {
    _macAddr = [macAddr mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiDevicesMacAddrReaded object:self];
}

#pragma mark - getter
- (NSMutableDictionary<NSString *,CBCharacteristic *> *)characteristics {
    if (!_characteristics) {
        _characteristics = [[NSMutableDictionary alloc] init];
    }
    return _characteristics;
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
    TBLEDeviceDistill *distill = objc_getAssociatedObject(self, TBLEDeviceDistillToolKey);
    if (!distill) {
        distill = [[TBLEDeviceDistill alloc] init];
        [distill setValue:self forKey:@"device"];
        [self setDistillTool:distill];
    }
    return distill;
}

@end
