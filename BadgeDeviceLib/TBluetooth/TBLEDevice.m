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
#import <objc/runtime.h>
#import <BabyBluetooth.h>

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
    _pV = p >= 800 && p <= 1100;
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

static const void *TBLEDeviceDataStoreCharacteristicKey = @"TBLEDeviceDataStoreCharacteristicKey";
@implementation TBLEDevice(DataDistill)
- (void)startDistill {
    if (nil != self.DataStoreCharacteristic && nil != self.peri) {
        [self.peri readValueForCharacteristic:self.DataStoreCharacteristic];
    }
}

- (void)distillData:(CBCharacteristic *)characteristic {
    if (characteristic == self.DataStoreCharacteristic) {
        unsigned int const allFF = ~0;
        unsigned long long all00 = 0;
        int compareFFResult = bcmp(characteristic.value.bytes, &allFF, sizeof(allFF));
        int compare00Result = bcmp(characteristic.value.bytes, &all00, characteristic.value.length);
        if (0 != compareFFResult && 0 != compare00Result) {
            NSLog(@"\r\n读取到的历史和电量信息%@\r\n", characteristic.value);
        }
    }
    [self startDistill];
}

- (void)timeCalibration:(CBCharacteristic *)characteristic {
    if (nil != self.peri) {
        NSData *data = [self createCurrentTimeData];
        
        [self.peri writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

- (NSData *)createCurrentTimeData {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy|MM|dd|HH|mm";
    NSString *dateString = [formatter stringFromDate:date];
    NSArray <NSString *>*dateArray = [dateString componentsSeparatedByString:@"|"];
    
    char year   = [[dateArray[0] substringFromIndex:2] intValue];
    char month  = [dateArray[1] intValue];
    char day    = [dateArray[2] intValue];
    char hour   = [dateArray[3] intValue];
    char minute = [dateArray[4] intValue];
    
    char dateBytes[8];
    dateBytes[0] = year;
    dateBytes[1] = month;
    dateBytes[2] = day;
    dateBytes[3] = hour;
    dateBytes[4] = minute;
    
    NSData *data = [NSData dataWithBytes:&dateBytes length:sizeof(dateBytes)];
    return data;
}

- (void)setDataStoreCharacteristic:(CBCharacteristic *)DataStoreCharacteristic {
    objc_setAssociatedObject(self, TBLEDeviceDataStoreCharacteristicKey, DataStoreCharacteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBCharacteristic *)DataStoreCharacteristic {
    return objc_getAssociatedObject(self, TBLEDeviceDataStoreCharacteristicKey);
}

@end
