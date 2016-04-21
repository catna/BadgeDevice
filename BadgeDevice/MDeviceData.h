//
//  MDeviceData.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
///设备数据模型
@interface MDeviceData : NSObject
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *macAddress;
@property (nonatomic ,copy) NSString *UVLe, *UVNu, *pres, *humi, *temp;
@property (nonatomic ,strong) NSDate *time;
@end
