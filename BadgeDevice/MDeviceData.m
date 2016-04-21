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
    NSString *string = [NSString stringWithFormat:@"设备名:%@\nMac地址:%@\n当前数据:\n气压:%@\n温度:%@\n湿度:%@\n",self.name,self.macAddress,self.pres,self.temp,self.humi];
    
    return string;
}

@end
