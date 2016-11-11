//
//  TBLEDeviceDistill.h
//  BadgeDevice
//
//  Created by MX on 2016/10/27.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TBLEDevice, TBLEDeviceRawData, CBCharacteristic;

@interface TBLEDeviceDistill : NSObject
@property (nonatomic, weak, readonly) TBLEDevice *device;

@property (nonatomic, strong) CBCharacteristic *historyDataCharacteristic;
@property (nonatomic, strong) CBCharacteristic *timeCalibrateCharacteristic;

@property (nonatomic, assign, readonly) NSUInteger battery;
@property (nonatomic, strong, readonly) TBLEDeviceRawData *historyRawData;

- (BOOL)startDistill;
- (void)distillData;
- (BOOL)timeCalibration;

- (id)initWithDevice:(TBLEDevice *)device;
@end
