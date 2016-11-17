//
//  BadgeDeviceManager.h
//  BadgeDevice
//
//  Created by MX on 2016/11/14.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBLEDevice, BadgeDevice;
@interface BadgeDeviceManager : NSObject
/*!
 *	@brief 这些都是已连接，有mac地址的设备
 */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, BadgeDevice *> *devices;

+ (instancetype)sharedManager;
- (void)scan:(BOOL)enable;
- (void)cancelConnect:(BadgeDevice *)dev;
- (void)reconnectAll;
@end
