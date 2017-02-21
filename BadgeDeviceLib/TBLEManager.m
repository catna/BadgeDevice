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
    //TODO: 需要在此处添加访问蓝牙功能的提示开关
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
        case CBCentralManagerStatePoweredOn:
            [self turnON];
            break;
            
        default:[self turnOFF];
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // 这个方法是搜索到设备的代理，当搜索到的设备的名字和预定义好的名字一致时，就把设备连接添加到设备列表内，同时准备去连接这个设备
    if ([peripheral.name isEqualToString:DeviceNameOne] || [peripheral.name isEqualToString:DeviceNameTwo]) {
        TBLEDevice *dev = [[TBLEDevice alloc] initWithPeripheral:peripheral];
        // 将设备的广播信息保存起来，以便会后需要用到的时候进行处理
        dev.advertise = advertisementData;
        [self.devices setObject:dev forKey:peripheral];
        // 尝试连接到这个设备，参数设置为空
        //TODO: 之后可以在这个位置设置一个连接断开的参数选项作为丰富设置功能的一个功能
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