//
//  TBLENotification.h
//  BadgeDevice
//
//  Created by MX on 2016/10/27.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef TBLENotification_h
#define TBLENotification_h

/*!
 *	@brief 蓝牙管理器状态更改
 */
extern NSString * const kBLENotiManagerStatusChanged;

/*!
 *	@brief 蓝牙管理器设备数变化
 */
extern NSString * const kBLENotiManagerDeviceChanged;

/*!
 *	@brief 设备状态变化，可能是连接变化或者是准备状态变化
 */
extern NSString * const kBLENotiDeviceStatusChanged;

/*!
 *	@brief 读取到设备的Mac地址
 */
extern NSString * const kBLENotiDeviceMacAddrReaded;

/*!
 *	@brief 设备的工具准备好工作状态
 */
extern NSString * const kBLENotiDeviceToolPrepared;

/*!
 *	@brief 设备当前数据更新
 */
extern NSString * const kBLENotiDeviceDataUpdate;

///设备历史数据读取完成
extern NSString * const kBLENotiDeviceHistoryDataReadCompletion;

#endif /* TBLENotification_h */
