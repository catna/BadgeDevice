//
//  TBLEManager.h
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBCentralManager, CBPeripheral;
@class TBLEDevice;
@interface TBLEManager : NSObject

@property (nonatomic, strong, readonly) CBCentralManager *manager;
@property (nonatomic, strong, readonly) NSMutableDictionary <CBPeripheral *,TBLEDevice *> *devices;
@property (nonatomic, assign, readonly) BOOL powon;

+ (instancetype)sharedManager;

- (void)turnON;
- (void)turnOFF;
@end
