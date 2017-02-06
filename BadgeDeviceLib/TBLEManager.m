//
//  TBLEManager.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "TBLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBLEDefine.h"
#import "TBLEDevice.h"

@interface TBLEManager () <CBCentralManagerDelegate>

@end

@implementation TBLEManager
@synthesize manager = _manager;
@synthesize devices = _devices;

+ (instancetype)sharedManager {
    static TBLEManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[TBLEManager alloc] init];
    });
    return shared;
}

- (void)turnON {
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}

- (void)turnOFF {
    [self.devices removeAllObjects];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOff:
            [self turnOFF];
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([peripheral.name isEqualToString:DeviceNameOne] || [peripheral.name isEqualToString:DeviceNameTwo]) {
        TBLEDevice *dev = [[TBLEDevice alloc] initWithPeripheral:peripheral];
        dev.advertise = advertisementData;
        [self.devices setObject:dev forKey:peripheral];
    }
}


#pragma mark - getter
- (CBCentralManager *)manager {
    if (!_manager) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{}];
    }
    return _manager;
}

- (NSMutableDictionary <CBPeripheral *,TBLEDevice *> *)devices {
    if (!_devices) {
        _devices = [[NSMutableDictionary alloc] init];
    }
    return _devices;
}

@end
