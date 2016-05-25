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

CB_EXTERN NSString *const kTBLENotificationDataUpdate;/**< 数据更新的通知*/
CB_EXTERN NSString *const kTBLENotificationReadMacAddress;/**< 读取到设备mac地址*/
CB_EXTERN NSString *const kTBLENotificationDisConnect;/** <连接断开的通知,决定之后的操作*/

@interface TBluetooth : NSObject
@property (nonatomic ,strong ,readonly) BabyBluetooth *babyBluetooth;/**<babyBluetooth tool*/
@property (nonatomic ,strong ,readonly) NSMutableDictionary <CBPeripheral *,TBLEDevice *> *devicesDic;


+ (instancetype)sharedBluetooth;

- (void)scanAndConnect:(BOOL)autoSearch;

///改变数据通道的开关
- (void)dataGalleryOpen:(BOOL)open peri:(CBPeripheral *)peri service:(CBService *)service;

@end
