//
//  TBLEData.h
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>

///设备数据
@interface TBLEData : NSObject
// 数据的类型
/// 数据是否可用
@property (nonatomic, assign, readonly) BOOL useful; // default is NO

// 数据详情
/// 日期
@property (nonatomic, strong) NSDate *date;
/// 温度
@property (nonatomic, assign) double temp;
/// 湿度
@property (nonatomic, assign) double humi;
/// 气压
@property (nonatomic, assign) double pres;
/// 紫外线(紫外线等级可以依靠工具方法进行转换, 没必要丢失原始的数据)
@property (nonatomic, assign) double uvNu;

/*!
 *	@brief 显示这个对象的数据详情
 */
- (NSString *)represent;
@end
