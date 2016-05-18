//
//  TBLEDevice.m
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation TBLEDeviceRawData

@end

@implementation TBLEDevice
- (void)clearAllPropertyData {
    self.name = nil;
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

- (TBLEDeviceRawData *)currentData {
    if (!_currentRawData) {
        _currentRawData = [[TBLEDeviceRawData alloc] init];
    }
    return _currentRawData;
}
@end
