//
//  TBluetoothTools.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetoothTools.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation TBluetoothTools
+ (NSString *)macWithCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic.value) {
        NSString *value = [NSString stringWithFormat:@"%@", characteristic.value];
        NSMutableString *macString = [[NSMutableString alloc] init];
        [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
        [macString appendString:@":"];
        [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
        return macString;	// 如：00:E0:4C:3F:14:DE
    }
    return @"";
}

@end
