//
//  TBLEDeviceDistill.m
//  BadgeDevice
//
//  Created by MX on 2016/10/27.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDeviceDistill.h"
#import "TBluetoothTools.h"
#import "TBLEDevice.h"
#import "TBLEDeviceRawData.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBLENotification.h"

#define FFCountMax 10

@interface TBLEDeviceDistill ()
@property (nonatomic, assign) NSUInteger FFCount;
@end

@implementation TBLEDeviceDistill
@synthesize device = _device;
@synthesize historyRawData = _historyRawData;
@synthesize battery = _battery;

- (id)initWithDevice:(TBLEDevice *)device {
    if (self = [super init]) {
        _device = device;
    }
    return self;
}

#pragma mark - public methods
- (BOOL)startDistill {
    if (self.device.peri && self.historyDataCharacteristic && self.FFCount <= FFCountMax) {
        [self.device.peri readValueForCharacteristic:self.historyDataCharacteristic];
        return YES;
    }
    return NO;
}

- (void)distillData {
    if (self.historyDataCharacteristic && self.device.peri) {
        NSData *data = self.historyDataCharacteristic.value;
        unsigned int const allFF = ~0;
        unsigned long long all00 = 0;
        int compareFFResult = bcmp(data.bytes, &allFF, sizeof(allFF));
        int compare00Result = bcmp(data.bytes, &all00, data.length);
        if (0 != compareFFResult && 0 != compare00Result) {
            NSLog(@"\r\n读取到的历史和电量信息%@\r\n", data);
            [self parseCharacteristicData:data];
        } else if (0 == compareFFResult) {
            NSLog(@"读取数据操作完成");
            self.FFCount += 1;
            [self timeCalibration];
        }
    }
    [self startDistill];
}

- (BOOL)timeCalibration {
    if (self.device.peri && self.timeCalibrateCharacteristic) {
        NSData *data = [TBluetoothTools createCurrentTimeData];
        [self.device.peri writeValue:data forCharacteristic:self.timeCalibrateCharacteristic type:CBCharacteristicWriteWithResponse];
        return YES;
    }
    return NO;
}

#pragma mark - private methods
//    读取到的历史和电量信息<1009080a 2129f06b 7e775c8d 01430908>
//    BYTE0：年
//    BYTE1：月
//    BYTE2：日
//    BYTE3：时
//    BYTE4：分
//    BYTE5：紫外线
//    BYTE6~7：温度
//    BYTE8~9：湿度
//    BYTE10~12：大气压
//    BYTE13：电池电量
//    BYTE14~15：保留
- (void)parseCharacteristicData:(NSData *)data {
    const char *rawData = data.bytes;
    int tehu = 0, uvle = 0;
    char time[5], pres[6];
    memcpy(time, rawData, 5);
    *((char *)&uvle) = rawData[5];
    memcpy(&tehu, &rawData[6], 4);
    memcpy(&pres, &rawData[7], 6);
    TBLEDeviceRawData *hisData = [[TBLEDeviceRawData alloc] init];
    hisData.THRawData = [NSData dataWithBytes:&tehu length:sizeof(tehu)];
    hisData.PrRawData = [NSData dataWithBytes:pres length:6];
    hisData.UVRawData = [NSData dataWithBytes:&uvle length:sizeof(uvle)];
    hisData.date = [TBluetoothTools parseHistoryDate:time];
    self.historyRawData = hisData;
    
    NSUInteger battery = 0;
    *((char *)&battery) = rawData[13];
    _battery = battery;
}

#pragma mark - setter & getter
- (void)setHistoryRawData:(TBLEDeviceRawData *)historyRawData {
    _historyRawData = historyRawData;
}

@end
