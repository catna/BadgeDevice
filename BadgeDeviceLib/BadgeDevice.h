//
//  BadgeDevice.h
//  BadgeDevice
//
//  Created by MX on 2016/11/10.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBLEDevice.h"
@class TBLEDeviceDistill, TBLEDeviceActive;

@interface BadgeDevice : NSObject<TBLEDeviceDataWagon>
@property (nonatomic, strong, readonly) TBLEDevice *device;
@property (nonatomic, strong, readonly) TBLEDeviceDistill *distillTool;
@property (nonatomic, strong, readonly) TBLEDeviceActive *activeTool;

- (id)initWithDevice:(TBLEDevice *)device;

- (BOOL)notifyCurrentData:(BOOL)enable;

- (BOOL)readHistoryData;

- (BOOL)resetTime;
@end
