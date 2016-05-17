//
//  TBluetooth.h
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BabyBluetooth;
@class TBLEDevice;

struct DeviceData {
    CFTypeRef UVNu;
    CFTypeRef UVLe;
    CFTypeRef pres;
    CFTypeRef humi;
    CFTypeRef temp;
};

@interface TBluetooth : NSObject
@property (nonatomic ,strong ,readonly) TBLEDevice *device;/**<current connect device*/
@property (nonatomic ,strong ,readonly) BabyBluetooth *babyBluetooth;/**<babyBluetooth tool*/

+ (instancetype)sharedBluetooth;

- (void)scanAndConnectWithMacAddrList:(NSArray <NSString *>*)macAddrList;
/////--------
- (void)cancelConnecting;

- (void)readDataWithUpdateHandler:(void (^)(struct DeviceData))handler notify:(BOOL)notify;
@end
