//
//  TBLETools.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 *	@brief 是一个数据格式转换的工具
 */
@interface TBLETools : NSObject
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

#pragma mark - calculator
+ (double)calculatorHumi:(double)humi;
+ (double)calculatorTemp:(double)temp;
+ (double)calculatorPres:(double)pres;
+ (double)calculatorUvLe:(double)uvle;
@end

@interface TBLETools (History)
/*!
 *	@brief 制造一个满足文档中需要写入的当前时间的数据
 *  BYTE0：年
 *  BYTE1：月
 *  BYTE2：日
 *  BYTE3：时
 *  BYTE4：分
 *  BYTE5~7：保留
 */
+ (NSData *)createCurrentTimeData;

/*!
 *	@brief 读取数据时间信息
 *	数据读取每次返回16个字节。
 *	其中，
 *	BYTE0：年
 *	BYTE1：月
 *	BYTE2：日
 *	BYTE3：时
 *	BYTE4：分
 *	BYTE5：紫外线
 *	BYTE6~7：温度
 *	BYTE8~9：湿度
 *
 *	@param dateBytes	必须返回的是16位的char数组
 *
 *	@return 返回解析好的时间，可能为nil
 */
+ (NSDate *)parseHistoryDate:(const char *)dateBytes;
@end
