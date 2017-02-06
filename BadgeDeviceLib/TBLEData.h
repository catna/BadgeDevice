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
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) double temp;
@property (nonatomic, assign) double humi;
@property (nonatomic, assign) double pres;
@property (nonatomic, assign) short uvle;
@end
