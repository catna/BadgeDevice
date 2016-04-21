//
//  TBluetooth.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBPeripheral;
///设备模型
@interface TBluetoothDevice : NSObject
@property (nonatomic ,copy  ) NSString     *name;
@property (nonatomic ,copy  ) NSString     *macAddress;
@property (nonatomic ,strong) CBPeripheral *peripheral;
@end

extern NSString *const kTBluetoothConnectSuccess;
extern NSString *const kTBluetoothDisConnect;

struct DeviceData {
    CFTypeRef UVNu;
    CFTypeRef UVLe;
    CFTypeRef pres;
    CFTypeRef humi;
    CFTypeRef temp;
};

@interface TBluetooth : NSObject
@property (nonatomic ,strong ,readonly) TBluetoothDevice *device;

+ (instancetype)sharedBluetooth;

- (void)connect;
- (void)cancelConnecting;

- (void)readDataWithUpdateHandler:(void (^)(struct DeviceData))handler notify:(BOOL)notify;
@end