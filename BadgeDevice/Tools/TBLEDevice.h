//
//  TBLEDevice.h
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;
@interface TBLEDevice : NSObject
@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSString *macAddr;
@property (nonatomic ,strong) CBPeripheral *peri;

- (void)clearAllPropertyData;
@end
