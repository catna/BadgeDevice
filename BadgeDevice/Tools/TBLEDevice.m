//
//  TBLEDevice.m
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDevice.h"

@implementation TBLEDevice
- (void)clearAllPropertyData {
    self.name = nil;
    self.macAddr = nil;
    self.peri = nil;
}
@end
