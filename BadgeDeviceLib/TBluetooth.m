//
//  TBluetooth.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetooth.h"
#import "TBLEDefine.h"
#import "TBLEDevice.h"

#import <BabyBluetooth.h>
#import "TBluetoothTools.h"

@interface TBluetooth ()
@property (nonatomic ,strong ,readonly) BabyBluetooth *babyBluetooth;/**<babyBluetooth tool*/
@property (nonatomic ,strong) NSDictionary <NSString *,NSArray<NSString *>*>* seConfDataDic;
@end


@interface TBluetooth (Tools)
- (void)distillMacAddr:(CBPeripheral *)peri ch:(CBCharacteristic *)ch;
- (void)readValueForCh:(CBCharacteristic *)characteristic inPeri:(CBPeripheral *)peri;
@end


@implementation TBluetooth
@synthesize devicesDic = _devicesDic;
@synthesize babyBluetooth = _babyBluetooth;

#pragma mark - life cycle
- (id)init {
    if (self = [super init]) {
        _babyBluetooth = [BabyBluetooth shareBabyBluetooth];
        [self cancelConnectingAndConfig];
        [self setupWorkFlow];
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

- (void)scanAndConnect {
    [self search];
}

- (void)removeDevice:(TBLEDevice *)device {
    if ([self.devicesDic.allKeys containsObject:device.peri]) {
        [self.devicesDic removeObjectForKey:device.peri];
    }
    if (device.isConnect) {
        [self.babyBluetooth cancelPeripheralConnection:device.peri];
    }
}

- (void)stop {
    self.babyBluetooth.stop(1);
    [self.devicesDic removeAllObjects];
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
        }
        self.devicesDic[peripheral].name = peripheral.name;
        self.devicesDic[peripheral].peri = peripheral;
        self.devicesDic[peripheral].advertisementData = advertisementData;
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
            [self.devicesDic[peripheral] setConnectStatus:YES];
        }
        
    }];

    // 设备断开连接的委托
    [self.babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开%@连接", peripheral.name);
        strongify(self);
        if ([self.devicesDic.allKeys containsObject:peripheral]) {
            [self.devicesDic[peripheral] setConnectStatus:NO];
        }
    }];

//     扫描到设备某个 service 下的 characteristic 的委托
    [self.babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        strongify(self);
        [self dataGalleryOpen:YES peri:peripheral service:service];
    }];

    [self.babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        strongify(self);
        //筛选出可以设备的mac地址
        [self distillMacAddr:peripheral ch:characteristic];
        [self readValueForCh:characteristic inPeri:peripheral];
    }];
}

- (void)search {
    self.babyBluetooth.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
}

///打开数据通道
- (void)dataGalleryOpen:(BOOL)open peri:(CBPeripheral *)peri service:(CBService *)service{
    for (NSString *key in self.seConfDataDic.allKeys) {
        if ([service.UUID.UUIDString isEqualToString:key]) {
            NSArray *serviceConfigAndData = self.seConfDataDic[key];
            for (CBCharacteristic *ch in service.characteristics) {
                if ([ch.UUID.UUIDString isEqualToString:serviceConfigAndData.firstObject]) {
                    Byte b = open ? 0x01 : 0x00;
                    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
                    [peri writeValue:data forCharacteristic:ch type:CBCharacteristicWriteWithResponse];
                }
                if ([ch.UUID.UUIDString isEqualToString:serviceConfigAndData.lastObject]) {
#if DEBUG
                    NSDictionary *nameDic = @{UVService:@"紫外线",THService:@"温湿度",PrService:@"大气压"};
                    NSString *str = nameDic[key];
                    NSLog(@"读取到%@数据--%@",str,ch.value);
#endif
                    [peri setNotifyValue:open forCharacteristic:ch];
                    open ? [self.babyBluetooth AutoReconnect:peri] : [self.babyBluetooth AutoReconnectCancel:peri];
                }
            }
        }
    }
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

@end

@implementation TBluetooth (Tools)
- (void)distillMacAddr:(CBPeripheral *)peri ch:(CBCharacteristic *)ch {
    if ([ch.UUID.UUIDString isEqualToString:MacAddrUUID]) {
        NSString *macAddress = [TBluetoothTools macWithCharacteristicData:ch.value];
        NSLog(@"读取到设备mac地址:%@",macAddress);
        if ([self.devicesDic.allKeys containsObject:peri]) {
            [self.devicesDic[peri] setMacAddr:macAddress];
        }
    }
}

- (void)readValueForCh:(CBCharacteristic *)characteristic inPeri:(CBPeripheral *)peri {
    if ([self.devicesDic.allKeys containsObject:peri]) {
        NSString *UUIDStr = characteristic.UUID.UUIDString;
        for (NSArray *uuidArr in self.seConfDataDic.allValues) {
            if ([uuidArr containsObject:UUIDStr]) {
                NSString *dataName;
                if ([UUIDStr isEqualToString:THData]) {
                    dataName = @"温湿度";
                    self.devicesDic[peri].currentRawData.THRawData = characteristic.value;
                } else if ([UUIDStr isEqualToString:UVData]) {
                    dataName = @"紫外线";
                    self.devicesDic[peri].currentRawData.UVRawData = characteristic.value;
                } else if ([UUIDStr isEqualToString:PrData]) {
                    dataName = @"大气压";
                    self.devicesDic[peri].currentRawData.PrRawData = [characteristic.value copy];
                }
                NSLog(@"读取设备%@的%@数据--%@",self.devicesDic[peri].macAddr,dataName, self.devicesDic[peri].currentRawData);
            }
        }
    }
}

@end