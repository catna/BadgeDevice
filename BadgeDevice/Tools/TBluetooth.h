//
//  TBluetooth.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class BabyBluetooth;
@class TBLEDevice;

@interface TBluetooth : NSObject
@property (nonatomic ,strong ,readonly) NSMutableDictionary <CBPeripheral *,TBLEDevice *> *devicesDic;

/*!
 *	初始化一个单例就可以打开蓝牙的相关东西了
 */
+ (instancetype)sharedBluetooth;

/*!
 *	@brief 开始扫描设备，并且连接设备
 */
- (void)scanAndConnect;

/*!
 *	@brief 断开指定设备
 *
 */
- (void)removeDevice:(TBLEDevice *)device;
/*!
 *	@brief 停止蓝牙功能相关的运行
 */
- (void)stop;

@end
