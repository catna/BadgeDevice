//
//  TBluetoothTools.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 *	@brief 是一个数据格式转换的工具
 */
@interface TBluetoothTools : NSObject
/*!
 *	@brief 把 characteristic 的 value 转换为 mac 地址的字符串
 *
 *	@param macData	characteristic 的 value
 *
 *	@return 如果参数是空，返回的是空字符串
 */
+ (NSString *)macWithCharacteristicData:(NSData *)macData;

/*!
 *	@brief 返回数据单位百帕斯卡
 *
 *	@param data	从蓝牙端获取的数据，length是6的那个
 *
 *	@return 例如: 1008.78
 */
+ (double)convertPresData:(NSData *)data;

/*!
 *	@brief 返回湿度信息
 */
+ (double)convertHumiData:(NSData *)data;

/*!
 *	@brief 返回温度信息
 */
+ (double)convertTempData:(NSData *)data;

/*!
 *	@brief 返回紫外线信息
 */
+ (double)convertUVNuData:(NSData *)data;

/*!
 *	@brief 返回紫外线强度信息
 */
+ (int)matchUVLeWithUVNu:(double)UVNu;
@end