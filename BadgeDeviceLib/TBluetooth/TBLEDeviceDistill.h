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
/*!
 *	@brief 设备有没有准备好数据读取
 */
@property (nonatomic, assign, readonly) BOOL isReady;

@property (nonatomic, assign, readonly) NSUInteger battery;
@property (nonatomic, strong, readonly) NSMutableArray<TBLEDeviceRawData *> *historyData;

- (BOOL)startDistill;
- (void)distillData;
- (BOOL)timeCalibration;

- (id)initWithDevice:(TBLEDevice *)device;
@end
