//
//  TBluetooth.m
//  BadgeDevice
//
//  Created by MX on 16/4/21.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "TBluetooth.h"
#import <BabyBluetooth.h>
#import <SVProgressHUD.h>

@interface TBluetoothDevice ()

@end
@implementation TBluetoothDevice

@end

NSString *const kTBluetoothConnectSuccess = @"kTBluetoothConnectSuccess";


@interface TBluetooth ()
@property (nonatomic ,strong) BabyBluetooth *babyBluetooth;
@end

@implementation TBluetooth
@synthesize device = _device;

#pragma mark - life cycle
- (id)init {
    if (self = [super init]) {
        self.babyBluetooth = [BabyBluetooth shareBabyBluetooth];
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

- (void)connect {
    [self cancelBluetoothConnectingAndConfigConnectSetting];
    [self setupBluetoothWorkFlow];
    [self bluetoothStartWork];
}

- (void)cancelConnecting {
    [self cancelBluetoothConnectingAndConfigConnectSetting];
}

- (void)readDataWithCompletionHandler:(void (^)())handler {
    
}

#pragma mark - private methods
- (void)cancelBluetoothConnectingAndConfigConnectSetting {
    [_babyBluetooth cancelAllPeripheralsConnection];
    // 扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    [_babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

- (void)setupBluetoothWorkFlow {
    __block typeof(self) weakSelf = self;
    
    // 蓝牙设备开启状态的委托
    [_babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
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
    
    // 扫描到设备的委托
    [_babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        NSLog(@"已扫描的设备:%@",peripheral.name);
    }];
    
    // 设置连接设备的过滤器，只连接设备
    [_babyBluetooth setFilterOnConnetToPeripherals:^BOOL(NSString *peripheralName) {
        if ([peripheralName isEqualToString:@"TI BLE Sensor Tag"] || [peripheralName isEqualToString:@"SensorTag"]) {
            return YES;
        }
        return NO;
    }];
    
    // 连接到设备成功的委托
    [_babyBluetooth setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"连接成功");
        strongSelf.device.name = peripheral.name;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTBluetoothConnectSuccess object:nil userInfo:nil];
    }];
//    
    // 设备断开连接的委托
    [_babyBluetooth setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"断开%@连接", peripheral.name);
//        __strong typeof(self) strongSelf = weakSelf;
//        if (peripheral == strongSelf.myPeripheral.peripheral) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:KTDisConnected object:nil];
//        }
//        if (strongSelf.retryWhenLostConnect) {
//            [strongSelf bluetoothStartWork];
//        }
    }];
//
    // 扫描到设备的 service 的委托
    [_babyBluetooth setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
//        for (CBService *service in peripheral.services) {
//            NSLog(@"CBService, UUID:%@", service.UUID.UUIDString);
//        }
    }];
//
//    // 扫描到设备某个 characteristic 的值的委托
//    [_babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        __strong typeof(self) strongSelf = weakSelf;
//        // 不需要不断通知时，只读取一次数据
//        if (!strongSelf.notify) {
//            [strongSelf invocateMethodWithCharacterastic:characteristic strongSelf:strongSelf];
//        }
//    }];
//    
//    __block CBCharacteristic *uvDataChara;
//    __block CBCharacteristic *thDataChara;
//    __block CBCharacteristic *prDataChara;
    
    // 扫描到设备某个 service 下的 characteristic 的委托
//    [_babyBluetooth setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        for (CBCharacteristic *characteristic in service.characteristics) {
//            if ([characteristic.UUID.UUIDString isEqualToString:@"2A23"]) {
//                //                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//                //                [peripheral readValueForCharacteristic:characteristic];
//                // 找到 UV 的 service
//            }
//        }
//        if ([service.UUID.UUIDString isEqualToString:uvServiceUUID]) {
//            for (CBCharacteristic *chara in service.characteristics) {
//                // 找到 UV Config 的 characteristic，这里写入 0x01，启动传感器的自动通知
//                if ([chara.UUID.UUIDString isEqualToString:uvConfigUUID]) {	                    [strongSelf writeValueForCBPeripheral:peripheral CBCharacteristic:chara];
//                }
//                
//                if ([chara.UUID.UUIDString isEqualToString:uvDataUUID]) {
//                    // 找到 UV Data 的 characteristic
//                    uvDataChara = chara;
//                    if (strongSelf.notify) {	// 需要不断通知
//                        // 注册 UV 值的通知，获取回调值
//                        [strongSelf.babyBt notify:peripheral characteristic:chara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//                            if (strongSelf.uv) {
//                                
//                                int v = [BabyToy ConvertDataToInt:characteristics.value];
//                                NSString *str = [NSString stringWithFormat:@"原始data:%@\n设备返回的值是:%x",characteristics.value,v];
//                                
//                                NSString *vstr = [NSString stringWithFormat:@"%@\n计算的值是:%@\n计算的UV等级是:%@",str,[BluetoothReadWriteHelper stringUVWithValue:characteristics.value],[BluetoothReadWriteHelper stringUVLevelWithValue:characteristics.value]];
//                                strongSelf.uv(vstr);
//                            }
//                            if (strongSelf.uvLe) {
//                                strongSelf.uvLe([BluetoothReadWriteHelper stringUVLevelWithValue:characteristics.value]);
//                            }
//                        }];
//                    }
//                }
//            }
//        }
//        // 温湿度
//        if ([service.UUID.UUIDString isEqualToString:thServiceUUID]) {
//            for (CBCharacteristic *chara in service.characteristics) {
//                if ([chara.UUID.UUIDString isEqualToString:thConfigUUID]) {
//                    [strongSelf writeValueForCBPeripheral:peripheral CBCharacteristic:chara];
//                }
//                
//                if ([chara.UUID.UUIDString isEqualToString:thDataUUID]) {
//                    thDataChara = chara;
//                    if (strongSelf.notify) {	// 需要不断通知
//                        // 注册温湿度值的通知，获取回调值
//                        [strongSelf.babyBt notify:peripheral characteristic:chara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//                            if (strongSelf.temp) {
//                                strongSelf.temp([BluetoothReadWriteHelper stringTempWithValue:characteristics.value]);
//                            }
//                            if (strongSelf.humi) {
//                                strongSelf.humi([BluetoothReadWriteHelper stringHumiWithValue:characteristics.value]);
//                            }
//                        }];
//                    }
//                }
//            }
//        }
//        // 气压
//        if ([service.UUID.UUIDString isEqualToString:prServiceUUID]) {
//            for (CBCharacteristic *chara in service.characteristics) {
//                if ([chara.UUID.UUIDString isEqualToString:prConfigUUID]) {
//                    [strongSelf writeValueForCBPeripheral:peripheral CBCharacteristic:chara];
//                }
//                
//                if ([chara.UUID.UUIDString isEqualToString:prDataUUID]) {
//                    prDataChara = chara;
//                    // 需要不断通知
//                    if (strongSelf.notify) {
//                        // 注册气压值的通知，获取回调值
//                        [strongSelf.babyBt notify:peripheral characteristic:chara block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//                            if (strongSelf.pres) {
//                                strongSelf.pres([BluetoothReadWriteHelper stringPressureWithValue:characteristics.value]);
//                            }
//                        }];
//                    }
//                }
//            }
//        }
//    }];
    
