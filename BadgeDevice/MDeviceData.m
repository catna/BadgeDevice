//
//  MDeviceData.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MDeviceData.h"

@implementation MDeviceData
- (NSString *)generateShowText {
    NSString *string = [NSString stringWithFormat:@"设备名:%@\nMac地址:%@\n当前数据:\n气压:%@",self.name,self.macAddress,self.pres];
    
    return string;
}

@end
