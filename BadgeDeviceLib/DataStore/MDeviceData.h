//
//  MDeviceData.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

///设备数据模型
@interface MDeviceData : NSManagedObject
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *macAddress;
@property (nonatomic ,copy) NSString *uvle, *uvnu, *pres, *humi, *temp;
@property (nonatomic ,strong) NSDate *time;

@property (nonatomic, copy) NSString *latitude, *longitude, *locationTimeStamp;

- (NSString *)generateShowText;

@end
