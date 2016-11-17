//
//  BadgeDeviceManager.m
//  BadgeDevice
//
//  Created by MX on 2016/11/14.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "BadgeDeviceManager.h"
#import "BadgeDevice.h"
#import "TBLENotification.h"
#import "TBLEDevice.h"
#import "TBluetooth.h"

#import "BadgeDeviceNotification.h"

@interface BadgeDeviceManager ()
@property (nonatomic, strong) NSMutableDictionary<NSDate *,BadgeDevice *> *devArray;
@end

@implementation BadgeDeviceManager
@synthesize devices = _devices;

+ (instancetype)sharedManager {
    static id shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[BadgeDeviceManager alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eNotiDeviceChanged) name:kBLENotiManagerDeviceChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eNotiDeviceChanged) name:kBLENotiDeviceStatusChanged object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public methods
- (void)scan:(BOOL)enable {
    if (enable) {
        [[TBluetooth sharedBluetooth] scanAndConnect:YES];
    } else {
        [TBluetooth sharedBluetooth].autoSearchEnable = NO;
    }
}

- (void)cancelConnect:(BadgeDevice *)dev {
    [[TBluetooth sharedBluetooth] connect:NO peri:dev.device.peri];
}

- (void)reconnectAll {
    for (BadgeDevice *d in self.devArray.allValues) {
        [[TBluetooth sharedBluetooth] connect:YES peri:d.device.peri];
    }
}

#pragma mark - private methods
- (void)eNotiDeviceChanged {
    NSArray *devices = [[[TBluetooth sharedBluetooth] devicesDic] allValues];
    for (TBLEDevice *device in devices) {
        if (![self.devArray.allKeys containsObject:device.discoveryTime]) {
            BadgeDevice *d = [[BadgeDevice alloc] initWithDevice:device];
            [self.devArray setObject:d forKey:device.discoveryTime];
        }
    }
    [self showMacDev];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiBadgeDeviceManagerDeviceChanged object:nil];
}

- (void)showMacDev {
    for (BadgeDevice *dev in self.devArray.allValues) {
        if (dev.device.macAddr && dev.device.isReady) {
            [self.devices setObject:dev forKey:dev.device.macAddr];
        } else if (dev.device.macAddr) {
            [self.devices removeObjectForKey:dev.device.macAddr];
        }
    }
}

#pragma mark - getter
- (NSMutableDictionary<NSString *,BadgeDevice *> *)devices {
    if (!_devices) {
        _devices = [[NSMutableDictionary alloc] init];
    }
    return _devices;
}

- (NSMutableDictionary<NSDate *,BadgeDevice *> *)devArray {
    if (!_devArray) {
        _devArray = [[NSMutableDictionary alloc] init];
    }
    return _devArray;
}

@end
