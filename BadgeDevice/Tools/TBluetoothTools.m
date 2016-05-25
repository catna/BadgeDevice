//
//  TBluetoothTools.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetoothTools.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBLEDefine.h"

@implementation TBluetoothTools
+ (NSString *)macWithCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic.value) {
        NSString *value = [NSString stringWithFormat:@"%@", characteristic.value];
        NSMutableString *macString = [[NSMutableString alloc] init];
        int rangs[6] = {1,3,5,12,14,16};
        for (int i = 5; i >= 0; i--) {
            [macString appendString:[[value substringWithRange:NSMakeRange(rangs[i], 2)] uppercaseString]];
            [macString appendString:@":"];
        }
        return [macString substringToIndex:macString.length - 1];
    }
    return @"";
}


/** 先写入 0x01 到 config 的 characteristic 中，之后再去 data 的 characteristic 去读取数据 */
+ (void)writeValueForCBPeripheral:(CBPeripheral *)peripheral CBCharacteristic:(CBCharacteristic *)characteristic {
    Byte b = 0x01;
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

@end


