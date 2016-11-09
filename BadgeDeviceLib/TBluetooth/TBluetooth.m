//
//  TBluetooth.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetooth.h"
#import <BabyBluetooth.h>

#import "TBLEDefine.h"
#import "TBLEDevice.h"
#import "TBLEDeviceRawData.h"
#import "TBLEDeviceDistill.h"
#import "TBLEDeviceActive.h"
#import "TBLENotification.h"
#import "TBluetoothTools.h"

@interface TBluetooth ()
@property (nonatomic, strong, readonly) BabyBluetooth *babyBluetooth;/**<babyBluetooth tool*/
@property (nonatomic, strong) NSDictionary <NSString *,NSArray<NSString *>*>* seConfDataDic;

@property (nonatomic, strong) NSTimer *timer;
@end


@interface TBluetooth (Tools)
- (void)distillMacAddr:(CBPeripheral *)peri ch:(CBCharacteristic *)ch;
- (void)readValueForCh:(CBCharacteristic *)characteristic inPeri:(CBPeripheral *)peri;
@end


@implementation TBluetooth
@synthesize BLEAvaliable = _BLEAvaliable;
@synthesize devicesDic = _devicesDic;
@synthesize babyBluetooth = _babyBluetooth;

#pragma mark - life cycle
- (id)init {
    if (self = [super init]) {
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
        [self cancelConnectingAndConfig];
        [self setupWorkFlow];
        self.autoSearchEnable = NO;
        [self.timer fire];
    }
    return self;
}

#pragma mark - Public methods
+ (instancetype)sharedBluetooth {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)scanAndConnect:(BOOL)autoSearch {
    _autoSearchEnable = autoSearch;
    [self search];
}

- (void)removeDevice:(TBLEDevice *)device {
    if ([self.devicesDic.allKeys containsObject:device.peri]) {
        [self.devicesDic removeObjectForKey:device.peri];
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiManagerDeviceChanged object:self.devicesDic];
    }
    if (device.isConnect) {
        [self.babyBluetooth cancelPeripheralConnection:device.peri];
    }
}

- (void)stop {
    self.babyBluetooth.stop(1);
    [self.devicesDic removeAllObjects];
}

- (BOOL)connect:(BOOL)connect peri:(CBPeripheral *)peri {
    if (!peri) return NO;
    if (connect) {
        self.babyBluetooth.having(peri).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
    } else {
        [self.babyBluetooth cancelPeripheralConnection:peri];
    }
    return YES;
}

- (void)eTimer {
    if (self.autoSearchEnable) {
        [self search];
    }
}

#pragma mark - private methods
- (void)cancelConnectingAndConfig {
    [self.babyBluetooth cancelAllPeripheralsConnection];
    // 扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@NO};
    [self.babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

- (void)setupWorkFlow {
    weakify(self);

    [self.babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        strongify(self);
        switch (central.state) {
            case CBCentralManagerStatePoweredOn:
                NSLog(@"电源开启%@", self.devicesDic);
                for (TBLEDevice *d in self.devicesDic.allValues) {
                    if (d.selected) {
                        self.babyBluetooth.having(d.peri).connectToPeripherals().discoverServices().discoverCharacteristics().begin();
                    }
                }
                break;
                
            default:
                NSLog(@"电源关闭或者不可用%@", self.devicesDic);
                break;
        }
        _BLEAvaliable = central.state == CBCentralManagerStatePoweredOn;
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiManagerStatusChanged object:nil];
    }];
    
    //只发现名字符合要求的设备，其他的一律忽略
    [self.babyBluetooth setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
         if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
             return YES;
         }
         return NO;
     }];

    // 扫描到设备的委托
    [self.babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        strongify(self);
        NSLog(@"已扫描的设备:%@",peripheral.name);
        if (![self.devicesDic.allKeys containsObject:peripheral]) {
            [self.devicesDic setObject:[[TBLEDevice alloc] init] forKey:peripheral];
            [self.devicesDic[peripheral] setValue:peripheral forKey:@"peri"];
            [self.devicesDic[peripheral] setValue:advertisementData forKey:@"advertisementData"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kBLENotiManagerDeviceChanged object:self.devicesDic];
        }
    }];

    [self.babyBluetooth setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
            return YES;
        }
        return NO;
    }];

    // 连接到设备成功的委托
    [self.babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        strongify(self);
        NSLog(@"连接成功---%@",peripheral.name);
        if ([self.devicesDic.allKeys containsObject:peripheral]) {
            [self.devicesDic[peripheral] setValue:@(YES) forKey:@"isConnect"];
        }
    }];

    // 设备断开连接的委托
    [self.babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开%@连接", peripheral.name);
        strongify(self);
        if ([self.devicesDic.allKeys containsObject:peripheral]) {
            [self.devicesDic[peripheral] setValue:@(NO) forKey:@"isConnect"];
        }
    }];

