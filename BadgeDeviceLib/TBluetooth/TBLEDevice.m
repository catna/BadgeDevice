//
//  TBLEDevice.m
//  BadgeDevice
//
//  Created by MX on 16/5/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBLEDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <objc/runtime.h>
#import <BabyBluetooth.h>

#import "TBLEDefine.h"
#import "TBluetoothTools.h"
#import "TBluetooth.h"
#import "TBLEDeviceRawData.h"
#import "TBLENotification.h"

@interface TBLEDevice ()

@end

@implementation TBLEDevice
@synthesize peri = _peri;
@synthesize advertisementData = _advertisementData;
@synthesize macAddr = _macAddr;
@synthesize isReady = _isReady;

- (void)notificationWithName:(NSString *)name {
    if (self.selected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
    }
}

- (void)decideIsReady {
    if (self.peri && self.peri.state == CBPeripheralStateConnected && self.macAddr) {
        self.isReady = YES;
    } else {
        self.isReady = NO;
    }
}

#pragma mark - setter

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    BabyBluetooth *BLE = [[TBluetooth sharedBluetooth] valueForKeyPath:@"babyBluetooth"];
    if (_selected && !(self.peri.state == CBPeripheralStateConnected)) {
        [[TBluetooth sharedBluetooth] connect:YES peri:self.peri];
    }
    _selected ? [BLE AutoReconnect:self.peri] : [BLE AutoReconnectCancel:self.peri];
    if (!_selected) {
        [BLE cancelPeripheralConnection:self.peri];
    }
}

- (void)setIsReady:(BOOL)isReady {
    _isReady = isReady;
    [self notificationWithName:kBLENotiDeviceStatusChanged];
}

- (void)setMacAddr:(NSString *)macAddr {
    _macAddr = [macAddr mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiDeviceMacAddrReaded object:self];
    [self decideIsReady];
}

#pragma mark - getter


@end
