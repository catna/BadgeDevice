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
CB_EXTERN NSString *const kTBLENotificationMatchSuccess;/**< 设备mac地址比对成功，但是不代表会一直连接这个设备*/

@interface TBluetooth : NSObject
@property (nonatomic ,strong ,readonly) TBLEDevice *device;/**<current connect device*/
@property (nonatomic ,strong ,readonly) BabyBluetooth *babyBluetooth;/**<babyBluetooth tool*/

+ (instancetype)sharedBluetooth;

- (void)scanAndConnectWithMacAddrList:(NSArray <NSString *>*)macAddrList;

- (void)setDataNotify:(BOOL)notify;

///清除数据和断开连接
- (void)cancelConn;
- (void)clear;

@end
