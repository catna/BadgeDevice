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

#pragma mark - private methods
- (void)eNotiDeviceChanged {
    NSArray *devices = [[[TBluetooth sharedBluetooth] devicesDic] allValues];
    for (TBLEDevice *device in devices) {
        if (![self.devices.allKeys containsObject:device]) {
            BadgeDevice *dev = [[BadgeDevice alloc] initWithDevice:device];
            [self.devices setObject:dev forKey:device];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiBadgeDeviceManagerDeviceChanged object:nil];
}

#pragma mark - getter
- (NSMutableDictionary<TBLEDevice *,BadgeDevice *> *)devices {
    if (!_devices) {
        _devices = [[NSMutableDictionary alloc] init];
    }
    return _devices;
}

@end
