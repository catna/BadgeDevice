//
//  BadgeDeviceManager.h
//  BadgeDevice
//
//  Created by MX on 2016/11/14.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BadgeDevice;
@interface BadgeDeviceManager : NSObject

/*!
 *	@brief key:设备mac地址
 */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, BadgeDevice *> *devices;

+ (instancetype)sharedManager;
- (void)scan:(BOOL)enable;
@end
