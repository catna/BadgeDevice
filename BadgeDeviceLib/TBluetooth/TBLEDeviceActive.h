//
//  TBLEDeviceActive.h
//  BadgeDevice
//
//  Created by MX on 2016/11/9.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBCharacteristic, CBPeripheral;
@class TBLEDeviceRawData, TBLEDevice;

@interface TBLEDeviceActive : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *,CBCharacteristic *> *characteristics;

@property (nonatomic, assign) BOOL notify;

@property (nonatomic ,strong, readonly) TBLEDeviceRawData *currentRawData;/**< 当前数据*/

- (void)updateData:(CBCharacteristic *)characteristic;
- (void)store:(CBCharacteristic *)characteristic
         peri:(CBPeripheral *)peri;

- (id)initWithDevice:(TBLEDevice *)device;
@end
