//
//  TBLENoti.h
//  BadgeDevice
//
//  Created by MX on 2017/2/22.
//  Copyright © 2017年 mx. All rights reserved.
//

#ifndef TBLENoti_h
#define TBLENoti_h

/*!
 *	@brief 通知相关状态改变.
 *  @discussion 这些附带的object都不可以全部信赖,要加上自己的判断以提高健壮性
 *              当是蓝牙管理器的状态更改时,例如电源状态改变等(用户更改了电源开关),则附带的object为nil
 *              当是蓝牙设备断开或连接的时候,这个附带的object是外围设备CBPeripheral
 *              当时信号强度变更的时候,附带的是TBLEDevice
 */
extern NSString *const kTBLENotiStatusChanged;

/*!
 *	@brief 通知设备的数据更新
 *  @discussion 设备当前数据更新,会附带对象以加快访问.TBLEDevice
 *              同样的,不要完全信赖会传来一个方便调用的对象
 */
extern NSString *const kTBLENotiDataChanged;

/// 通知读取到新的历史数据

/*!
 *	@brief 通知读取到设备的历史数据
 *  @discussion 读取到设备的历史数据,会附带对象以加快访问.TBLEDevice
 *              同样的,不要完全信赖会传来一个方便调用的对象
 */
extern NSString *const kTBLENotiHistoryDataReaded;

#endif /* TBLENoti_h */
