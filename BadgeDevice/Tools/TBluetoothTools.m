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

@implementation TBluetoothTools (DataConvert)
+ (double)convertPresData:(NSData *)data {
    const void *rawData = data.bytes;
    int a = 0;
    char *b = (char *)&a;
    for (int i = 0; i < sizeof(int); i ++) {
        *(b + i) = *(char *)(rawData + 3 + i);
    }
    return (double)a/100.0;
}

+ (double)convertUVNuData:(NSData *)data {
    //rawData: <2a000000> length:4
    const void *rawData = data.bytes;
    return (double)*(int *)rawData;
}

+ (double)convertHumiData:(NSData *)data {
    //raw: <c46be29c> length:4
    const void *rawData = data.bytes;
    int a = 0;
    char *b = (char *)&a;
    for (int i = 0; i < sizeof(int); i ++) {
        *(b + i) = *(char *)(rawData + 2 + i);
    }
    return (double)a * 125.0 / 65536 - 6;
}

+ (double)convertTempData:(NSData *)data {
    const void *rawData = data.bytes;
    int a = 0;
    char *b = (char *)&a;
    for (int i = 0; i < sizeof(int); i ++) {
        *(b + i) = *(char *)(rawData + i);
    }
    return (double) a * 175.72 / 65536 - 46.85;
}

+ (int)matchUVLeWithUVNu:(double)UVNu {
    double u0 = (UVNu * 3.0) / 128;	// u0 为输出电压
    if (u0 <= 0.99) {	// u0 小于等于0.99时，认为 uv 指数为0
        return 0;
    }
    double uv = (u0 - 0.99) * 10 / (2.2 - 1);
    if (0 <= uv && uv <= 0.5) {
        return 1;	// 一级，最弱
    } else if (0.5 < uv && uv <= 1) {
        return 2;	// 二级，弱
    } else if (1 < uv && uv <= 1.75) {
        return 3;	// 三级，中等
    } else if (1.75 < uv && uv <= 3) {
        return 4;	// 四级，强
    } else if (uv > 3) {
        return 5;	// 五级，很强
    } else {
        return 0;
    }
}
@end
