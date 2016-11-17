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

/*!
 *	@brief 这个是设备是否属于手机，并且有权限重新连接的一个凭证，在网络端申请进行一下判断，当这个值为NO的时候，会自动断掉这个设备的连接;当为YES的时候，会设置该设备为自动重连状态
 */
//@property (nonatomic, assign) BOOL selected;

@property (nonatomic, weak) id<TBLEDeviceDataWagon> dataWagon;

- (id)initWithPeri:(CBPeripheral *)peri;
@end
