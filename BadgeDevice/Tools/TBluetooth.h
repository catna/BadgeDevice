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
/*!
 *	在想把数据更新的通知放在设备的block里面会不会好一点，这样的话可以监听单独设备的数据更新
 */
CB_EXTERN NSString *const kTBLENotificationDataUpdate;/**< 数据更新的通知*/

/*!
 *	这样可以根据这个创建一个设备的实例
 */
CB_EXTERN NSString *const kTBLENotificationReadMacAddress;/**< 读取到设备mac地址*/

/*!
 *  这样好像可以操作设备的连接断开状态
 */
CB_EXTERN NSString *const kTBLENotificationConnectingChanged;/** <连接状态变化的通知,决定之后的操作*/

@interface TBluetooth : NSObject
@property (nonatomic ,strong ,readonly) BabyBluetooth *babyBluetooth;/**<babyBluetooth tool*/
@property (nonatomic ,strong ,readonly) NSMutableDictionary <CBPeripheral *,TBLEDevice *> *devicesDic;

/*!
 *	初始化一个单例就可以打开蓝牙的相关东西了
 */
+ (instancetype)sharedBluetooth;

/*!
 *	@brief 开始扫描设备，并且连接设备
 *
 *	@param autoSearch	是否开启一直自动搜索
 */
- (void)scanAndConnect:(BOOL)autoSearch;

/*!
 *	@brief 断开指定设备
 *
 */
- (void)removeDevice:(TBLEDevice *)device;
/*!
 *	@brief 停止蓝牙功能相关的运行
 */
- (void)stop;

//我觉得这个应该放在设备里面来判定是否打开数据的通道，或者说，应该在设备里面放个接口，用来更新设备通道开关的状态
///改变数据通道的开关(因为这个设备需要写入一个0x01才可以启动数据通道)
- (void)dataGalleryOpen:(BOOL)open peri:(CBPeripheral *)peri service:(CBService *)service;

@end
