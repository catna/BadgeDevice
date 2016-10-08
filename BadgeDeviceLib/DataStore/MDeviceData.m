//
//  MDeviceData.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MDeviceData.h"

@implementation MDeviceData
@synthesize name = _name;
@synthesize humi = _humi;
@synthesize temp = _temp;
@synthesize uvle = _uvle;
@synthesize uvnu = _uvnu;
@synthesize pres = _pres;
@synthesize macAddress = _macAddress;
@synthesize time = _time;

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize locationTimeStamp = _locationTimeStamp;

- (NSString *)generateShowText {
    NSString *string = [NSString stringWithFormat:@"设备名:%@\nMac地址:%@\n\n当前数据:\n\n气压:%@hPa\n\n温度:%@°C\n\n湿度:%@%%\n\n紫外线数值:%@\n\n紫外线等级:%@\n\n",self.name,self.macAddress,self.pres,self.temp,self.humi,self.uvnu,self.uvle];
    
    return string;
}

@end