//     扫描到设备某个 service 下的 characteristic 的委托
    [self.babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        strongify(self);
        for (NSString *key in self.seConfDataDic.allKeys) {
            if ([service.UUID.UUIDString isEqualToString:key]) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                        if ([self.devicesDic.allKeys containsObject:peripheral]) {
                            [self.devicesDic[peripheral].activeTool store:characteristic peri:peripheral];
                        }
                }
            }
        }
        
        if ([service.UUID.UUIDString isEqualToString:ConnectService]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:ConnectData]) {
                    self.devicesDic[peripheral].distillTool.historyDataCharacteristic = characteristic;
                }
                
                if ([characteristic.UUID.UUIDString isEqualToString:ConnectTimeConfig]) {
                    self.devicesDic[peripheral].distillTool.timeCalibrateCharacteristic = characteristic;
                }
            }
        }
    }];

    [self.babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        strongify(self);
        //筛选出可以设备的mac地址
        [self distillMacAddr:peripheral ch:characteristic];
        [self readValueForCh:characteristic inPeri:peripheral];
        if ([characteristic.UUID.UUIDString isEqualToString:ConnectData]) {
            [self.devicesDic[peripheral].distillTool distillData];
        }
    }];
}

- (void)search {
    self.babyBluetooth.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().begin();
}



#pragma mark - getter
- (NSMutableDictionary <CBPeripheral *,TBLEDevice *>*)devicesDic {
    if (!_devicesDic) {
        _devicesDic = [[NSMutableDictionary alloc] init];
    }
    return _devicesDic;
}

- (BabyBluetooth *)babyBluetooth {
    if (!_babyBluetooth) {
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
    }
    return _babyBluetooth;
}

- (NSDictionary <NSString *,NSArray <NSString *>*>*)seConfDataDic {
    if (!_seConfDataDic) {
        _seConfDataDic = @{UVService:@[UVConfig,UVData],THService:@[THConfig,THData],PrService:@[PrConfig,PrData]};
    }
    return _seConfDataDic;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:AutoSearchTimeGap target:self selector:@selector(eTimer) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end

@implementation TBluetooth (Tools)
- (void)distillMacAddr:(CBPeripheral *)peri ch:(CBCharacteristic *)ch {
    if ([ch.UUID.UUIDString isEqualToString:MacAddrUUID]) {
        NSString *macAddress = [TBluetoothTools macWithCharacteristicData:ch.value];
        NSLog(@"读取到设备mac地址:%@",macAddress);
        if ([self.devicesDic.allKeys containsObject:peri]) {
            [self.devicesDic[peri] setValue:macAddress forKey:@"macAddr"];
        }
    }
}

- (void)readValueForCh:(CBCharacteristic *)characteristic inPeri:(CBPeripheral *)peri {
    if ([self.devicesDic.allKeys containsObject:peri]) {
        NSString *UUIDStr = characteristic.UUID.UUIDString;
        for (NSArray *uuidArr in self.seConfDataDic.allValues) {
            if ([uuidArr containsObject:UUIDStr]) {
                [self.devicesDic[peri].activeTool updateData:characteristic];
            }
        }
    }
}

@end
