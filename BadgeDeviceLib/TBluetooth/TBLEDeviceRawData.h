//
//  TBLEDeviceRawData.h
//  BadgeDevice
//
//  Created by MX on 2016/10/27.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBLEDeviceRawData : NSObject
/// 数据创建时间(指第一次读取到这条数据的时间)
@property (nonatomic, strong) NSDate *dataCreateTime;
/// 数据记录时间(指这条数据产生的时间)(很关键，需要保存)
@property (nonatomic, strong) NSDate *dataRecordTime;

@property (nonatomic ,strong) NSData *UVRawData;/**< 紫外线数据*/
@property (nonatomic ,strong) NSData *THRawData;/**< 温湿度数据*/
@property (nonatomic ,strong) NSData *PrRawData;/**< 大气压数据*/

@property (nonatomic, assign, readonly) BOOL dataValidity;/**< 数据有效性*/
@property (nonatomic ,strong, readonly) NSString *UVLe;
@property (nonatomic ,strong, readonly) NSString *Pres;
@property (nonatomic ,strong, readonly) NSString *Temp;
@property (nonatomic ,strong, readonly) NSString *Humi;
@end
