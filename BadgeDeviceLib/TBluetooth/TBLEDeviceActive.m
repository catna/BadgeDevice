//
//  TBLEDeviceActive.m
//  BadgeDevice
//
//  Created by MX on 2016/11/9.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDeviceActive.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBLEDeviceRawData.h"
#import "TBLEDefine.h"
#import "TBLEDevice.h"

@interface TBLEDeviceActive ()
@property (nonatomic, weak) TBLEDevice *device;
@end

@implementation TBLEDeviceActive
@synthesize currentRawData = _currentRawData;
@synthesize characteristics = _characteristics;

- (void)updateData:(CBCharacteristic *)characteristic {
    NSString *UUIDStr = characteristic.UUID.UUIDString;
    NSString *dataName;
    if ([UUIDStr isEqualToString:THData]) {
        dataName = @"温湿度";
        _currentRawData.THRawData = characteristic.value;
    } else if ([UUIDStr isEqualToString:UVData]) {
        dataName = @"紫外线";
        _currentRawData.UVRawData = characteristic.value;
    } else if ([UUIDStr isEqualToString:PrData]) {
        dataName = @"大气压";
        _currentRawData.PrRawData = characteristic.value;
    }
    //                NSLog(@"读取设备%@的%@数据--%@",self.devicesDic[peri].macAddr,dataName, self.devicesDic[peri].currentRawData);

}

- (void)store:(CBCharacteristic *)characteristic peri:(CBPeripheral *)peri {
    NSArray *keys = @[UVConfig, UVData, THConfig, THData, PrConfig, PrData];
    for (NSString *key in keys) {
        if ([characteristic.UUID.UUIDString isEqualToString:key]) {
            [self.characteristics setObject:characteristic forKey:key];
        }
    }
}

- (void)setNotify:(BOOL)notify {
    _notify = notify;
    NSArray *keys = @[UVConfig, THConfig, PrConfig];
    for (NSString *key in keys) {
        CBCharacteristic *cha = [self.characteristics valueForKey:key];
        if (self.device.peri && cha) {
            Byte open = _notify ? 0x01 : 0x00;
            NSData *data = [NSData dataWithBytes:&open length:sizeof(open)];
            [self.device.peri writeValue:data forCharacteristic:cha type:CBCharacteristicWriteWithResponse];
        }
    }
    
    NSArray *notiKeys = @[UVData, THData, PrData];
    for (NSString *key in notiKeys) {
        CBCharacteristic *cha = [self.characteristics valueForKey:key];
        if (self.device.peri && cha) {
            [self.device.peri setNotifyValue:_notify forCharacteristic:cha];
        }
    }
}

#pragma mark - getter
- (TBLEDeviceRawData *)currentRawData {
    if (!_currentRawData) {
        _currentRawData = [[TBLEDeviceRawData alloc] init];
    }
    return _currentRawData;
}

- (NSMutableDictionary<NSString *,CBCharacteristic *> *)characteristics {
    if (!_characteristics) {
        _characteristics = [[NSMutableDictionary alloc] init];
    }
    return _characteristics;
}
@end
