//
//  TBLEDevice.h
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;
@class TBLEData;

@interface TBLEDevice : NSObject
@property (nonatomic, strong, readonly) CBPeripheral *peri;
@property (nonatomic, strong) NSDictionary *advertise;

/// 状态信息
@property (nonatomic, strong, readonly) NSString *macAddress;
@property (nonatomic, strong, readonly) NSString *softwareVersion;
@property (nonatomic, assign, readonly) short powerQ;

/// 当前设备的数据
@property (nonatomic, strong, readonly) TBLEData *data;

- (id)initWithPeripheral:(CBPeripheral *)peri;
@end