//    [_babyBluetooth setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        if ([characteristic.UUID.UUIDString isEqualToString:@"2A23"]) {
//            // 只取 System ID
//            NSString *macAddress = [BluetoothDevicePersistence macWithCharacteristic:characteristic];
//            //可以添加
//            BOOL canAddDev = YES;
//            for (NSString *macIgnoreStr in weakSelf.arrayIgnoreMacAddressList) {
//                if ([macAddress isEqualToString:macIgnoreStr]) {
//                    if (weakSelf.opType == BluetoothOperateTypeConnect) {
//                        canAddDev = NO;
//                        weakSelf.canReadValueOperate = NO;
//                        [weakSelf.peripheraIgnoreList addObject:peripheral.identifier.UUIDString];
//                        //停止与当前已存在的设备的连接
//                        [weakSelf.babyBt.centralManager cancelPeripheralConnection:peripheral];
//                        [weakSelf bluetoothStartWork];
//                        return;
//                        
//                    } else if (weakSelf.opType == BluetoothOperateTypeRead) {
//                        weakSelf.canReadValueOperate = YES;
//                    }
//                }
//            }
//            //在是读设备数据的情况下，如果设置不过滤，也可以读取设备
//            if (weakSelf.opType == BluetoothOperateTypeRead) {
//                if (!weakSelf.filter) {
//                    weakSelf.canReadValueOperate = YES;
//                }
//            }
//            if (canAddDev) {
//                if ([weakSelf.macAddressEspecially isEqualToString:macAddress] || [weakSelf.macAddressEspecially isEqual:@""] || weakSelf.macAddressEspecially == nil) {
//                    // 搜索到的蓝牙与已经连过的 mac 地址一致
//                    [Bluetooth shareBluetooth].myPeripheral = [[PeripheralInfoModel alloc] initModelWithPeripheral:peripheral characteristic:characteristic];
//                    if (weakSelf.opType == BluetoothOperateTypeConnect) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kTAddANewDevice object:nil];
//                    }
//                }
//            } else {
//                [weakSelf.babyBt.centralManager cancelPeripheralConnection:peripheral];
//                [weakSelf bluetoothStartWork];
//            }
//        }
//    }];
    // 某个 characteristic 的 value 有写入时
//    [_babyBluetooth setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
//        
//        __strong typeof(self) strongSelf = weakSelf;
//        if (strongSelf.canReadValueOperate) {
//            // UV 写入完，去重新读值
//            if ([characteristic.UUID.UUIDString isEqualToString:uvConfigUUID]) {
//                strongSelf.babyBt.characteristicDetails(strongSelf.myPeripheral.peripheral, uvDataChara);
//            }
//            // 温湿度写入完，去重新读值
//            if ([characteristic.UUID.UUIDString isEqualToString:thConfigUUID]) {
//                strongSelf.babyBt.characteristicDetails(strongSelf.myPeripheral.peripheral, thDataChara);
//            }
//            // 气压写入完，去重新读值
//            if ([characteristic.UUID.UUIDString isEqualToString:prConfigUUID]) {
//                strongSelf.babyBt.characteristicDetails(strongSelf.myPeripheral.peripheral, prDataChara);
//            }
//        }
//    }];
}

- (void)bluetoothStartWork {
    _babyBluetooth.scanForPeripherals().then.connectToPeripherals().then.discoverServices().then.discoverCharacteristics().then.readValueForCharacteristic().begin();
}

#pragma mark - getter
- (TBluetoothDevice *)device {
    if (!_device) {
        _device = [[TBluetoothDevice alloc] init];
    }
    return _device;
}

@end
