//
//  TBluetoothTools.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBluetooth.h"
@class CBCharacteristic;

@interface TBluetoothTools : NSObject
+ (NSString *)macWithCharacteristic:(CBCharacteristic *)characteristic;

/** 先写入 0x01 到 config 的 characteristic 中，之后再去 data 的 characteristic 去读取数据 */
+ (void)writeValueForCBPeripheral:(CBPeripheral *)peripheral CBCharacteristic:(CBCharacteristic *)characteristic;
@end

@interface TBluetoothTools (DataConvert)
/*!
 *	@brief 返回数据单位百帕斯卡
 *
 *	@param data	从蓝牙端获取的数据，length是6的那个
 *
 *	@return 例如: 1008.78
 */
+ (double)convertPresData:(NSData *)data;

/*!
 *	@brief 返回湿度信息
 */
+ (double)convertHumiData:(NSData *)data;

/*!
 *	@brief 返回温度信息
 */
+ (double)convertTempData:(NSData *)data;

/*!
 *	@brief 返回紫外线信息
 */
+ (double)convertUVNuData:(NSData *)data;

/*!
 *	@brief 返回紫外线强度信息
 */
+ (int)matchUVLeWithUVNu:(double)UVNu;
@end