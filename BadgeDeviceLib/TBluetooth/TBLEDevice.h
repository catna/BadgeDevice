//
//  TBLEDevice.h
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBPeripheral, CBCharacteristic, CBService;
@class TBLEDeviceRawData, TBLEDeviceDistill, TBLEDeviceActive;

@protocol TBLEDeviceDataWagon <NSObject>
@optional
/*!
 *	@brief 存下Characteristic
 *
 *	@param service          service
 *	@param peripheral		device peripheral
 */
- (void)storeCharacteristicInService:(CBService *)service
                       peri:(CBPeripheral *)peripheral;

/*!
 *	@brief 搬运Characteristic的数据
 *
 *	@param characteristic	更新的Characteristic
 *	@param peripheral			设备
 */
- (void)carryCharacteristic:(CBCharacteristic *)characteristic
                       peri:(CBPeripheral *)peripheral;

@end

@interface TBLEDevice : NSObject
@property (nonatomic, strong, readonly) CBPeripheral *peri;
@property (nonatomic, strong, readonly) NSDate *discoveryTime;
@property (nonatomic, strong, readonly) NSDictionary *advertisementData;
@property (nonatomic, copy, readonly) NSString *macAddr;

/*!
 *	@brief 是否准备好设备的状态，包括mac地址等等
 */
@property (nonatomic, assign, readonly) BOOL isReady;

@property (nonatomic, weak) id<TBLEDeviceDataWagon> dataWagon;

- (id)initWithPeri:(CBPeripheral *)peri;
@end
