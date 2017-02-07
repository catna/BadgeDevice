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
@property (nonatomic, strong) NSTimer *timer;
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
    [self.timer fire];
}

- (void)turnOFF {
    [self.devices removeAllObjects];
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - event
- (void)eTimer {
    NSLog(@"eTimer");
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [self turnON];
            break;
            
        default:[self turnOFF];
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([peripheral.name isEqualToString:DeviceNameOne] || [peripheral.name isEqualToString:DeviceNameTwo]) {
        TBLEDevice *dev = [[TBLEDevice alloc] initWithPeripheral:peripheral];
        dev.advertise = advertisementData;
        [self.devices setObject:dev forKey:peripheral];
        [self.manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}


#pragma mark - getter
- (CBCentralManager *)manager {
    if (!_manager) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey:@(YES)}];
    }
    return _manager;
}

- (NSMutableDictionary <CBPeripheral *,TBLEDevice *> *)devices {
    if (!_devices) {
        _devices = [[NSMutableDictionary alloc] init];
    }
    return _devices;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:TimerWorkerFrequence target:self selector:@selector(eTimer) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
