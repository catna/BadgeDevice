//
//  TBLEDevice.m
//  BadgeDevice
//
//  Created by MX on 2017/2/6.
//  Copyright © 2017年 mx. All rights reserved.
//

#import "TBLEDevice.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TBLEDefine.h"
#import "TBLETools.h"

@interface TBLEDevice () <CBPeripheralDelegate>

@end

@implementation TBLEDevice
@synthesize peri = _peri;

- (id)initWithPeripheral:(CBPeripheral *)peri {
    if (self = [super init]) {
        _peri = peri;
        _peri.delegate = self;
    }
    return self;
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *ch in service.characteristics) {
        if ([ch.UUID.UUIDString isEqualToString:MacAddrUUID]) {
            _macAddress = [TBLETools macWithCharacteristicData:ch.value];
        }
    }
}

@end
