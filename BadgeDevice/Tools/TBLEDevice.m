//
//  TBLEDevice.m
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBluetoothTools.h"

@implementation TBLEDeviceRawData
@synthesize Temp = _Temp;
@synthesize Humi = _Humi;
@synthesize Peri = _Peri;
@synthesize UVLe = _UVLe;

- (void)setTHRawData:(NSData *)THRawData {
    _THRawData = THRawData;
    double t = [TBluetoothTools convertTempData:THRawData];
    double h = [TBluetoothTools convertHumiData:THRawData];
    _Temp = [NSString stringWithFormat:@"%.2f", t];
    _Humi = [NSString stringWithFormat:@"%.2f", h];
}

- (void)setPrRawData:(NSData *)PrRawData {
    _PrRawData = PrRawData;
    double p = [TBluetoothTools convertPresData:PrRawData];
    _Peri = [NSString stringWithFormat:@"%.2f", p];
}

- (void)setUVRawData:(NSData *)UVRawData {
    _UVRawData = UVRawData;
    double uv = [TBluetoothTools convertUVNuData:UVRawData];
    _UVLe = [NSString stringWithFormat:@"%d", [TBluetoothTools matchUVLeWithUVNu:uv]];
}
@end

@implementation TBLEDevice
@synthesize isConnect = _isConnect;

- (void)setConnectStatus:(BOOL)connect {
    _isConnect = connect;
}

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

- (TBLEDeviceRawData *)currentRawData {
    if (!_currentRawData) {
        _currentRawData = [[TBLEDeviceRawData alloc] init];
    }
    return _currentRawData;
}
@end
