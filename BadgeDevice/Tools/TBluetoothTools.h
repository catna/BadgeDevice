//
//  TBluetoothTools.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBluetooth.h"
@class CBCharacteristic;

@interface TBluetoothTools : NSObject
+ (NSString *)macWithCharacteristic:(CBCharacteristic *)characteristic;

/** 先写入 0x01 到 config 的 characteristic 中，之后再去 data 的 characteristic 去读取数据 */
+ (void)writeValueForCBPeripheral:(CBPeripheral *)peripheral CBCharacteristic:(CBCharacteristic *)characteristic;
@end
