//
//  BluetoothReadWriteHelper.h
//  weather-Swift
//
//  Created by MX on 16/2/26.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

// UV
static NSString *const uvServiceUUID = @"F000AA00-0451-4000-B000-000000000000", *const uvDataUUID = @"F000AA01-0451-4000-B000-000000000000", *const uvConfigUUID = @"F000AA02-0451-4000-B000-000000000000";
// 温湿度
static NSString *const thServiceUUID = @"F000AA20-0451-4000-B000-000000000000", *const thDataUUID = @"F000AA21-0451-4000-B000-000000000000", *const thConfigUUID = @"F000AA22-0451-4000-B000-000000000000";
// 气压
static NSString *const prServiceUUID = @"F000AA40-0451-4000-B000-000000000000", *const prDataUUID = @"F000AA41-0451-4000-B000-000000000000", *const prConfigUUID = @"F000AA42-0451-4000-B000-000000000000";

///蓝牙读写小助手
@interface BluetoothReadWriteHelper : NSObject
///气压值转换(返回的是可直接给block调用的值)
+ (NSString *)stringPressureWithValue:(NSData *)value;
///湿度值转换(返回的是可直接给block调用的值)
+ (NSString *)stringHumiWithValue:(NSData *)value;
///温度值转换(返回的是可直接给block调用的值)
+ (NSString *)stringTempWithValue:(NSData *)value;
///uv值转换(返回的是可直接给block调用的值,如果是uvLevel则需要特别转换一下)
+ (NSString *)stringUVWithValue:(NSData *)value;
///uvLevel转换(返回的是可直接给block调用的值,参数如上)
+ (NSString *)stringUVLevelWithValue:(NSData *)value;
@end
