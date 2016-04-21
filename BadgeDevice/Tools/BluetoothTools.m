//
//  BluetoothTools.m
//  weather-Swift
//
//  Created by MX on 16/2/26.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "BluetoothTools.h"

@implementation BluetoothTools
#pragma mark - 计算各项指数的公式
/**
 *  计算 UV 指数
 *
 *  @param uvDec 已经转换为十进制的读数
 *
 *  @return UV 指数
 */
+ (NSString *)calculateUV:(int)uvDec {
    float u0 = (uvDec *3.0) / 128;	// u0 为输出电压
    if (u0 <= 0.99) {	// u0 小于等于0.99时，认为 uv 指数为0
        return @"0";
    }
    float uv = (u0 - 0.99) * 10 / (2.2 - 1);
    //	long uvRint = lrintf(uv);	// 四舍五入 uv 指数
//    int uvRint = (int)(uv + 0.5);	// 四舍五入 uv 指数
    return [NSString stringWithFormat:@"%f", uv];
}

/**
 *  使用 UV 指数计算暴晒级数
 *
 *  @param uv UV 指数
 *
 *  @return 暴晒级数（包括1、2、3、4、5）
 */
+ (NSString *)calculateUVLevel:(float)uv {
    if (0 <= uv && uv <= 0.5) {
        return @"1";	// 一级，最弱
    }
    else if (0.5 < uv && uv <= 1) {
        return @"2";	// 二级，弱
    }
    else if (1 < uv && uv <= 1.75) {
        return @"3";	// 三级，中等
    }
    else if (1.75 < uv && uv <= 3) {
        return @"4";	// 四级，强
    }
    else if (uv > 3) {
        return @"5";	// 五级，很强
    } else {
        return @"0";
    }
}

/** 计算温度，单位摄氏度 */
+ (NSString *)calculateTemp:(int)tempDec {
    float temp = -46.85 + 175.72 * tempDec / 65536;	// 65536 为 2^16
    return [NSString stringWithFormat:@"%.1f", temp];
}

/** 计算湿度，已为百分制 */
+ (NSString *)calculateHum:(int)humDec {
    float hum = -6 + 125.0 * humDec / 65536;
    return [NSString stringWithFormat:@"%.1f", hum];
}

@end
