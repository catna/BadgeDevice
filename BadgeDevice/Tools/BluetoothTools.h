//
//  BluetoothTools.h
//  weather-Swift
//
//  Created by MX on 16/2/26.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
///这是一个bluetooth工具
@interface BluetoothTools : NSObject
/**
 *  计算 UV 指数
 *
 *  @param uvDec 已经转换为十进制的读数
 *
 *  @return UV 指数
 */
+ (NSString *)calculateUV:(int)uvDec;

/**
 *  使用 UV 指数计算暴晒级数
 *
 *  @param uv UV 指数
 *
 *  @return 暴晒级数（包括1、2、3、4、5）
 */
+ (NSString *)calculateUVLevel:(float)uv;

/** 计算温度，单位摄氏度 */
+ (NSString *)calculateTemp:(int)tempDec;

/** 计算湿度，已为百分制 */
+ (NSString *)calculateHum:(int)humDec;

@end
