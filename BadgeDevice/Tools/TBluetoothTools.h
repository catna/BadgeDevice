//
//  TBluetoothTools.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBCharacteristic;

@interface TBluetoothTools : NSObject
+ (NSString *)macWithCharacteristic:(CBCharacteristic *)characteristic;
@end
