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
@property (nonatomic, assign, readonly) BOOL powon;

/// 通过单例模式避免重复创建多个蓝牙设备管理器工具
+ (instancetype)sharedManager;

/// 打开, 此处的打开只是意味着工作流程的打开,并不是蓝牙功能的打开
- (void)turnON;
/// 关闭, 此处的关闭只是意味着工作流程的关闭,并不是蓝牙功能的关闭, 关闭之后会移除所有已经搜索到的设备, 但是重新打开并不能连接到之前连接到的设备,需要关闭蓝牙重新打开重新搜索连接
- (void)turnOFF;
@end
