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
#import <SVProgressHUD.h>

#import "TBluetoothTools.h"

// NSString *const kTBluetoothConnectSuccess = @"kTBluetoothConnectSuccess";

NSString *const kTBLENotificationDisConnect = @"kTBLENotificationDisConnect";

NSString *const kTBLENotificationDataUpdate = @"kTBLENotificationDataUpdate";
NSString *const kTBLENotificationReadMacAddress = @"kTBLENotificationReadMacAddress";


@interface TBluetooth ()

@property (nonatomic ,strong) NSDictionary <NSString *,NSArray<NSString *>*>* seConfDataDic;
@property (nonatomic ,strong ,readonly) NSTimer *timer;
@end


@interface TBluetooth (Tools)
- (void)distillMacAddr:(CBPeripheral *)peri ch:(CBCharacteristic *)ch;
- (void)readValueForCh:(CBCharacteristic *)characteristic inPeri:(CBPeripheral *)peri;
@end


@implementation TBluetooth
@synthesize timer = _timer;
@synthesize devicesDic = _devicesDic;
@synthesize babyBluetooth = _babyBluetooth;

#pragma mark - life cycle

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
    [self cancelConnectingAndConfig];
    [self setupWorkFlow];
    if (autoSearch) {
        [self.timer fire];
    } else {
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
    __block typeof(self) weakSelf = self;
    // 蓝牙设备开启状态的委托
    [self.babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        switch (central.state) {
            case CBCentralManagerStateUnknown:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateUnknown"];
                break;
            case CBCentralManagerStateResetting:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateResetting"];
                break;
            case CBCentralManagerStateUnsupported:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateUnsupported"];
                break;
            case CBCentralManagerStateUnauthorized:
                [SVProgressHUD showInfoWithStatus:@"CBCentralManagerStateUnauthorized"];
                break;
            case CBCentralManagerStatePoweredOff:
                [SVProgressHUD showInfoWithStatus:@"蓝牙已关闭"];
                break;
            case CBCentralManagerStatePoweredOn:
                [SVProgressHUD showInfoWithStatus:@"蓝牙已打开，开始扫描设备"];
                break;
            default:
                break;
        }
    }];

    //只发现名字符合要求的设备，其他的一律忽略
    [self.babyBluetooth setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
         if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
             return YES;
         } else {
             return NO;
         }
     }];

    // 扫描到设备的委托
    [self.babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"已扫描的设备:%@",peripheral.name);

        if (![strongSelf.devicesDic.allKeys containsObject:peripheral]) {
            [strongSelf.devicesDic setObject:[[TBLEDevice alloc] init] forKey:peripheral];
        }
        strongSelf.devicesDic[peripheral].name = peripheral.name;
        strongSelf.devicesDic[peripheral].peri = peripheral;
        strongSelf.devicesDic[peripheral].advertisementData = advertisementData;
    }];

    [self.babyBluetooth setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        if ([peripheralName isEqualToString:DeviceNameOne] || [peripheralName isEqualToString:DeviceNameTwo]) {
            return YES;
        } else {
            return NO;
        }
    }];

    // 连接到设备成功的委托
    [self.babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"连接成功---%@",peripheral.name);
        if ([strongSelf.devicesDic.allKeys containsObject:peripheral]) {
            strongSelf.devicesDic[peripheral].isConnect = YES;
        }
    }];

    // 设备断开连接的委托
    [self.babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开%@连接", peripheral.name);
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.devicesDic.allKeys containsObject:peripheral]) {
            strongSelf.devicesDic[peripheral].isConnect = NO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotificationDisConnect object:nil];
    }];

//    // 扫描到设备的 service 的委托
//    [self.babyBluetooth setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
//        #ifndef DEBUG
//        for (CBService *service in peripheral.services) {
//           NSLog(@"CBService, UUID:%@", service.UUID.UUIDString);
//        }
//        #endif
//    }];

////     扫描到设备某个 service 下的 characteristic 的委托
//    [self.babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//
//        [strongSelf openPeri:peripheral dataGalleryService:service];
//    }];

    [self.babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        //筛选出可以设备的mac地址
        [strongSelf distillMacAddr:peripheral ch:characteristic];
        [strongSelf readValueForCh:characteristic inPeri:peripheral];
    }];
}

- (void)search {
    self.babyBluetooth.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
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

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:AutoSearchTimeGap target:self selector:@selector(search) userInfo:nil repeats:YES];
    }
    return _timer;
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
        NSString *macAddress = [TBluetoothTools macWithCharacteristic:ch];
        NSLog(@"读取到设备mac地址:%@",macAddress);
        if ([self.devicesDic.allKeys containsObject:peri]) {
            self.devicesDic[peri].macAddr = macAddress;
            [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotificationReadMacAddress object:nil];
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
                    self.devicesDic[peri].currentRawData.PrRawData = characteristic.value;
                }
//                NSLog(@"读取设备%@的%@数据--%@",self.devicesDic[peri].macAddr,dataName,characteristic.value);
                [[NSNotificationCenter defaultCenter] postNotificationName:kTBLENotificationDataUpdate object:nil];
            }
        }
    }
}

///打开数据通道
- (void)dataGalleryOpen:(BOOL)open peri:(CBPeripheral *)peri service:(CBService *)service{
    for (NSString *key in self.seConfDataDic.allKeys) {
        if ([service.UUID.UUIDString isEqualToString:key]) {
            for (CBCharacteristic *ch in service.characteristics) {
                if ([ch.UUID.UUIDString isEqualToString:self.seConfDataDic[key][0]]) {
                    [TBluetoothTools writeValueForCBPeripheral:peri CBCharacteristic:ch];
                }
                if ([ch.UUID.UUIDString isEqualToString:self.seConfDataDic[key][1]]) {
#ifdef DEBUG
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

@end
