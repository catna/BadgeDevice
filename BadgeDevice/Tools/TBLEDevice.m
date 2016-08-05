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
#import "TBluetooth.h"

@implementation TBLEDeviceRawData {
    BOOL _uV, _pV, _tV, _hV;
}
@synthesize dataValidity = _dataValidity;
@synthesize Temp = _Temp;
@synthesize Humi = _Humi;
@synthesize Pres = _Pres;
@synthesize UVLe = _UVLe;

- (void)setTHRawData:(NSData *)THRawData {
    _THRawData = THRawData;
    double t = [TBluetoothTools convertTempData:THRawData];
    double h = [TBluetoothTools convertHumiData:THRawData];
    _tV = t > -40.0;
    _hV = h > -1.0;
    
    _Temp = [NSString stringWithFormat:@"%.2f", t];
    _Humi = [NSString stringWithFormat:@"%.2f", h];
}

- (void)setPrRawData:(NSData *)PrRawData {
    _PrRawData = PrRawData;
    double p = [TBluetoothTools convertPresData:PrRawData];
    _pV = p > 10;
    _Pres = [NSString stringWithFormat:@"%.2f", p];
}

- (void)setUVRawData:(NSData *)UVRawData {
    _UVRawData = UVRawData;
    double uv = [TBluetoothTools convertUVNuData:UVRawData];
    _uV = uv >= 0;
    _UVLe = [NSString stringWithFormat:@"%d", [TBluetoothTools matchUVLeWithUVNu:uv]];
}

- (BOOL)dataValidity {
    if (_uV && _pV && _tV && _hV) {
        return YES;
    }
    return NO;
}

@end

@implementation TBLEDevice
@synthesize macAddr = _macAddr;
@synthesize isConnect = _isConnect;

- (void)setConnectStatus:(BOOL)connect {
    _isConnect = connect;
    if (!_isConnect) {
        for (CBService *service in self.peri.services) {
            [[TBluetooth sharedBluetooth] dataGalleryOpen:NO peri:self.peri service:service];
        }
    }
}

- (void)setMacAddr:(NSString *)macAddr {
    _macAddr = [macAddr mutableCopy];
    if (self.peri.services) {
        for (CBService *service in self.peri.services) {
            [[TBluetooth sharedBluetooth] dataGalleryOpen:NO peri:self.peri service:service];
            [[TBluetooth sharedBluetooth] dataGalleryOpen:YES peri:self.peri service:service];
        }
    }
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
