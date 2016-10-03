//
//  DataStoreTool.m
//  BadgeDevice
//
//  Created by MX on 2016/10/2.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "DataStoreTool.h"
#import "MDeviceData.h"
#import "TDataManager.h"
#import <BadgeDeviceLib/TBluetooth.h>
#import <BadgeDeviceLib/TBLEDevice.h>
#import <BadgeDeviceLib/TBLEDefine.h>

@interface DataStoreTool()
@property (nonatomic, strong) NSMutableArray<TBLEDevice *> *deviceArray;
@property (nonatomic, strong) NSMutableArray<MDeviceData *> *dataArray;
@end

@implementation DataStoreTool {
    NSUInteger _storeCount;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (instancetype)sharedTool {
    static id tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[[self class] alloc] init];
    });
    return tool;
}

- (BOOL)traceADevice:(TBLEDevice *)device {
    if (device) {
        weakify(self);
        weakify(device);
        if (![self.deviceArray containsObject:device]) {
            [self.deviceArray addObject:device];
        }
        device.DataUpdateHandler = ^(BOOL dataValidity){
            if (dataValidity) {
                strongify(self);
                strongify(device);
                if (_storeCount >= 4) {
                    [self storeDeviceData:device];
                    _storeCount = 0;
                }
                _storeCount ++;
            }
        };
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)cancelTraceDevice:(TBLEDevice *)device {
    if (device && [self.deviceArray containsObject:device]) {
        device.DataUpdateHandler = nil;
        [self.deviceArray removeObject:device];
        return YES;
    } else {
        return NO;
    }
}

- (void)storeDeviceData:(TBLEDevice *)device {
    if (self.dataArray.count >= 10) {
        [[TDataManager sharedDataManager] saveContext];
        [self.dataArray removeAllObjects];
    }
    MDeviceData *d = [NSEntityDescription insertNewObjectForEntityForName:@"MDeviceData" inManagedObjectContext:[[TDataManager sharedDataManager] managedObjectContext]];
    d.time = [NSDate date];
    d.pres = device.currentRawData.Pres;
    d.humi = device.currentRawData.Humi;
    d.temp = device.currentRawData.Temp;
    d.uvle = device.currentRawData.UVLe;
    d.macAddress = device.macAddr;
    [self.dataArray addObject:d];
}

#pragma mark - getter
- (NSMutableArray<TBLEDevice *> *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [[NSMutableArray alloc] init];
    }
    return _deviceArray;
}

- (NSMutableArray<MDeviceData *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _dataArray;
}

@end
