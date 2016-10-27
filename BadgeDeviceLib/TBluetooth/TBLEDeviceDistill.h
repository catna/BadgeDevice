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
@property (nonatomic, weak) TBLEDevice *device;

@property (nonatomic, strong) CBCharacteristic *historyDataCharacteristic;
@property (nonatomic, strong) CBCharacteristic *timeCalibrateCharacteristic;

@property (nonatomic, assign, readonly) NSUInteger battery;
@property (nonatomic, strong, readonly) TBLEDeviceRawData *historyRawData;
/*!
 *	@brief 用于记录历史数据，交给trace工具调用
 */
@property (nonatomic, strong) void (^historyDataReaded)(TBLEDeviceRawData *historyRawData);

- (BOOL)startDistill;
- (void)distillData;
- (BOOL)timeCalibration;

@end
