//
//  BadgeDevice.m
//  BadgeDevice
//
//  Created by MX on 2016/11/10.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "BadgeDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBluetooth/TBLEDefine.h"
#import "TBluetooth/TBLEDeviceDistill.h"
#import "TBluetooth/TBLEDeviceActive.h"

@interface BadgeDevice ()
@property (nonatomic, strong) NSDictionary <NSString *,NSArray<NSString *>*>* seConfDataDic;
@end

@implementation BadgeDevice
@synthesize device = _device;
@synthesize activeTool = _activeTool;
@synthesize distillTool = _distillTool;

- (id)initWithDevice:(TBLEDevice *)device {
    if (self = [super init]) {
        _device = device;
        _activeTool = [[TBLEDeviceActive alloc] initWithDevice:_device];
        _distillTool = [[TBLEDeviceDistill alloc] initWithDevice:_device];
        _device.dataWagon = self;
    }
    return self;
}

- (id)init {
    NSLog(@"BadgeDevice:Please use init with device method");
    abort();
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
