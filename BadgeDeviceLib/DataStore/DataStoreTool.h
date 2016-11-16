//
//  DataStoreTool.h
//  BadgeDevice
//
//  Created by MX on 2016/10/2.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDeviceData;

@interface DataStoreTool : NSObject
+ (instancetype)sharedTool;
/*!
 *	@brief 创建一个可以保存数据的对象模型
 *
 *	@return 返回上述模型
 */
- (MDeviceData *)createAModelToFill;

/*!
 *	@brief 保存当前模型
 */
- (void)save;

/*!
 *	@brief 获取存储的数据
 *
 *	@param timeInterval	当参数为0的时候取出所有的数据，不为0是取出距离现在时间N秒的数据
 *
 *	@return 返回数据，可能为nil
 */
- (NSArray<MDeviceData *> *)readDataWith:(NSTimeInterval)timeInterval;
@end
