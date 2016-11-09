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
#import "TBLEDeviceDistill.h"
#import "TBLEDeviceActive.h"
#import "TBLEDeviceRawData.h"
#import "TBLENotification.h"

@interface TBLEDevice ()
@property (nonatomic, assign) BOOL isReady;
@end

@implementation TBLEDevice
@synthesize peri = _peri;
@synthesize advertisementData = _advertisementData;
@synthesize macAddr = _macAddr;
@synthesize isConnect = _isConnect;


- (void)notificationWithName:(NSString *)name {
    if (self.selected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
    }
}

#pragma mark - setter
- (void)setIsConnect:(BOOL)isConnect {
    _isConnect = isConnect;
    [self notificationWithName:kBLENotiDeviceStatusChanged];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    BabyBluetooth *BLE = [[TBluetooth sharedBluetooth] valueForKeyPath:@"babyBluetooth"];
    if (_selected && !self.peri.state == CBPeripheralStateConnected) {
//        [BLE conn]
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
}

#pragma mark - getter


@end

static const void *TBLEDeviceDistillToolKey = "TBLEDeviceDistillToolKey";
static const void *TBLEDeviceActiveToolKey = "TBLEDeviceActiveToolKey";
@implementation TBLEDevice(DataDistill)
#pragma mark - public methods

#pragma mark - setter & getter
- (void)setDistillTool:(TBLEDeviceDistill *)distillTool {
    objc_setAssociatedObject(self, TBLEDeviceDistillToolKey, distillTool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TBLEDeviceDistill *)distillTool {
    TBLEDeviceDistill *distill = objc_getAssociatedObject(self, TBLEDeviceDistillToolKey);
    if (!distill) {
        distill = [[TBLEDeviceDistill alloc] init];
        [distill setValue:self forKey:@"device"];
        [self setDistillTool:distill];
    }
    return distill;
}

- (void)setActiveTool:(TBLEDeviceActive *)activeTool {
    objc_setAssociatedObject(self, TBLEDeviceActiveToolKey, activeTool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TBLEDeviceActive *)activeTool {
    TBLEDeviceActive *activeTool = objc_getAssociatedObject(self, TBLEDeviceActiveToolKey);
    if (!activeTool) {
        activeTool = [[TBLEDeviceActive alloc] init];
        [self setActiveTool:activeTool];
    }
    return activeTool;
}

@end
