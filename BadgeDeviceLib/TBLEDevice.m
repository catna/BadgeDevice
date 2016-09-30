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

@interface TBLEDeviceRawData ()
@property (nonatomic, strong) void (^DataUpdateHandler)(BOOL dataValidity);
@end

@implementation TBLEDeviceRawData {
    BOOL _uV, _pV, _tV, _hV;
}
@synthesize dataValidity = _dataValidity;
@synthesize Temp = _Temp;
@synthesize Humi = _Humi;
@synthesize Pres = _Pres;
@synthesize UVLe = _UVLe;

- (void)setTHRawData:(NSData *)THRawData {
    if (THRawData == NULL) {
        return;
    }
    _THRawData = THRawData;
    double t = [TBluetoothTools convertTempData:THRawData];
    double h = [TBluetoothTools convertHumiData:THRawData];
    _tV = t > -40.0;
    _hV = h > -1.0;
    
    _Temp = [NSString stringWithFormat:@"%.2f", t];
    _Humi = [NSString stringWithFormat:@"%.2f", h];
    [self updateData];
}

- (void)setPrRawData:(NSData *)PrRawData {
    if (PrRawData == NULL) {
        return;
    }
    _PrRawData = PrRawData;
    double p = [TBluetoothTools convertPresData:PrRawData];
    _pV = p > 10;
    _Pres = [NSString stringWithFormat:@"%.2f", p];
    [self updateData];
}

- (void)setUVRawData:(NSData *)UVRawData {
    if (UVRawData == NULL) {
        return;
    }
    _UVRawData = UVRawData;
    double uv = [TBluetoothTools convertUVNuData:UVRawData];
    _uV = uv >= 0;
    _UVLe = [NSString stringWithFormat:@"%d", [TBluetoothTools matchUVLeWithUVNu:uv]];
    [self updateData];
}

- (BOOL)dataValidity {
    if (_uV && _pV && _tV && _hV) {
        return YES;
    }
    return NO;
}

- (void)updateData {
    if (self.DataUpdateHandler) {
        self.DataUpdateHandler(self.dataValidity);
    }
#if DEBUG
    NSLog(@"徽章数据->\r\n温度:%@\t湿度:%@\t气压:%@\t紫外线:%@\r\n", self.Temp, self.Humi, self.Pres, self.UVLe);
#endif
}

@end

@implementation TBLEDevice
@synthesize macAddr = _macAddr;
@synthesize isConnect = _isConnect;

- (void)setConnectStatus:(BOOL)connect {
    _isConnect = connect;
    if (self.connectStatusChanged) {
        self.connectStatusChanged(_isConnect);
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
    self.currentRawData.DataUpdateHandler = _DataUpdateHandler;
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
