//
//  BadgeDevice.m
//  BadgeDevice
//
//  Created by MX on 2016/11/10.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "BadgeDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BadgeDeviceNotification.h"

#import "TBluetooth/TBLEDefine.h"
#import "TBluetooth/TBLEDeviceDistill.h"
#import "TBluetooth/TBLEDeviceActive.h"
#import "TBluetooth/TBLENotification.h"
#import "TBluetooth/TBLEDeviceRawData.h"

#import "DataStore/DataStoreTool.h"
#import "DataStore/MDeviceData.h"

#define currentDataCountMax 50
@interface BadgeDevice ()
@property (nonatomic, strong) NSDictionary <NSString *,NSArray<NSString *>*>* seConfDataDic;
@end

@implementation BadgeDevice {
    NSUInteger _currentDataCount;
}
@synthesize device = _device;
@synthesize activeTool = _activeTool;
@synthesize distillTool = _distillTool;

- (id)initWithDevice:(TBLEDevice *)device {
    if (self = [super init]) {
        _device = device;
        _activeTool = [[TBLEDeviceActive alloc] initWithDevice:_device];
        _distillTool = [[TBLEDeviceDistill alloc] initWithDevice:_device];
        _device.dataWagon = self;
        _currentDataCount = 0;
        [self addListener];
    }
    return self;
}

- (id)init {
    NSLog(@"BadgeDevice:Please use init with device method");
    abort();
}

- (void)dealloc {
    [self removeListener];
}

#pragma mark - public methods
- (BOOL)notifyCurrentData:(BOOL)enable {
    if (self.activeTool.isReady) {
        self.activeTool.notify = enable;
        return YES;
    }
    return NO;
}

- (BOOL)readHistoryData {
    if (self.distillTool.isReady) {
        [self.distillTool startDistill];
        return YES;
    }
    return NO;
}

- (BOOL)resetTime {
    if (self.distillTool.isReady) {
        [self.distillTool timeCalibration];
        return YES;
    }
    return NO;
}

#pragma mark - private methods
- (void)eNotiHistoryData {
    if (self.distillTool.historyData.count > 0) {
        DataStoreTool *ds = [DataStoreTool sharedTool];
        for (TBLEDeviceRawData *data in self.distillTool.historyData) {
            if (data.dataValidity) {
                MDeviceData *d = [ds createAModelToFill];
                d.name = self.device.peri.name;
                d.time = data.dataRecordTime;
                d.pres = data.Pres;
                d.humi = data.Humi;
                d.temp = data.Temp;
                d.uvle = data.UVLe;
                d.macAddress = self.device.macAddr;
                [ds save];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiBadgeDeviceHistoryDataReadCompletion object:nil];
}

- (void)eNotiCurrentDataUpdate {
    if (self.activeTool.currentRawData.dataValidity && _currentDataCount >= currentDataCountMax) {
        _currentDataCount = 0;
        DataStoreTool *ds = [DataStoreTool sharedTool];
        MDeviceData *d = [ds createAModelToFill];
        d.name = self.device.peri.name;
        d.time = self.activeTool.currentRawData.dataRecordTime;
        d.pres = self.activeTool.currentRawData.Pres;
        d.humi = self.activeTool.currentRawData.Humi;
        d.temp = self.activeTool.currentRawData.Temp;
        d.uvle = self.activeTool.currentRawData.UVLe;
        d.macAddress = self.device.macAddr;
        [ds save];
    }
    _currentDataCount += 1;
    if (self.activeTool.currentRawData.dataValidity) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiBadgeDeviceCurrentDataUpdate object:nil];
    }
}

- (void)addListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eNotiHistoryData) name:kBLENotiDeviceHistoryDataReadCompletion object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eNotiCurrentDataUpdate) name:kBLENotiDeviceDataUpdate object:nil];
}

- (void)removeListener {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TBLEDeviceDataWagon
- (void)storeCharacteristicInService:(CBService *)service peri:(CBPeripheral *)peripheral {
    for (NSString *key in self.seConfDataDic.allKeys) {
        if ([service.UUID.UUIDString isEqualToString:key]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                [self.activeTool store:characteristic peri:peripheral];
            }
        }
    }

    if ([service.UUID.UUIDString isEqualToString:ConnectService]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:ConnectData]) {
                self.distillTool.historyDataCharacteristic = characteristic;
            }

            if ([characteristic.UUID.UUIDString isEqualToString:ConnectTimeConfig]) {
                self.distillTool.timeCalibrateCharacteristic = characteristic;
            }
        }
    }
}

- (void)carryCharacteristic:(CBCharacteristic *)characteristic peri:(CBPeripheral *)peripheral {
    if ([self.device.peri isEqual:peripheral]) {
        NSString *UUIDStr = characteristic.UUID.UUIDString;
        if ([UUIDStr isEqualToString:ConnectData]) {
            [self.distillTool distillData];
            return;
        }
        for (NSArray *uuidArr in self.seConfDataDic.allValues) {
            if ([uuidArr containsObject:UUIDStr]) {
                [self.activeTool updateData:characteristic];
            }
        }
    }
}

#pragma mark - setter & getter
- (NSDictionary <NSString *,NSArray <NSString *>*>*)seConfDataDic {
    if (!_seConfDataDic) {
        _seConfDataDic = @{UVService:@[UVConfig,UVData],THService:@[THConfig,THData],PrService:@[PrConfig,PrData]};
    }
    return _seConfDataDic;
}
@end
