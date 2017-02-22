//
//  TBLEManager.h
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBCentralManager, CBPeripheral;
@class TBLEDevice;

/*!
 *	@brief 蓝牙管理器工具
 */
@interface TBLEManager : NSObject
/// 系统提供的管理工具
@property (nonatomic, strong, readonly) CBCentralManager *manager;
/// 已经知道的设备
@property (nonatomic, strong, readonly) NSMutableDictionary <CBPeripheral *,TBLEDevice *> *devices;

/// 接收连接变化时系统提供的通知
@property (nonatomic, assign) BOOL alertConnect;    // default is YES

/// 通过单例模式避免重复创建多个蓝牙设备管理器工具
+ (instancetype)sharedManager;

/// 打开,此处的打开只是意味着工作流程的打开,并不是蓝牙功能的打开,内部定时器的调用,会根据设置去自动连接设备
- (void)turnON;
/// 关闭,此处的关闭只是意味着工作流程的关闭,并不是蓝牙功能的关闭,会断开所有设备的连接
- (void)turnOFF;

/*!
 *	@brief 改变设备连接的接口
 *
 *	@param conn	是否要连接设备
 *	@param peri	设备
 */
- (void)connect:(BOOL)conn to:(CBPeripheral *)peri;
@end
