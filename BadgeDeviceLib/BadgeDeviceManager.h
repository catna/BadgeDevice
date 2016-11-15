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
@property (nonatomic, strong, readonly) NSMutableDictionary<TBLEDevice *, BadgeDevice *> *devices;

+ (instancetype)sharedManager;
- (void)scan:(BOOL)enable;
@end
