//
//  BluetoothReadWriteHelper.m
//  weather-Swift
//
//  Created by MX on 16/2/26.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "BluetoothReadWriteHelper.h"
#import "StringTool.h"
#import "BluetoothTools.h"
#import "BabyToy.h"

@implementation BluetoothReadWriteHelper
+ (NSString *)stringPressureWithValue:(NSData *)value {
    NSString *valueStr = [NSString stringWithFormat:@"%@",value];
    NSString *prHex = [NSString stringWithFormat:@"0x%@%@%@", [valueStr substringWithRange:NSMakeRange(12, 2)],[valueStr substringWithRange:NSMakeRange(10, 2)],[valueStr substringWithRange:NSMakeRange(7, 2)]];
    NSString *pressureHpa = [NSString stringWithFormat:@"%.1f",[[StringTool stringFromHexString:prHex] floatValue]/100.0];
    return pressureHpa;
}

+ (NSString *)stringHumiWithValue:(NSData *)value {
    NSString *valueStr = [NSString stringWithFormat:@"%@",value];
    NSString *humHex = [NSString stringWithFormat:@"%@%@", [valueStr substringWithRange:NSMakeRange(7, 2)], [valueStr substringWithRange:NSMakeRange(5, 2)]];
    return [BluetoothTools calculateHum:[[StringTool stringFromHexString:humHex] intValue]];
}

+ (NSString *)stringTempWithValue:(NSData *)value {
    NSString *valueStr = [NSString stringWithFormat:@"%@",value];
    // 计算温度
    NSString *tempHex = [NSString stringWithFormat:@"%@%@", [valueStr substringWithRange:NSMakeRange(3, 2)], [valueStr substringWithRange:NSMakeRange(1, 2)]];	// 十六进制的温度
    return [BluetoothTools calculateTemp:[[StringTool stringFromHexString:tempHex] intValue]];
}

+ (NSString *)stringUVWithValue:(NSData *)value {
    NSString *uvIndex = [BluetoothTools calculateUV:[BabyToy ConvertDataToInt:value]];
    return uvIndex;
}

+ (NSString *)stringUVLevelWithValue:(NSData *)value {
    NSString *uvIndex = [BluetoothTools calculateUV:[BabyToy ConvertDataToInt:value]];
    return [BluetoothTools calculateUVLevel:[uvIndex floatValue]];
}
@end
